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

<#
    .SYNOPSIS
        Returns a specific APIC-EM registered project

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER ProjectID
        The GUID of the project

    .PARAMETER Name
        The name of the project

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        Get-APICEMNetworkPlugAndPlayProject -Name 'minions'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayProject {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$ProjectID,

        [Parameter()]
        [string]$Name
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-project'

    if(-not [string]::IsNullOrEmpty($ProjectID)) {
        $uri += '/' + $ProjectID 
    } elseif (-not [string]::IsNullOrEmpty($Name)) {
        $uri += '?siteName=' + $Name 
    } 

    $response = Invoke-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Returns the device associated with a plug and play project and device id

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER ProjectID
        The GUID of the project

    .PARAMETER DeviceID
        The serial number of device of the device

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        Get-APICEMNetworkPlugAndPlayProjectDevice -ProjectID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a' -DeviceID '0ae8e543-ee35-4e15-a268-3121b144d542'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayProjectDevice {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$ProjectID,

        [Parameter()]
        [string]$SerialNumber
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-project/' + $ProjectID + '/device'
    
    $uri = Add-StringParameterToUriIfNotEmpty -uri $uri -Name 'serialNumber' -Value $SerialNumber
    
    $response = Invoke-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Removes the device associated with a plug and play project and device id

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER ProjectID
        The GUID of the project

    .PARAMETER DeviceID
        The GUID of the device

    .PARAMETER NoWait
        Return an APIC-EM task id and don't wait for result.

    .PARAMETER Force
        Force the change, don't prompt

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        Remove-APICEMNetworkPlugAndPlayProjectDevice -ProjectID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a' -DeviceID '0ae8e543-ee35-4e15-a268-3121b144d542'
        Remove-APICEMServiceTicket
#>
Function Remove-APICEMNetworkPlugAndPlayProjectDevice {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$ProjectID,

        [Parameter(Mandatory)]
        [string]$DeviceID,

        [Parameter()]
        [switch]$NoWait,

        [Parameter()]
        [switch]$Force
    )

    if (-not ($Force -or $PSCmdlet.ShouldProcess('APIC-EM plug and play project devices'))) {  
        return $null  
    } 

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-project/' + $ProjectID + '/device'
    
    $uri = Add-StringPathToUriIfNotEmpty -uri $uri $DeviceID 

    $response = $null
    try {
        $response = Invoke-APICEMDeleteRequest -ServiceTicket $session.ServiceTicket -Uri $uri
        
        if($NoWait) {
            return $response.response.taskId
        }
    } catch {
        throw [System.Exception]::new(
            'Failed to issue project device delete request to APIC-EM',
            $_.Exception
        )
    }

    try {
        $taskResult = Wait-APICEMTaskEnded -TaskID $response.response.taskId
        if($taskResult.isError) {
            throw [System.Exception]::new(
                $taskResult.progress
            )
        }

        if($taskResult.progress -ne ('Success Deleting Site Device(Rule): id# ' + $DeviceID)) {
            throw [System.Exception]::(
                'Response from device deletion not correct'
            )
        }

        return $taskResult.progress
    } catch {
        throw [System.Exception]::new(
            'Issuing delete request to APIC-EM succeeded, but failed to wait for the result',
            $_.Exception
        )
    }
}

<#
    .SYNOPSIS
        Claims a plug and play device within a project (Create a new device under a given project)

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER ProjectID
        The GUID of the APIC-EM project

    .PARAMETER PlatformID
        The GUID of the platform of the device (see Get-APICEMNetworkPlugAndPlayPlatformFiles)

    .PARAMETER HostName
        The hostname of the device to claim

    .PARAMETER HasAAA
        Specifies that the configuration template has AAA

    .PARAMETER SerialNumber
        The serial number of the device to claim

    .PARAMETER PkiEnabled
        Configures whether the device should have PKI enabled

    .PARAMETER SudiRequired
        Configures whether a secure device unique identifier is required

    .PARAMETER TemplateConfigID
        The GUID of the template config to apply to the device

    .PARAMETER ImageId
        The ImageId (GUID) of the IOS (or other firmware) to apply to the claimed device

    .PARAMETER Role
        The device role as it should be configured in the inventory (ACCESS/DISTRIBUTION/CORE)

    .PARAMETER NoWait
        Returns immediately following the initiation of the task with the APIC-EM task id

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        $parameters = @{
            HasAAA = '262'
            HostName = 'PIZZAHUT'
            PlatformId = 'WS-C3560CX-12TC'
            SerialNumber = 'FOC8675X309'
            PkiEnabled = $false
            SudiRequired = $false
            TemplateConfigId = '9e5c9259-9125-4c9b-859b-bc5cb3ead1c3'
        }
        $claimDeviceJob = Add-APICEMNetworkPlugAndPlayProjectDevice @parameters
        Remove-APICEMServiceTicket
