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
# Update package list
apt update

# Install ufw
sudo apt-get --yes install ufw

# Allow specific ports
Write-Log "Allowing ports 8472, 10250, 51820, 51821, 5001, 6443, 80"
sudo ufw allow 8472/udp
sudo ufw allow 10250/tcp
sudo ufw allow 51820/udp
sudo ufw allow 51821/udp
sudo ufw allow 5001/tcp
sudo ufw allow 6443/tcp
sudo ufw allow 80/tcp
sudo ufw allow 80/udp

# Enable ufw
sudo ufw --force enable

Write-Log "UFW configured successfully"