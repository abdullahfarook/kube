# sudo pwsh -Command "iex '& ([scriptblock]::Create((iwr https://raw.githubusercontent.com/abdullahfarook/kube/main/k3s-worker.ps1))) -server_ip <master node ip> -token <agent token> -attach_disk $true -size 32G"'"
param(
    [Parameter(Mandatory)][string]$server_ip,
    [Parameter(Mandatory)][string]$token,
    [bool]$uninstall = $false,
    [bool]$attach_disk = $false,
    [string]$size,
    [string]$firewall_script = "https://raw.githubusercontent.com/abdullahfarook/kube/main/firewalls.ps1",
    [string]$attach_disk_script = "https://raw.githubusercontent.com/abdullahfarook/kube/main/attach-disk.ps1"
)
function Write-Log {
    param (
        [string]$message,
        [string]$level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if ($level -eq "ERR") {
        Write-Err "$timestamp [$level] $message"
    }else{
        Write-Output "$timestamp [$level] $message"
    }
}
function Write-Err {
    param (
        [string]$message
    )
    Write-Log $message "ERR"
    exit 1
}
Write-Log "Starting k3s worker script..."

if ($uninstall -eq $true) {
    Write-Log "Uninstall flag is set to true. Checking for k3s-agent-uninstall.sh..."
    if (Test-Path /usr/local/bin/k3s-agent-uninstall.sh) {
        Write-Log "Uninstalling k3s worker..."
        /usr/local/bin/k3s-agent-uninstall.sh
    }
    else {
        Write-Err "k3s-agent-uninstall.sh not found"
    }
    exit 0
}

# join the k3s cluster using agent token and master node ip
# Start-Process -NoNewWindow -FilePath "sudo" -ArgumentList "systemctl daemon-reload" -Wait
# Write-Log "Systemd daemon reloaded successfully"
# $command = "curl -sfL https://get.k3s.io | K3S_URL=https://$($server_ip):6443 K3S_TOKEN=$token sh -"
$command = "curl -sfL https://get.k3s.io | K3S_URL=https://$($server_ip):6443 K3S_TOKEN=$token sh -"
Start-Process -NoNewWindow -FilePath "sudo" -ArgumentList -FilePat -Wait
if (-not $?) {
    Write-Err "Failed to join the cluster: $_"
    exit 1
}
Write-Log "Joined the cluster successfully."

# verify the cluster
Write-Log "Verifying the cluster..."
kubectl get nodes
if (-not $?) {
    Write-Err "Failed to verify the cluster: $_"
    exit 1
}

# open firewall ports
# $command = "iex '& ([scriptblock]::Create((iwr $firewall_script)))'"
# Write-Log "Opening firewall ports with command: $command"
# iex $command

# # attach disk
# if ($attach_disk -eq $true) {
#     $command = "iex '& ([scriptblock]::Create((iwr $attach_disk_script))) -size $size'"
#     Write-Log "Attaching disk with command: $command"
#     iex $command
# }

$command = "'& ([scriptblock]::Create((iwr $firewall_script)))'"
Start-Process -NoNewWindow -FilePath "sudo" -ArgumentList "pwsh -Command $command" -Wait
if (-not $?) {
    Write-Err "Failed to open firewall ports: $_"
}else[
    Write-Log "Firewall ports opened successfully."
]

if ($attach_disk -eq $true) {
    $command = "'& ([scriptblock]::Create((iwr $attach_disk_script))) -size $size'"
    Start-Process -NoNewWindow -FilePath "sudo" -ArgumentList "pwsh -Command $command" -Wait
    if (-not $?) {
        Write-Err "Failed to attach disk: $_"
    }else{
        Write-Log "Disk attached successfully."
    }
}

Write-Log "k3s worker script completed."