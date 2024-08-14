# sudo curl -sfL https://get.k3s.io | \
# INSTALL_K3S_EXEC="--write-kubeconfig-mode 664 --tls-san <vm ip>"  \
# INSTALL_K3S_CHANNEL=stable \sh -s - server \
# --node-taint CriticalAddonsOnly=true:NoExecute --disable traefik --token <token> \
# --datastore-endpoint="mysql://<user>:<password>@tcp(<mysql ip>:3306)/k3s"

param (
    [string]$clusterIp,
    [string]$mysqlIp,
    [string]$mysqlUser,
    [string]$mysqlPassword,
    [string]$token?,
    [string]$channel = "stable",
    [string]$version = "latest",
    [bool]$disableTraefik = $true,
    [bool]$taintServer = $true
)
# optional token
$command = "curl -sfL https://get.k3s.io |"
$command += " INSTALL_K3S_EXEC='--write-kubeconfig-mode 664 --tls-san $clusterIp'"
$command += " INSTALL_K3S_CHANNEL=$channel sh -s - server"
if ($taintServer -eq $true) {
    $command += " --node-taint CriticalAddonsOnly=true:NoExecute"
}
if ($disableTraefik -eq $true) {
    $command += " --disable traefik"
}
if ($null -ne $token) {
    $command += " --token $token"
}
$command += " --datastore-endpoint='mysql://${mysqlUser}:$mysqlPassword@tcp($mysqlIp:3306)/k3s'"
$command += " --tls-san $clusterIp"
echo $command
iex $command
 
# copy the token from k3s server at path and set it as environment variable named AGENT_TOKEN
#/var/lib/rancher/k3s/server/agent-token
$agentToken = cat -Path "/var/lib/rancher/k3s/server/agent-token"
$env:AGENT_TOKEN = $agentToken
return $agentToken