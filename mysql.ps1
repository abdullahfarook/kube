# sudo pwsh -Command "iex '& ([scriptblock]::Create((iwr https://raw.githubusercontent.com/abdullahfarook/kube/main/mysql.ps1))) -mysql_root_password <password> '"
Param(
    [Parameter(Mandatory)][string]$mysql_root_password,
    [string]$mysql_path = "/shared/mysql",
    [string]$mysql_version = "latest",
    [string]$join_network,
    [bool]$existing = $true,
    [string]$new_user,
    [string]$new_password
)

Write-Host "Starting MySQL setup script..."
$compose = @"
version: '3'
services:
  mysql:
    image: mysql/mysql-server:$mysql_version
    container_name: mysql
    command: --default-authentication-plugin=mysql_native_password
    volumes:
      - $mysql_path/data:/var/lib/mysql
      - $mysql_path/conf.d:/etc/mysql/conf.d
    restart: always
    ports:
      - 3306:3306
    environment:
      MYSQL_ROOT_PASSWORD: '$mysql_root_password'
"@
$file = "mysql-compose.yml"
# remove existing file
if (Test-Path $file) {
    Remove-Item $file
}
$compose | Out-File -FilePath $file -Force
Write-Host "Docker Compose file created at $file"

try {
    Write-Host "Starting MySQL container..."
    nerdctl compose -f $file up -d
    Write-Host "MySQL container started successfully."
}
catch {
    Write-Error "Failed to start MySQL container:`n$_"
    exit 1
}
rm $file

# join network
if ($null -ne $joinNetwork) {
    Write-Host "Creating and connecting to network $joinNetwork..."
    nerdctl network create $joinNetwork
    nerdctl network connect $joinNetwork mysql
    Write-Host "Network $joinNetwork created and connected successfully."
}

# create user and database
if ($existing -eq $false) { 
    # check for arguments new_user and new_password
    if ($null -eq $new_user -or $null -eq $new_password) {
        Write-Error "new_user and new_password must be provided if provided argument 'existing' is false"
        exit 1
    }
    Write-Host "Creating new MySQL user $new_user..."
    $query = "CREATE USER '$new_user'@'%' IDENTIFIED WITH mysql_native_password BY '$new_password';GRANT ALL PRIVILEGES ON *.* TO '$new_user'@'%';FLUSH PRIVILEGES;"
    $command = "nerdctl exec mysql mysql -u root -p$mysql_root_password -e `"$query`""
# fill content of file in bash and execute
    $file = "mysql-new-user.sh"
    if(Test-Path $file) {
        Remove-Item $file
    }
    $command | Out-File -FilePath $file -Force
    Write-Host "Executing MySQL command..."
    sudo bash $file
    if($_) {
        Write-Error "Failed to create new MySQL user:`n$_"
        exit 1
    }
}

Write-Host "MySQL setup script completed."