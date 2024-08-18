param (
    [string]$size,
    [bool]$existing = $true,
    [string]$path = "/shared"
)

Write-Output "Starting disk attachment process..."
Write-Output "Parameters: size=$size, existing=$existing, path=$path"

# find disk which has same size
Write-Output "Searching for disk with size $size..."
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
    Write-Output "Partitioning and formatting disk $disk..."
    # check if disk is already partitioned then do not partition
    parted /dev/$disk --script mklabel gpt mkpart xfspart xfs 0% 100%
    mkfs.xfs /dev/$partition
    partprobe /dev/$partition
    Write-Output "Disk partitioned and formatted."
}

# mount the disk
if (-not (Test-Path $path)) {
    Write-Output "Creating mount point $path..."
    mkdir $path
}
Write-Output "Mounting /dev/$partition to $path..."
mount /dev/$partition $path

# add to fstab
Write-Output "Adding disk to /etc/fstab..."
$uuid = blkid | grep -i $partition | ForEach-Object { $_ -split " " } | Where-Object { $_ -match "UUID" }
$uuid = $uuid -split "=" | Where-Object { $_ -ne "" }
$uuid = $uuid[1]
# if UUID exists in fstab, does not add
if ($null -eq (grep -i $uuid /etc/fstab)) {
    Add-Content /etc/fstab "UUID=$uuid   $path   xfs   defaults,nofail   1   2"
    Write-Output "Disk added to /etc/fstab."
} else {
    Write-Output "Disk already exists in /etc/fstab."
}

# verify the disk
Write-Output "Verifying the disk..."
lsblk -o NAME,SIZE,MOUNTPOINT | grep -i "sd"
Write-Output "Disk attachment process completed."