####
## Function to gather information about HyperV environment
####

## HyperV host ComputerName variable (DNS if done remotely)
##
$hv_hostname = "hyperv-host"

## Path where HyperV virtual network environment information is to be provided
##
$hv_switchinfo_json = 'https://raw.githubusercontent.com/metshcam/AutoDeployHyperVLinuxEnvironment/main/JSON/virtualnetwork_private.json'
$hv_switchinfo = Invoke-WebRequest -Uri $hv_switchinfo_json

## Validate existing network environment for the host
##
$hv_switchlist = Get-VMSwitch | Where-Object {$_.Name -ne "Default Switch"}

if ($hv_switchlist.Count -eq 0) {
  Write-Host "
  You don't currently have any virtual network
  environments to worry about.  Creating your 
  new virtual network without worry.
"
}

if ($hv_switchlist.Count -gt 0) {
  Write-Host "
  Your environment currently has $hv_switchlist.Count networks.
  We will check and see if there will be a conflict using $hv_switchinfo.
  "
}
