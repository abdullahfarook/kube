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
$serverFlagIndex = $lines.IndexOf(($lines | Where-Object { $_ -like "*server \*" }));
$serverContent = $serviceFileContent.Substring($serverFlagIndex);

[System.Collections.ArrayList]$flags = @(
    @{
        Key =   [string]    "--disable"
        Value = [string]    "traefik"
        Input = [bool]      $disable_traefik
    },
    @{
        Key =   [string]    "--node-taint"
        Value = [string]    "CriticalAddonsOnly=true:NoExecute"
        Input = [bool]      $taint_server
    }
)
# Loop through each flag in the $flags hashtable
foreach ($flag in $flags.GetEnumerator()) {
    $flagKey = $flag.Key
    $flagValue = $flag.Value
    $flagInput = $flag.Input
    $flagName  = $flagKey + " " + $flagValue

    # Check if the flag already exists in the server content
    $containsFlag = $serverContent.Contains($flagValue)
    if ($containsFlag -and $flagInput) {
        Write-Log "$flagName already exists"
    }

    # Check if the flag exists but its value is different
    if ($containsFlag -and (-not $flagInput)) { 
        Write-Log "Removing flag $flagName"
        $index = $lines.IndexOf(($lines | Where-Object { $_ -like "*$flagValue*" }))
        Write-Log "$flag flag index: $index"
        $lines.RemoveAt($index)
        $lines.RemoveAt($index-1)
    }

    # Check if the flag doesn't exist and its value is true
    if (-not $containsFlag -and $flagInput) {
        Write-Log "Adding flag $flagName"
        $lines.Insert($serverFlagIndex + 1, "`t'$flagKey' \")
        $lines.Insert($serverFlagIndex + 2, "`t'$flagValue' \")
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