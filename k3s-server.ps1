# sudo pwsh -Command "iex '& ([scriptblock]::Create((iwr https://raw.githubusercontent.com/abdullahfarook/kube/main/k3s-server.ps1).Content)) -cluster_ip <cluster_ip> -mysql_ip <mysql_ip> -mysql_user <mysql_user> -mysql_password <mysql_password> -token <token>'" 
# sudo curl -sfL https://get.k3s.io | \
# INSTALL_K3S_EXEC="--write-kubeconfig-mode 664 --tls-san <vm ip>"  \
# INSTALL_K3S_CHANNEL=stable \sh -s - server \
# --node-taint CriticalAddonsOnly=true:NoExecute --disable traefik --token <token> \
# --datastore-endpoint="mysql://<user>:<password>@tcp(<mysql ip>:3306)/k3s"
param (
    [Parameter(Mandatory)][string]$cluster_ip,
    [string]$mysql_ip = "127.0.0.1",
    [string]$mysql_port = "3306",
    [Parameter(Mandatory)][string]$mysql_user,
    [Parameter(Mandatory)][string]$mysql_password,
    [string]$token?,
    [string]$channel = "stable",
    [string]$version = "latest",
    [bool]$disable_traefik = $false,
    [bool]$taint_server = $false,
    [bool]$uninstall = $false
)
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
function Write-Err {
    param (
        [string]$message
    )
    Write-Log $message "ERR"
    exit 1
}
if ($uninstall -eq $true) {
    # if file exists, execute the uninstall script
    if (Test-Path /usr/local/bin/k3s-uninstall.sh) {
        Write-Log "Uninstalling k3s server"
        /usr/local/bin/k3s-uninstall.sh
    }
    else {
        Write-Err "k3s-uninstall.sh not found"
    }
    exit 0
}
# install k3s server
$command = @"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 664 --tls-san $cluster_ip" INSTALL_K3S_CHANNEL=$channel \sh -s - server
"@

if ($taintServer -eq $true) {
    $command += " --node-taint CriticalAddonsOnly=true:NoExecute"
}
if ($disableTraefik -eq $true) {
    $command += " --disable traefik"
}
if ($null -ne $token) {
    $command += " --token $token"
}
$command += " --datastore-endpoint='mysql://${mysql_user}:$mysql_password@tcp(${mysql_ip}:${mysql_port})/k3s'"

Write-Host "Executing command: $command"
# execute the command in bash
bash -c $command
if (-not $?) {
    Write-Err "Failed to install k3s server: $_"
    exit 1
}
# setup credentials
# goto /etc/rancher/k3s/k3s.yaml
# print the content of the file but wrap text on
cat /etc/rancher/k3s/k3s.yaml

# if insecure connection, SSL certificate needs to be installed
# goto /var/lib/rancher/k3s/server/tls/
# download client-ca.crt and install

# Getting the agent token
$agentToken = cat -Path "/var/lib/rancher/k3s/server/agent-token"
Write-Log "Agent token: $agentToken"
$env:AGENT_TOKEN = $agentToken

return $agentToken