# sudo pwsh -Command "iex '& ([scriptblock]::Create((iwr https://raw.githubusercontent.com/abdullahfarook/kube/main/configure-k3s.ps1).Content)) -disable_traefik 0 -taint_server 0'"
param (
    [bool]$disable_traefik = $true,
    [bool]$taint_server = $true
)

function Write-Log {
    param (
        [string]$message,
        [string]$level = "INF"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    if ($level -eq "ERR") {
        Write-Host -NoNewline "[$timestamp "
        Write-Host -NoNewline "$level] " -ForegroundColor Red
        write-host  $message
    }
    else {
        Write-Host -NoNewline "[$timestamp "
        Write-Host -NoNewline "$level] " -ForegroundColor Green
        write-host  $message
    }
}

$serviceFilePath = "/etc/systemd/system/k3s.service"

if (-not (Test-Path $serviceFilePath)) {
    Write-Log "Service file not found at $serviceFilePath" "ERROR"
    throw "Service file not found"
}
# Read the content of the service file
$serviceFileContent = Get-Content -Path $serviceFilePath -Raw
Write-Log "Read service file content successfully"
# Add flag below the line containing 'server \'
[System.Collections.ArrayList]$lines = $serviceFileContent -split "`n"
$serverFlagIndex = $lines.IndexOf(($lines | Where-Object { $_ -match "server \\" }));
$serverContent = $serviceFileContent.Substring($serverFlagIndex);
$flags = @{
    '--disable_traefik' = [bool]$disable_traefik
    '--taint_server' = [bool]$taint_server
    # Add more flags here
}

# Loop through each flag in the $flags hashtable
foreach ($flag in $flags.GetEnumerator()) {
    $flagName = $flag.Key
    $flagValue = $flag.Value

    # Check if the flag already exists in the server content
    $containsFlag = $serverContent.Contains($flagName)
    if ($containsFlag -and $flagValue) {
        Write-Log "$flagName flag already exists"
    }

    # Check if the flag exists but its value is different
    if ($containsFlag -and (-not $flagValue)) {
        $index = $lines.IndexOf(($lines | Where-Object { $_ -like "*$flagName*" }))
        $lines.RemoveAt($index)
        Write-Log "$flagName flag removed"
    }

    # Check if the flag doesn't exist and its value is true
    if (-not $containsFlag -and $flagValue) {
        $lines.Insert($serverFlagIndex + 1, "`t'$flagName' \")
        Write-Log "Added '$flagName' flag"
    }
}

# Remove empty lines from the content
$lines = $lines | Where-Object { $_ -ne "" }
$serviceFileContent = $lines -join "`n"
# Write the modified content back to the service file
$serviceFileContent | Out-File -FilePath $serviceFilePath -Force
# Reload the systemd daemon
Start-Process -NoNewWindow -FilePath "sudo" -ArgumentList "systemctl daemon-reload" -Wait
Write-Log "Systemd daemon reloaded successfully"
# # Restart the k3s service
Start-Process -NoNewWindow -FilePath "sudo" -ArgumentList "systemctl restart k3s" -Wait
Write-Log "k3s service restarted successfully"