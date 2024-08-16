# sudo pwsh -Command "iex '& ([scriptblock]::Create((iwr https://raw.githubusercontent.com/abdullahfarook/kube/main/mysql.ps1))) -mysql_root_password 'password' "
Param(
    [string]$mysql_root_password,
    [string]$mysql_path = "/shared/mysql",
    [string]$mysql_version = "8.0.39",
    [string]$join_network,
    [bool]$existing = $true,
    [string]$new_user,
    [string]$new_password
)

$compose = @"
mysql:
    image: mysql/mysql-server:${mysqlVersion}
    container_name: mysql
    volumes:
      - ${mysqlPath}/data:/var/lib/mysql
      - ${mysqlPath}/conf.d:/etc/mysql/conf.d
    restart: always
    ports:
      - 3306:3306
    environment:
      MYSQL_ROOT_PASSWORD: ${mysqlRootPassword}
"@
$file = "mysql-compose.yml"
$compose | Out-File -FilePath $file -Force

try {
    nerdctl compose -f $file up -d
} catch {
    Write-Error "Failed to start MySQL container:`n$_"
    exit 1
}

# join network
if ($null -ne $joinNetwork) {
  nerdctl network create $joinNetwork
  nerdctl network connect $joinNetwork mysql
}


# create user and database
if ($existing -eq $false) { 
  #check for arguments new_user and new_password
  if ($null -eq $newUser -or $null -eq $newPassword) {
    Write-Error "new_user and new_password must be provided if provided argument 'existing' is false"
    exit 1
  }
$command = @"
CREATE USER '$newUser'@'%' IDENTIFIED WITH mysql_native_password BY '$newPassword';
GRANT ALL PRIVILEGES ON *.* TO '$newUser'@'%';
FLUSH PRIVILEGES;
"@
nerdctl exec mysql mysql -u root -p$mysqlRootPassword -e $command

}