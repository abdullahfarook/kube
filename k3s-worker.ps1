# sudo pwsh -Command "iex '& ([scriptblock]::Create((iwr https://raw.githubusercontent.com/abdullahfarook/kube/main/k3s-worker.ps1))) -server_ip <master node ip> -token <agent token> -attach_disk $true -size 32G"'"
param(
    [Parameter(Mandatory)][string]$server_ip,
    [Parameter(Mandatory)][string]$token,
    [string]$uninstall = $false,
    [bool]$attach_disk = $false,
    [string]$size,
    [string]$firewall_script = "https://raw.githubusercontent.com/abdullahfarook/kube/main/firewalls.ps1",
    [string]$attach_disk_script = "https://raw.githubusercontent.com/abdullahfarook/kube/main/attach-disk.ps1"
)

Write-Output "Starting k3s worker script..."

if ($uninstall -eq $true) {
    Write-Output "Uninstall flag is set to true. Checking for k3s-agent-uninstall.sh..."
    if (Test-Path /usr/local/bin/k3s-agent-uninstall.sh) {
        Write-Output "Uninstalling k3s worker..."
        /usr/local/bin/k3s-agent-uninstall.sh
    }
    else {
        Write-Error "k3s-agent-uninstall.sh not found"
    }
    exit 0
}

# join the k3s cluster using agent token and master node ip
$command = "curl -sfL https://get.k3s.io | K3S_URL=https://$server_ip:6443 K3S_TOKEN=$token sh -"
Write-Output "Joining the k3s cluster with command: $command"
iex $command

# verify the cluster
Write-Output "Verifying the cluster..."
kubectl get nodes

# open firewall ports
$command = "iex '& ([scriptblock]::Create((iwr $firewall_script)))'"
Write-Output "Opening firewall ports with command: $command"
iex $command

# attach disk
if ($attach_disk -eq $true) {
    $command = "iex '& ([scriptblock]::Create((iwr $attach_disk_script))) -size $size'"
    Write-Output "Attaching disk with command: $command"
    iex $command
}

Write-Output "k3s worker script completed."