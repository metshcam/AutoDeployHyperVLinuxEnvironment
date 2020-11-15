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
