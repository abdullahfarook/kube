# sudo pwsh -Command "iex '& ([scriptblock]::Create((iwr https://raw.githubusercontent.com/abdullahfarook/kube/main/docker.ps1)))'"
param(
    [bool]$uninstall = $false
)
function Write-Log {
    param (
        [string]$message,
        [string]$level = "INF"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    if ($level -eq "ERR") {
        Write-Host -NoNewline "[$timestamp "
        Write-Host -NoNewline "$level] " -ForegroundColor Red
        write-host  $message
    }else{
        Write-Host -NoNewline "[$timestamp "
        Write-Host -NoNewline "$level] " -ForegroundColor Green
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
    Write-Log "Uninstalling docker..."
    apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli docker-compose-plugin
    apt-get autoremove -y --purge docker-engine docker docker.io docker-ce docker-compose-plugin
    rm -rf /var/lib/docker /etc/docker
    rm /etc/apparmor.d/docker
    groupdel docker
    rm -rf /var/run/docker.sock
    rm -rf /var/lib/containerd
    rm -r ~/.docker
    Write-Log "Docker uninstalled successfully"
    exit 0
}
apt update
apt --yes --no-install-recommends install apt-transport-https ca-certificates curl software-properties-common
wget --quiet --output-document=- https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository --yes "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable"
apt update
apt --yes install docker-ce
systemctl enable docker
Write-Log "Docker installed successfully"