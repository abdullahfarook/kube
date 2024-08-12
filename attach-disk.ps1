# wget -O - https://raw.githubusercontent.com/abdullahfarook/kube/main/attach-disk.ps1 | sudo pwsh -Command - "Invoke-AttachDisk -size 32"
function Invoke-AttachDisk {
    param(
        [int]$size,
        [bool]$existing = $true,
        [string]$path = "/shared"
    )

    # find disk which has same size
    $disk = lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sd" | Where-Object { $_ -match "$size" }
    if($null -eq $disk) {
        Write-Error "No disk found with size $size"
        return
    }
    $disk = $disk -split " " | Where-Object { $_ -ne "" }
    $disk = $disk[0]
    $partition = $disk + "1"

    if ($existing -eq $false) {
        # partition the disk
        parted /dev/$disk --script mklabel gpt mkpart xfspart xfs 0% 100%
        mkfs.xfs /dev/$partition
        partprobe /dev/$partition
    }

    # mount the disk
    mkdir $path
    mount /dev/$partition $path

    # add to fstab
    $uuid = blkid | grep -i $partition | ForEach-Object { $_ -split " " } | Where-Object { $_ -match "UUID" }
    $uuid = $uuid -split "=" | Where-Object { $_ -ne "" }
    $uuid = $uuid[1]
    Add-Content /etc/fstab "UUID=$uuid $path xfs defaults,nofail 1 2"

    # verify the disk
    lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sd"
}
