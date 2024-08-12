# Install K3s with taint
# sudo curl -sfL https://get.k3s.io | \
# INSTALL_K3S_EXEC="--write-kubeconfig-mode 664 --tls-san <vm ip>"  \
# INSTALL_K3S_CHANNEL=stable \sh -s - server \
# --node-taint CriticalAddonsOnly=true:NoExecute --disable traefik --token <token> \
# --datastore-endpoint="mysql://<user>:<password>@tcp(<mysql ip>:3306)/k3s"

# rewrite K3s without taint in powershell script
param (
    [string]$ip,
    [string]$mysql,
    [string]$user,
    [string]$password,
    [string]$token?
)
# optional token
curl -sfL https://get.k3s.io | `
INSTALL_K3S_EXEC="--write-kubeconfig-mode 664 --tls-san $ip"  `
INSTALL_K3S_CHANNEL=stable `
sh -s - server `
--disable traefik if ($null -ne $token) { "--token $token " } `
--datastore-endpoint="mysql://$(user):$password@tcp($mysql:3306)/k3s"

.\firewalls.ps1



