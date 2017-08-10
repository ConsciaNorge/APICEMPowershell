<#
This code is written and maintained by Darren R. Starr from Conscia Norway AS.

License :

Copyright (c) 2017 Conscia Norway AS

Permission is hereby granted, free of charge, to any person obtaining a 
copy of this software and associated documentation files (the "Software"), 
to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software 
is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

Add-Type -TypeDefinition (Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/CSharp/APICEMException.cs') -Raw)

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/RESTAPIHelpers.ps1')

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/File/FileService.ps1')
Export-ModuleMember -Function Get-APICEMFile
Export-ModuleMember -Function Get-APICEMFileNamespace

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/Inventory/DeviceCredential.ps1')
Export-ModuleMember -Function Get-APICEMInventoryGlobalCredential

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/Inventory/Discovery.ps1')
Export-ModuleMember -Function Get-APICEMInventoryDiscovery
Export-ModuleMember -Function New-APICEMInventoryDiscovery
Export-ModuleMember -Function Set-APICEMInventoryDiscovery
Export-ModuleMember -Function Get-APICEMInventoryDiscoveryCount
Export-ModuleMember -Function Get-APICEMInventoryDiscoveryRange
Export-ModuleMember -Function Remove-APICEMInventoryDiscovery

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/Inventory/Location.ps1')
Export-ModuleMember -Function Get-APICEMInventoryLocation
Export-ModuleMember -Function New-APICEMInventoryLocation
Export-ModuleMember -Function Remove-APICEMInventoryLocation

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/Inventory/NetworkDevice.ps1')
Export-ModuleMember -Function Get-APICEMNetworkDevice
Export-ModuleMember -Function Get-APICEMNetworkDeviceLocation
Export-ModuleMember -Function Get-APICEMNetworkDeviceModule
Export-ModuleMember -Function Get-APICEMNetworkDeviceManagementInfo
Export-ModuleMember -Function Remove-APICEMNetworkDevice
Export-ModuleMember -Function Set-APICEMNetworkDeviceLocation
Export-ModuleMember -Function Set-APICEMNetworkDeviceRole

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/Inventory/NetworkDeviceConfig.ps1')
Export-ModuleMember -Function Get-APICEMNetworkDeviceConfig

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/Inventory/Tag.ps1')
Export-ModuleMember -Function Get-APICEMInventoryTag
Export-ModuleMember -Function Get-APICEMInventoryTags
Export-ModuleMember -Function New-APICEMInventoryTag
Export-ModuleMember -Function New-APICEMInventoryTagAssociation
Export-ModuleMember -Function Remove-APICEMInventoryTag
Export-ModuleMember -Function Remove-APICEMInventoryTagAssociation

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/NetworkPlugAndPlay/PnpDevice.ps1')
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayDevice
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayDeviceHistory

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/NetworkPlugAndPlay/PnpFile.ps1')
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayFileTemplate
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayImageDefault
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayImages
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayPlatformFile

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/NetworkPlugAndPlay/PnpProject.ps1')
Export-ModuleMember -Function Add-APICEMNetworkPlugAndPlayProjectDevice
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayProject
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayProjectDevice
Export-ModuleMember -Function New-APICEMNetworkPlugAndPlayProject
Export-ModuleMember -Function Remove-APICEMNetworkPlugAndPlayProjectDevice

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/NetworkPlugAndPlay/Template.ps1')
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayTemplate

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/NetworkPlugAndPlay/TemplateConfig.ps1')
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayTemplateConfig
Export-ModuleMember -Function Set-APICEMNetworkPlugAndPlayTemplateProperties

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/NetworkPlugAndPlay/TemplateConfig.ps1')
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayTemplateRenderer
Export-ModuleMember -Function Publish-APICEMNetworkPlugAndPlayFileTemplate

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/RoleBasedAccessControl/Ticket.ps1')
Export-ModuleMember -Function Remove-APICEMServiceTicket
Export-ModuleMember -Function Get-APICEMServiceTicket

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/ApicEmApi/Task/Task.ps1')
Export-ModuleMember -Function Get-APICEMTask

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/Add-APICEMClaimedDevice.ps1')
Export-ModuleMember -Function Add-APICEMClaimedDevice

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/Get-APICEMInventoryDiscoveryByIP.ps1')
Export-ModuleMember -Function Get-APICEMInventoryDiscoveryByIP

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/New-DeviceDiscoverySetting.ps1')
Export-ModuleMember -Function New-DeviceDiscoverySetting

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/Wait-APICEMTaskEnded.ps1')
Export-ModuleMember -Function Wait-APICEMTaskEnded

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/Wait-APICEMDiscoveryComplete.ps1')
Export-ModuleMember -Function Wait-APICEMDiscoveryComplete

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/Wait-APICEMDiscoveryCompletesWithADevice.ps1')
Export-ModuleMember -Function Wait-APICEMDiscoveryCompletesWithADevice

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/Add-APICEMDeviceToInventory.ps1')
Export-ModuleMember -Function Add-APICEMDeviceToInventory

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/Wait-APICEMDeviceProvisioned.ps1')
Export-ModuleMember -Function Wait-APICEMDeviceProvisioned

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/Wait-APICEMDeviceInInventory.ps1')
Export-ModuleMember -Function Wait-APICEMDeviceInInventory

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/Get-APICEMPnPDevicesByNetwork.ps1')
Export-ModuleMember -Function Get-APICEMPnPDevicesByNetwork
Export-ModuleMember -Function Test-IsInNetwork
Export-ModuleMember -Function Get-NetworkPrefixParts

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/VelocityParser.ps1')
Export-ModuleMember -Function Get-VelocityDocumentInformation

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/Get-APICEMNeighborInformationFromTopologyInfo.ps1')
Export-ModuleMember -Function Get-APICEMNeighborInformationFromTopologyInfo
Export-ModuleMember -Function Get-CiscoInterfaceShortName

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/Get-APICEMNetworkTopologyFromPnPDevices.ps1')
Export-ModuleMember -Function Get-APICEMNetworkTopologyFromPnPDevices

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/Get-APICEMPnPNetworkDiagram.ps1')
Export-ModuleMember -Function Get-APICEMPnPNetworkDiagram

. (Join-Path -Path $PSScriptRoot -ChildPath 'Sources/Utility/Get-CiscoInterfaceSortingName.ps1')
Export-ModuleMember -Function Get-CiscoInterfaceSortingName



