# sudo pwsh -Command "iex '& ([scriptblock]::Create((iwr https://raw.githubusercontent.com/abdullahfarook/kube/main/k3s-server.ps1).Content)) -cluster_ip <cluster_ip> -mysql_ip <mysql_ip> -mysql_user <mysql_user> -mysql_password <mysql_password> -token <token>'" 
# sudo curl -sfL https://get.k3s.io | \
# INSTALL_K3S_EXEC="--write-kubeconfig-mode 664 --tls-san <vm ip>"  \
# INSTALL_K3S_CHANNEL=stable \sh -s - server \
# --node-taint CriticalAddonsOnly=true:NoExecute --disable traefik --token <token> \
# --datastore-endpoint="mysql://<user>:<password>@tcp(<mysql ip>:3306)/k3s"
param (
    [string]$cluster_ip,
    [string]$mysql_ip = "localhost",
    [string]$mysql_port = "3306",
    [string]$mysql_user,
    [string]$mysql_password,
    [string]$token?,
    [string]$channel = "stable",
    [string]$version = "latest",
    [bool]$disable_traefik = $true,
    [bool]$taint_server = $true
)
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
$command += " --datastore-endpoint='mysql://${mysqlUser}:$mysqlPassword@tcp(${mysqlIp}:${mysql_port})/k3s'"

Write-Host "Executing command: $command"
iex $command
if (-not $?) {
    Write-Error "Failed to install k3s server: $_"
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
echo "Agent token: $agentToken"
$env:AGENT_TOKEN = $agentToken

return $agentToken