param (
    [bool]$disable_traefik = $true,
    [bool]$taint_server = $true
)

# Define a logging function
function Write-Log {
    param (
        [string]$message,
        [string]$level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if ($level -eq "ERR") {
        Write-Host -NoNewline "$timestamp "
        Write-Host -NoNewline "[$level] " -ForegroundColor Red
        write-host  $message
    }else{
        Write-Host -NoNewline "$timestamp "
        Write-Host -NoNewline "[$level] " -ForegroundColor Green
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
# Disable traefik
Write-Log "disable_traefik: $disable_traefik"
if ($disable_traefik -eq $false) {
    $serviceFileContent = $serviceFileContent -replace ' --disable traefik', ''
    Write-Log "Traefik disable flag removed"
}
else {
    if($serviceFileContent -like '*--disable traefik*') {
        Write-Log "Traefik disable flag already exists"
    } else {
        $serviceFileContent = $serviceFileContent -replace "'server' ", "'server' --disable traefik "
        Write-Log "Traefik disable flag added"
        
    }
}
# Taint the server
Write-Log "taint_server: $taint_server"
if ($taint_server -eq $false) {
    $serviceFileContent = $serviceFileContent -replace ' --node-taint CriticalAddonsOnly=true:NoExecute', ''
    Write-Log "Server taint flag removed"
}
else
{
    if($serviceFileContent -like '*--node-taint CriticalAddonsOnly=true:NoExecute*') {
        Write-Log "Server taint flag already exists"
        
    } else {
        $serviceFileContent = $serviceFileContent -replace "'server' ", "'server' --node-taint CriticalAddonsOnly=true:NoExecute "
        Write-Log "Server taint flag added"
    }
}
# echo $serviceFileContent
# Write the modified content back to the service file
$serviceFileContent | Out-File -FilePath $serviceFilePath -Force
# Reload the systemd daemon
Start-Process -NoNewWindow -FilePath "sudo" -ArgumentList "systemctl daemon-reload" -Wait
Write-Log "Systemd daemon reloaded successfully"
# # Restart the k3s service
Start-Process -NoNewWindow -FilePath "sudo" -ArgumentList "systemctl restart k3s" -Wait
Write-Log "k3s service restarted successfully"