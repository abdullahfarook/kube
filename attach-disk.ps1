# sudo pwsh -Command "iex '& ([scriptblock]::Create((iwr https://raw.githubusercontent.com/abdullahfarook/kube/main/attach-disk.ps1))) -size 32G'"
param (
    [string]$size,
    [bool]$existing = $true,
    [string]$path = "/shared"
)

# find disk which has same size
$disk = lsblk -o NAME,SIZE,MOUNTPOINT | grep -i "sd" | Where-Object { $_ -match "$size" }
if ($null -eq $disk) {
    Write-Error "No disk found with size $size"
    return
}
$disk = $disk -split " " | Where-Object { $_ -ne "" }
$disk = $disk[0]
Write-Output "Disk found: $disk"
$partition = $disk + "1"
if (($existing -eq $false) -and (-not (lsblk -o NAME,SIZE,MOUNTPOINT | grep -i "$disk" | grep -i "part"))) {
    # check if disk is already partitioned then do not partition
    parted /dev/$disk --script mklabel gpt mkpart xfspart xfs 0% 100%
    mkfs.xfs /dev/$partition
    partprobe /dev/$partition
}
# mount the disk
if (-not (Test-Path $path)) {
    mkdir $path
}
mount /dev/$partition $path
# add to fstab
$uuid = blkid | grep -i $partition | ForEach-Object { $_ -split " " } | Where-Object { $_ -match "UUID" }
$uuid = $uuid -split "=" | Where-Object { $_ -ne "" }
$uuid = $uuid[1]
# if UUID exists in fstab, does not add
if ($null -eq (grep -i $uuid /etc/fstab)) {
    Add-Content /etc/fstab "UUID=$uuid   $path   xfs   defaults,nofail   1   2"
}
# verify the disk
lsblk -o NAME,SIZE,MOUNTPOINT | grep -i "sd"
