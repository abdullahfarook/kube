# wget -O - https://raw.githubusercontent.com/abdullahfarook/kube/main/powershell.sh | sudo bash 
# Download the PowerShell package file
wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.4/powershell_7.4.4-1.deb_amd64.deb

###################################
# Install the PowerShell package
dpkg -i powershell_7.4.4-1.deb_amd64.deb

# Resolve missing dependencies and finish the install (if necessary)
apt-get install -f

# Delete the downloaded package file
rm powershell_7.4.4-1.deb_amd64.deb

# Start PowerShell Preview
pwsh
