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

$hv_vmswitch_interfacename
