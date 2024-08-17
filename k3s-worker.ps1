param(
    [string]$server_ip,
    [string]$token,
    [string]$uninstall = $false
)
if ($uninstall -eq $true) {
    if (Test-Path /usr/local/bin/k3s-agent-uninstall.sh) {
        echo "Uninstalling k3s worker"
        /usr/local/bin/k3s-agent-uninstall.sh
    }
    else {
        Write-Error "k3s-agent-uninstall.sh not found"
    }
    exit 0
}
# join the k3s cluster using agent token and master node ip
$command = "curl -sfL https://get.k3s.io | K3S_URL=https://$server_ip:6443 K3S_TOKEN=$token sh -"
echo $command
iex $command

# verify the cluster
kubectl get nodes

# open firewall ports
$script = $env:FIREWALL_SCRIPT
$command = "iex '& ([scriptblock]::Create((iwr $script)))'"
echo $command
iex $command
