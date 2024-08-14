param(
    [string]$server_ip,
    [string]$token
)
# join the k3s cluster using agent token and master node ip
$command = "curl -sfL https://get.k3s.io | K3S_URL=https://$serverIp:6443 K3S_TOKEN=$token sh -"
echo $command
iex $command

# verify the cluster
kubectl get nodes

# open firewall ports
$script = $env:FIREWALL_SCRIPT
$command = "iex '& ([scriptblock]::Create((iwr $script)))'"
echo $command
iex $command
