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
# sudo pwsh -Command "iex '& ([scriptblock]::Create((iwr https://raw.githubusercontent.com/abdullahfarook/kube/main/nerdctl.ps1)))'"
# download and extract containerd
Write-Log "Installing containerd..."
Invoke-WebRequest https://github.com/containerd/containerd/releases/download/v1.7.20/containerd-1.7.20-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-1.7.20-linux-amd64.tar.gz
Remove-Item containerd-1.7.20-linux-amd64.tar.gz

# download and extract cni plugins
Write-Log "Installing CNI plugins..."
mkdir -p -m 755 /opt/cni/bin
Invoke-WebRequest https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.5.1.tgz
Remove-Item cni-plugins-linux-amd64-v1.5.1.tgz

# download ans install runc
Write-Log "Installing runc..."
Invoke-WebRequest https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc
Remove-Item runc.amd64

# configure containerd
Write-Log "Configuring containerd..."
mkdir -m 755 /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
Invoke-WebRequest -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service

# start containerd
systemctl daemon-reload
systemctl enable --now containerd
systemctl status containerd

# download and install nerdctl
Write-Log "Installing nerdctl..."
Invoke-WebRequest https://github.com/containerd/nerdctl/releases/download/v1.7.6/nerdctl-1.7.6-linux-amd64.tar.gz
tar -zxf  nerdctl-1.7.6-linux-amd64.tar.gz nerdctl
Move-Item nerdctl /usr/local/bin
Remove-Item nerdctl-1.7.6-linux-amd64.tar.gz
nerdctl --version

# download and install iptables
Write-Log "Installing iptables..."
apt update
apt install -y iptables