#>
Function Add-APICEMNetworkPlugAndPlayProjectDevice {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$ProjectID,

        [Parameter()]
        [string]$HasAAA,

        [Parameter(Mandatory)]
        [string]$HostName,

        [Parameter(Mandatory)]
        [string]$PlatformId,

        [Parameter()]
        [string]$SerialNumber,

        [Parameter()]
        [bool]$PkiEnabled,

        [Parameter()]
        [bool]$SudiRequired,

        [Parameter()]
        [string]$TemplateConfigId,

        [Parameter()]
        [string]$ImageId,

        [Parameter()]
        [string]$Role,

        [Parameter()]
        [switch]$NoWait
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-project/' + $ProjectID + '/device'

    $deviceSettings = New-Object -TypeName 'PSCustomObject'
    if(-not [string]::IsNullOrEmpty($HasAAA)) { Add-Member -InputObject $deviceSettings -Name 'hasAAA' -Value $HasAAA -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($Hostname)) { Add-Member -InputObject $deviceSettings -Name 'hostName' -Value $Hostname -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($PlatformId)) { Add-Member -InputObject $deviceSettings -Name 'platformId' -Value $PlatformId -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SerialNumber)) { Add-Member -InputObject $deviceSettings -Name 'serialNumber' -Value $SerialNumber -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('PkiEnabled')) { Add-Member -InputObject $deviceSettings -Name 'pkiEnabled' -Value $PkiEnabled -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('SudiRequired')) { Add-Member -InputObject $deviceSettings -Name 'sudiRequired' -Value $SudiRequired -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($TemplateConfigId)) { Add-Member -InputObject $deviceSettings -Name 'templateConfigId' -Value $TemplateConfigId -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($ImageId)) { Add-Member -InputObject $deviceSettings -Name 'imageId' -Value $ImageId -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($Role)) { Add-Member -InputObject $deviceSettings -Name 'role' -Value $Role -MemberType NoteProperty }

    $requestObject = @(
        $deviceSettings
    )

    $response = $null
    try {
        $response = Invoke-APICEMPostRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject
    } catch {
        throw [System.Exception]::new(
            'Failed to post job to APIC-EM to claim a plug and play device : ' + $_.Exception.Message,
            $_.Exception
        )
    }

    if($NoWait) {
        return $response.taskId
    }

    try {
        $taskResult = Wait-APICEMTaskEnded @session -TaskID $response.taskId

        if($null -eq $taskResult) {
            throw [System.Exception]::new(
                'No result received from APIC-EM, timed out'
            )
        }

        if($taskResult.isError) {
            throw [System.Exception]::new(
                'Error claiming PnP device : ' + $taskResult.progress
            )
        }

        $taskResponse = ConvertFrom-Json -InputObject $taskResult.progress

        if($taskResponse.message -ne 'Success creating new site device(rule)') {
            throw [System.Exception]::(
                'Response from project rule creation not correct'
            )
        }

        return $taskResponse.ruleId       
    } catch {
        throw [System.Exception]::new(
            'Successfully issued request to claim a pnp device, but failed to wait for completion : ' + $_.Exception.Message,
            $_.Exception
        )
    }
}

<#
    .SYNOPSIS
        Creates a new APIC-EM PnP project

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER Name
        The name of the project

    .PARAMETER ProvisionedBy
        The name of the user who provisioned the project

    .PARAMETER TFTPServer
        TFTP Server Host name or IP

    .PARAMETER TFTPPath
        TFTP Server path

    .PARAMETER Notes
        Notes to be stored with the project

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        $newProjectJob = New-APICEMNetworkPlugAndPlayProject -Name 'Minions'
        Remove-APICEMServiceTicket
#>
Function New-APICEMNetworkPlugAndPlayProject {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [string]$ProvisionedBy,

        [Parameter()]
        [string]$TFTPServer,

        [Parameter()]
        [string]$TFTPPath,

        [Parameter()]
        [string]$Notes
    )

    if (-not ($Force -or $PSCmdlet.ShouldProcess('APIC-EM plug and play projects'))) {  
        return $null  
    } 

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-project'

    $site = New-Object -TypeName 'PSCustomObject'
    if(-not [string]::IsNullOrEmpty($Name)) { Add-Member -InputObject $site -Name 'siteName' -Value $Name -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($ProvisionedBy)) { Add-Member -InputObject $site -Name 'provisionedBy' -Value $ProvisionedBy -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($TFTPServer)) { Add-Member -InputObject $site -Name 'tftpServer' -Value $TFTPServer -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($TFTPPath)) { Add-Member -InputObject $site -Name 'tftpPath' -Value $TFTPPath -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($Notes)) { Add-Member -InputObject $site -Name 'note' -Value $Notes -MemberType NoteProperty }

    $requestObject = @(
        $site
    )

    $response = Invoke-APICEMPostRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject

    return $response
}
