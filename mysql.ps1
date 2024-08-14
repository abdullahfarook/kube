Param(
    [string]$mysqlRootPassword,
    [string]$mysqlPath = "/shared/mysql",
    [string]$mysqlVersion = "8.0.39",
    [string]$joinNetwork?,
    [bool]$existing = $true,
    [string]$newUser = "user",
    [string]$newPassword = "Pass"
)
# create network
if ($null -ne $joinNetwork) {
    nerdctl network create $joinNetwork
}

$compose = @"
version: '3'
services:
  mysql:
    image: mysql/mysql-server:$mysqlVersion
    container_name: mysql
    volumes:
      - $mysqlPath/data:/var/lib/mysql
      - $mysqlPath/conf.d:/etc/mysql/conf.d
    restart: always
    ports:
      - 3306:3306
    environment:
      MYSQL_ROOT_PASSWORD: $mysqlRootPassword
"@
$compose | Out-File -FilePath "mysql-compose.yml" -Force
containerd compose -f "mysql-compose.yml" up -d

# join network
if ($null -ne $joinNetwork) {
    nerdctl network connect $joinNetwork mysql
}


# create user and database
if ($existing -eq $false) { 
$command = @"
CREATE USER '$newUser'@'%' IDENTIFIED WITH mysql_native_password BY '$newPassword';
GRANT ALL PRIVILEGES ON *.* TO '$newUser'@'%';
FLUSH PRIVILEGES;
"@
containerd exec mysql mysql -u root -p$mysqlRootPassword -e $command

}