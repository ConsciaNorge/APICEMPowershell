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

. (Join-Path -Path $PSScriptRoot -ChildPath 'HelperScripts/APICEMCommon.ps1')

Export-ModuleMember -Function Remove-APICEMServiceTicket
Export-ModuleMember -Function Get-APICEMServiceTicket

. (Join-Path -Path $PSScriptRoot -ChildPath 'APICEMFile/APICEMFile.ps1')

Export-ModuleMember -Function Get-APICEMFile
Export-ModuleMember -Function Get-APICEMFileNamespace
Export-ModuleMember -Function Get-APICEMFileNamespaces

. (Join-Path -Path $PSScriptRoot -ChildPath 'APICEMNetworkInventory/APICEMInventoryNetworkDevices.ps1')

Export-ModuleMember -Function Get-APICEMNetworkDevice
Export-ModuleMember -Function Get-APICEMNetworkDevices
Export-ModuleMember -Function Get-APICEMNetworkDeviceConfig
Export-ModuleMember -Function Get-APICEMNetworkDeviceLocation
Export-ModuleMember -Function Get-APICEMNetworkDeviceModules
Export-ModuleMember -Function Get-APICEMNetworkDeviceManagementInfo
Export-ModuleMember -Function Set-APICEMNetworkDeviceRole

. (Join-Path -Path $PSScriptRoot -ChildPath 'APICEMNetworkInventory/APICEMInventoryLocation.ps1')
Export-ModuleMember -Function Get-APICEMInventoryLocation
Export-ModuleMember -Function Get-APICEMInventoryLocations
Export-ModuleMember -Function New-APICEMInventoryLocation
Export-ModuleMember -Function Remove-APICEMInventoryLocation

. (Join-Path -Path $PSScriptRoot -ChildPath 'APICEMNetworkInventory/APICEMInventoryLocation.ps1')
Export-ModuleMember -Function Get-APICEMInventoryLocation
Export-ModuleMember -Function Get-APICEMInventoryLocations
Export-ModuleMember -Function New-APICEMInventoryLocation
Export-ModuleMember -Function Remove-APICEMInventoryLocation

. (Join-Path -Path $PSScriptRoot -ChildPath 'APICEMNetworkInventory/APICEMInventoryTag.ps1')
Export-ModuleMember -Function Get-APICEMInventoryTagAssociations
Export-ModuleMember -Function Get-APICEMInventoryTag
Export-ModuleMember -Function Get-APICEMInventoryTags
Export-ModuleMember -Function New-APICEMInventoryTag
Export-ModuleMember -Function New-APICEMInventoryTagAssociation
Export-ModuleMember -Function Remove-APICEMInventoryTag
Export-ModuleMember -Function Remove-APICEMInventoryTagAssociation

. (Join-Path -Path $PSScriptRoot -ChildPath 'APICEMNetworkPlugAndPlay/APICEMNetworkPlugAndPlay.ps1')

Export-ModuleMember -Function Add-APICEMNetworkPlugAndPlayProjectDevice
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayDevice
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayDeviceHistory
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayDevices
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayFileTemplates
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayImageDefault
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayImages
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayPlatformFiles
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayProject
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayProjectDevice
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayProjectDevices
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayProjects
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayTemplateRenderer
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayTemplateRenderers
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayTemplate
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayTemplateConfig
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayTemplateConfigs
Export-ModuleMember -Function Get-APICEMNetworkPlugAndPlayTemplates
Export-ModuleMember -Function New-APICEMNetworkPlugAndPlayProject
Export-ModuleMember -Function Render-APICEMNetworkPlugAndPlayFileTemplate
Export-ModuleMember -Function Set-APICEMNetworkPlugAndPlayTemplateProperties

. (Join-Path -Path $PSScriptRoot -ChildPath 'APICEMTask/APICEMTask.ps1')

Export-ModuleMember -Function Get-APICEMTask

. (Join-Path -Path $PSScriptRoot -ChildPath 'APICEMUtility/Add-APICEMClaimedDevice')
Export-ModuleMember -Function Add-APICEMClaimedDevice

. (Join-Path -Path $PSScriptRoot -ChildPath 'APICEMUtility/Wait-APICEMTaskEnded.ps1')
Export-ModuleMember -Function Wait-APICEMTaskEnded

. (Join-Path -Path $PSScriptRoot -ChildPath 'HelperScripts/VelocityParser.ps1')
Export-ModuleMember -Function Get-VelocityDocumentInformation
