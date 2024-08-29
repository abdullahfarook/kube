# sudo pwsh -Command "iex '& ([scriptblock]::Create((iwr https://raw.githubusercontent.com/abdullahfarook/kube/main/attach-disk.ps1))) -size 32G'"
param (
    [string]$size,
    [bool]$existing = $true,
    [string]$path = "/shared"
)
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
Write-Log "Starting disk attachment process..."
Write-Log "Parameters: size=$size, existing=$existing, path=$path"

# find disk which has same size
Write-Log "Searching for disk with size $size..."
$disk = lsblk -o NAME,SIZE,MOUNTPOINT | grep -i "sd" | Where-Object { $_ -match "$size" }
if ($null -eq $disk) {
    Write-Err "No disk found with size $size"
    return
}
$disk = $disk -split " " | Where-Object { $_ -ne "" }
$disk = $disk[0]
Write-Log "Disk found: $disk"

$partition = $disk + "1"
if (($existing -eq $false) -and (-not (lsblk -o NAME,SIZE,MOUNTPOINT | grep -i "$disk" | grep -i "part"))) {
    Write-Log "Partitioning and formatting disk $disk..."
    # check if disk is already partitioned then do not partition
    parted /dev/$disk --script mklabel gpt mkpart xfspart xfs 0% 100%
    mkfs.xfs /dev/$partition
    partprobe /dev/$partition
    Write-Log "Disk partitioned and formatted."
}

# mount the disk
if (-not (Test-Path $path)) {
    Write-Log "Creating mount point $path..."
    mkdir $path
}
Write-Log "Mounting /dev/$partition to $path..."
mount /dev/$partition $path

# add to fstab
Write-Log "Adding disk to /etc/fstab..."
$uuid = blkid | grep -i $partition | ForEach-Object { $_ -split " " } | Where-Object { $_ -match "UUID" }
$uuid = $uuid -split "=" | Where-Object { $_ -ne "" }
$uuid = $uuid[1]
# if UUID exists in fstab, does not add
if ($null -eq (grep -i $uuid /etc/fstab)) {
    Add-Content /etc/fstab "UUID=$uuid   $path   xfs   defaults,nofail   1   2"
    Write-Log "Disk added to /etc/fstab."
} else {
    Write-Log "Disk already exists in /etc/fstab."
}

# verify the disk
Write-Log "Verifying the disk..."
lsblk -o NAME,SIZE,MOUNTPOINT | grep -i "sd"
Write-Log "Disk attachment process completed."