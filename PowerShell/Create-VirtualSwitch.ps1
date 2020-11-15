####
## Function to gather information about HyperV environment
####

## Path where HyperV virtual network environment information is to be provided
## JSON file on github
##
$hv_switchinfo_json = 'https://raw.githubusercontent.com/metshcam/AutoDeployHyperVLinuxEnvironment/main/JSON/hv_ps_switchparameters.json'
$hv_switchinfo = Invoke-WebRequest -Uri $hv_switchinfo_json
$hv_switchinfo.Content

## Build argument array for the virtual network creation argument values
##
$hv_switchargs = $hv_switchinfo.Content | ConvertFrom-Json

## HyperV host (-ComputerName)
##
$hv_hostname = "hyperv-host"

## Validate existing network environment for the host
## Do not display the Default Switch
##
$hv_switchlist = Get-VMSwitch | Where-Object {$_.Name -ne "Default Switch"}

## Check and display count for existing virtual networks
## If there aren't any, move on.
##
if ($hv_switchlist.Count -eq 0) {
  Write-Host "
  You don't currently have any virtual network
  environments.  Creating your new virtual network.
  "
}

## If there are about none, display and move on.
##
if ($hv_switchlist.Count -gt 0) {
  Write-Host "
  Your environment currently has $hv_switchlist.Count networks.
  We will check and see if there will be a conflict using $hv_switchinfo.
  "
}

$hv_vmswitch_interfacename
