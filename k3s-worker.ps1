# # copy the token from k3s server at path
# sudo cat /var/lib/rancher/k3s/server/agent-token

# # open ports 8472, 10250, 51820, 51821, 5001, 6443 on master node as well as every other worker node
# udo firewall-cmd --zone=public --add-port=8472/udp --permanent && \
# sudo firewall-cmd --zone=public --add-port=10250/tcp --permanent  && \
# sudo firewall-cmd --zone=public --add-port=51820/udp --permanent && \
# sudo firewall-cmd --zone=public --add-port=51821/udp --permanent && \
# sudo firewall-cmd --zone=public --add-port=5001/tcp --permanent  && \
# sudo firewall-cmd --zone=public --add-port=6443/tcp --permanent && \
# sudo firewall-cmd --reload

# # join the k3s cluster using agent token and master node ip
# sudo curl -sfL https://get.k3s.io | K3S_URL=https://<master node ip>:6443 K3S_TOKEN="<agent token>" sh -

param(
    [string]$serverIp,
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
