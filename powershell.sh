
# Download the PowerShell package file
wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.4/powershell_7.4.4-1.deb_amd64.deb

###################################
# Install the PowerShell package
sudo dpkg -i powershell_7.4.4-1.deb_amd64.deb

# Delete the downloaded package file
rm powershell_7.4.4-1.deb_amd64.deb

# Start PowerShell Preview
pwsh
