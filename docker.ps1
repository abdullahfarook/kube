# sudo pwsh -Command "iex '& ([scriptblock]::Create((iwr https://raw.githubusercontent.com/abdullahfarook/kube/main/docker.ps1)))'"
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
apt update
apt --yes --no-install-recommends install apt-transport-https ca-certificates curl software-properties-common
wget --quiet --output-document=- https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository --yes "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable"
apt update
apt --yes install docker-ce
systemctl enable docker
Write-Log "Docker installed successfully"