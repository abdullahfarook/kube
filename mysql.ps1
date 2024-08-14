Param(
    [string]$mysql_root_password,
    [string]$mysql_path = "/shared/mysql",
    [string]$mysql_version = "8.0.39",
    [string]$join_network = "shared_network",
    [bool]$existing = $true,
    [string]$new_user = "user",
    [string]$new_password = "Pass"
)

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
$file = "mysql-compose.yml"
$compose | Out-File -FilePath $file -Force
nerdctl compose -f $file up -d

# join network
if ($null -ne $joinNetwork) {
  nerdctl network create $joinNetwork
  nerdctl network connect $joinNetwork mysql
}


# create user and database
if ($existing -eq $false) { 
$command = @"
CREATE USER '$newUser'@'%' IDENTIFIED WITH mysql_native_password BY '$newPassword';
GRANT ALL PRIVILEGES ON *.* TO '$newUser'@'%';
FLUSH PRIVILEGES;
"@
nerdctl exec mysql mysql -u root -p$mysqlRootPassword -e $command

}