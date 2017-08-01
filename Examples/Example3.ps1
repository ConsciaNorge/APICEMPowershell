Clear-Host

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\APICEMPowerShell.psd1') -Force

# $user = 'admin'
# $pass = 'Minions12345'
# $apicEMHostIP = '10.100.11.17'

$user = 'darren'
$pass = 'Minions12345'
#$apicEMHostIP = '172.16.96.68'
$apicEMHostIP = '172.16.138.12'

Get-APICEMServiceTicket -ApicHost $apicEMHostIP -Username $user -Password $pass -IgnoreBadCerts

#exit
#
##$unclaimedDevice = (Get-APICEMNetworkPlugAndPlayDevices -Unclaimed)[0]
##
##$images = Get-APICEMNetworkPlugAndPlayImages
##
###$images.platform | Out-Host
###$images.platform.productId | Out-Host
###
###'-----' | Out-Host
##$unclaimedDevice.platformId | Out-Host
##
##$defaultImage = Get-APICEMNetworkPlugAndPlayImageDefault -ProductID $unclaimedDevice.platformId
##
##$projectJob = New-APICEMNetworkPlugAndPlayProject -Name 'DAVE-Bear'
##$projectTaskStatus = Wait-APICEMTaskEnded -TaskID $projectJob.taskId
##
##$project = Get-APICEMNetworkPlugAndPlayProject @session -Name 'Buttnutt'
#
## $newLocationJob = New-APICEMInventoryLocation -Name 'Minionville' -Description 'Where minions really party'
## $newLocationStatus = Wait-APICEMTaskEnded -TaskID $newLocationJob.taskId
#
##$newTagJob = New-APICEMInventoryTag -Name 'FuzzyBunny'
##$newTagStatus = Wait-APICEMTaskEnded -TaskID $newTagJob.taskId
##$tagJobResult = ConvertFrom-JSON $newTagStatus.progress
#
#$tag = Get-APICEMInventoryTag -Name 'FuzzyBunny'
#
#$newLocationJob = New-APICEMInventoryLocation -Name 'Happyville' -Description 'Where sad people go to find the meaning to life' -tag $tag.id
#$newLocationStatus = Wait-APICEMTaskEnded -TaskID $newLocationJob.taskId
#
#$minionVille = Get-APICEMInventoryLocation -Name 'Minionville'
#$happyVille= Get-APICEMInventoryLocation -Name 'Happyville'
#
#$deleteHappyvilleJob = Remove-APICEMInventoryLocation -LocationID $happyVille.id
#$deleteHappyvilleStatus = Wait-APICEMTaskEnded -TaskID $deleteHappyvilleJob.taskId
#
#$locations = Get-APICEMInventoryLocations
#
#$devices = Get-APICEMNetworkDevice
#$testDevice = $devices[0]
#
#$setRoleJob = Set-APICEMNetworkDeviceRole -DeviceId $testDevice.id 
#$setRoleStatus = Wait-APICEMTaskEnded -TaskID $setRoleJob.taskId
#
#$tags = Get-APICEMInventoryTags
#
#$associateTagJob = New-APICEMInventoryTagAssociation -Name 'FuzzyBunny' -NetworkDeviceId $testDevice.id
#$associateTagStatus = Wait-APICEMTaskEnded -TaskID $associateTagJob.taskId
#
#$tagAssociations = Get-APICEMInventoryTagAssociations -Name 'FuzzyBunny' -NetworkDevices
#$tagAssoc = $tagAssociations[0]
#
#$removeAssocTask = Remove-APICEMInventoryTagAssociation -TagID $tagAssoc.id -NetworkDeviceID $tagAssoc.resourceID


# $x = Get-APICEMNetworkPlugAndPlayDevice -SerialNumber 'FOC2118U0BX' 

#$dev = Get-APICEMNetworkDevice -SerialNumber 'FOC2026X04Z' -ErrorAction SilentlyContinue
#$loc = Get-APICEMInventoryLocation -Name 'Squeeky'
#$job = Set-APICEMNetworkDeviceLocation -DeviceId $dev.id -LocationId $loc.id
#Wait-APICEMTaskEnded -TaskID $job.TaskID


# collectionStatus          : In Progress