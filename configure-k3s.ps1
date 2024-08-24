# sudo pwsh -Command "iex '& ([scriptblock]::Create((iwr https://raw.githubusercontent.com/abdullahfarook/kube/main/configure-k3s.ps1).Content))'" 
param (
    [bool]$disable_traefik = $true,
    [bool]$taint_server = $true
)