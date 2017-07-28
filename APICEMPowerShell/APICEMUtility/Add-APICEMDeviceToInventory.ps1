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
        Creates a new inventory discovery job and waits for it to complete with the specified device found (or timeout)

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER IPAddress
        The IP address of the device to discover

    .PARAMETER DiscoveryJobName
        The name of the new discovery job

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Add-APICEMDeviceToInventory -IPAddress '1.2.3.4' -DiscoveryJobName 'JOES-DINER'
        Remove-APICEMServiceTicket 
#>
Function Add-APICEMDeviceToInventory
{
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$IPAddress,

        [Parameter(Mandatory)]
        [string]$DiscoveryJobName

    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $globalCredentialList = @()
    $cliCredential = Get-APICEMInventoryGlobalCredential @session -CLI
    if($null -ne $cliCredential) { $globalCredentialList += $cliCredential }

    $snmpv2ReadCredential = Get-APICEMInventoryGlobalCredential @session -SNMPv2Read
    if($null -ne $snmpv2ReadCredential) { $globalCredentialList += $snmpv2ReadCredential }

    $snmpv2WriteCredential = Get-APICEMInventoryGlobalCredential @session -SNMPv2Write
    if($null -ne $snmpv2WriteCredential) { $globalCredentialList += $snmpv2WriteCredential }

    $snmpv3Credential = Get-APICEMInventoryGlobalCredential @session -SNMPv3
    if($null -ne $snmpv3Credential) { $globalCredentialList += $snmpv3Credential }

    if($globalCredentialList.Count -eq 0) {
        throw [System.Exception]::new(
            'There doesn''t appear to be any global credentials defined on the APIC-EM. Correct this before continuing'
        )
    }

    $discoveryParameters = @{
        Name                   = $DiscoveryJobName 
        ProtocolOrder          = 'ssh' 
        GlobalCredentialIDList = $globalCredentialList.id 
        IPAddressList          = $IPAddress 
        DiscoveryType          = 'Single'
    }

    $newDiscoveryJob = New-APICEMInventoryDiscovery @session @discoveryParameters
    $newDiscoveryStatus = Wait-APICEMTaskEnded @session -TaskID $newDiscoveryJob.taskId

    if(
        ($null -eq $newDiscoveryStatus) -or
        ($null -ne ($newDiscoveryStatus | Get-Member -Name errorCode))
    ) {
        throw [System.Exception]::new(
            'Failed to initiate discovery job on APIC-EM'
        )
    }

    $newDiscoveryId = $newDiscoveryStatus.progress

    $discoveryResult = Wait-APICEMDiscoveryCompletesWithADevice @session -DiscoveryID $newDiscoveryId
    if(
        ($null -eq $discoveryResult) -or 
        ($null -eq ($discoveryResult | Get-Member 'deviceIds')) -or 
        ([string]::IsNullOrWhiteSpace($discoveryResult.deviceIds))
    ) {
        throw [System.TimeoutException]::new(
            'Failed to find the newly claimed device via inventory discovery before timing out'
        )
    }

    $claimedDeviceId = $discoveryResult.deviceIds.Trim()

    return $claimedDeviceId
}
