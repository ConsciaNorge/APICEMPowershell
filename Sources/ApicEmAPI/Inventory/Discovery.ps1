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
        Creates a new inventory device discovery process

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER Name
        The name of the discovery job

    .PARAMETER CDPLevel
        The number of CDP levels deep to search

    .PARAMETER IPFilterList
        A list of IP addresses to skip from the search

    .PARAMETER PasswordList
        A list of passwords to use for trying to login to devices

    .PARAMETER ProtocolOrder
        The protocol order to try (not properly documented at Cisco, will ask for clarification)

    .PARAMETER Rediscovery
        A switch that specifies whether rediscovery is needed

    .PARAMETER RetryCount
        The number of times to try to discover the device (default 3)

    .PARAMETER SnmpAuthPassphrase
        Passphrase for SNMPv3 privacy (avoid, use credentials)

    .PARAMETER SnmpPrivacyProtocol
        Privacy protocol to use for SNMPv3 (DES|AES128)
        
    .PARAMETER SnmpROCommunity
        SNMPv2 read-only community string

    .PARAMETER SnmpRWCommunity
        SNMPv2 read-write community string

    .PARAMETER UsernameList
        List of usernames to try to login to devices during the discovery (correlates 1:1 with PasswordList)

    .PARAMETER GlobalCredentialIDList
        A list of GUIDs specifying login credentials for accessing devices

    .PARAMETER ParentDiscoveryID
        A GUID of a parent discovery process (needs clarification from Cisco)

    .PARAMETER SnmpVersion
        The SNMP version to use can be '2' or '3' (this is a string value)

    .PARAMETER TimeoutSeconds
        The time to wait for a response from a device in seconds (default 5)

    .PARAMETER IPAddressList
        A list of address ranges to scan for devices (format depends on DiscoveryType)

    .PARAMETER DiscoveryType
        The search method to find devices. ('auto cdp discovery'|'single'|'range'|'multi range')

    .PARAMETER SnmpMode
        The SNMPv3 operational mode (AUTHPRIV|AUTHNOPRIV|NOAUTHNOPRIV)

    .PARAMETER SnmpUsername
        The SNMPv3 Username to use when connecting to the device

    .PARAMETER Force
        Bypasses prompting for permission to alter the APIC-EM

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        New-APICEMInventoryDiscovery -Name 'DAVE' -UsernameList @('Bob') -PasswordList @('Minions8675309') -IPAddressList '172.16.1.1' -DiscoveryType 'single' -ProtocolOrder 'ssh'
        Remove-APICEMServiceTicket 
#>
Function New-APICEMInventoryDiscovery {
    [CmdletBinding(SupportsShouldProcess = $true)]

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'passwordList')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'snmpAuthPassphrase')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'globalCredentialIDList')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingUserNameAndPassWordParams", "", Scope="Function", Target="*")]
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [int]$CDPLevel,

        [Parameter()]
        [string[]]$IPFilterList,

        [Parameter()]
        [string[]]$PasswordList,

        [Parameter()]
        [string]$ProtocolOrder,

        [Parameter()]
        [switch]$Rediscovery,

        [Parameter()]
        [int]$RetryCount = 3,

        [Parameter()]
        [string]$SnmpAuthPassphrase,

        [Parameter()]
        [string]$SnmpPrivacyProtocol,

        [Parameter()]
        [string]$SnmpROCommunity,

        [Parameter()]
        [string]$SnmpRWCommunity,

        [Parameter()]
        [string[]]$UsernameList,

        [Parameter()]
        [string[]]$GlobalCredentialIDList,

        [Parameter()]
        [string]$ParentDiscoveryID,

        [Parameter()]
        [string]$SnmpVersion,

        [Parameter()]
        [int]$TimeoutSeconds = 5,

        [Parameter(Mandatory)]
        [string]$IPAddressList,

        [Parameter()]
        [string]$DiscoveryType,

        [Parameter()]
        [string]$SnmpMode,

        [Parameter()]
        [string]$SnmpUsernamae,

        [Parameter()]
        [bool]$Force
    )

    if (-not ($Force -or $PSCmdlet.ShouldProcess('APIC-EM discovery inventory'))) {  
        return $null  
    } 

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/discovery'

    $deviceSettings = New-Object -TypeName 'PSCustomObject'

    if(-not [string]::IsNullOrEmpty($Name)) { Add-Member -InputObject $deviceSettings -Name 'name' -Value $Name -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('CDPLevel')) { Add-Member -InputObject $deviceSettings -Name 'cdpLevel' -Value ([Convert]::ToString($CDPLevel)) -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('IPFilterList')) { Add-Member -InputObject $deviceSettings -Name 'ipFilterList' -Value $IPFilterList -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('PasswordList')) { Add-Member -InputObject $deviceSettings -Name 'passwordList' -Value $PasswordList -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($ProtocolOrder)) { Add-Member -InputObject $deviceSettings -Name 'protocolOrder' -Value $ProtocolOrder -MemberType NoteProperty }
    if($Rediscovery) { Add-Member -InputObject $deviceSettings -Name 'reDiscovery' -Value $true -MemberType NoteProperty }
    if($RetryCount -gt 0) { Add-Member -InputObject $deviceSettings -Name 'retry' -Value ([Convert]::ToString($RetryCount)) -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpAuthPassphrase)) { Add-Member -InputObject $deviceSettings -Name 'snmpAuthPassphrase' -Value $SnmpAuthPassphrase -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpPrivacyProtocol)) { Add-Member -InputObject $deviceSettings -Name 'snmpPrivacyProtocol' -Value $SnmpPrivacyProtocol -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpROCommunity)) { Add-Member -InputObject $deviceSettings -Name 'snmpROCommunity' -Value $SnmpROCommunity -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpRWCommunity)) { Add-Member -InputObject $deviceSettings -Name 'snmpRWCommunity' -Value $SnmpRWCommunity -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('UsernameList')) { Add-Member -InputObject $deviceSettings -Name 'usernameList' -Value $UsernameList -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('GlobalCredentialIDList')) { Add-Member -InputObject $deviceSettings -Name 'globalCredentialIdList' -Value $GlobalCredentialIDList -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($ParentDiscoveryID)) { Add-Member -InputObject $deviceSettings -Name 'parentDiscoveryID' -Value $ParentDiscoveryID -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpVersion)) { Add-Member -InputObject $deviceSettings -Name 'snmpVersion' -Value $SnmpVersion -MemberType NoteProperty }
    if($TimeoutSeconds -gt 0) { Add-Member -InputObject $deviceSettings -Name 'timeout' -Value ([Convert]::ToString($TimeoutSeconds)) -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($IPAddressList)) { Add-Member -InputObject $deviceSettings -Name 'ipAddressList' -Value $IPAddressList -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($DiscoveryType)) { Add-Member -InputObject $deviceSettings -Name 'discoveryType' -Value $DiscoveryType -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpMode)) { Add-Member -InputObject $deviceSettings -Name 'snmpMode' -Value $SnmpMode -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpUsername)) { Add-Member -InputObject $deviceSettings -Name 'snmpUsername' -Value $SnmpUsername -MemberType NoteProperty }

    $requestObject = $deviceSettings

    $response = Invoke-APICEMPostRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject

    return $response
}

<#
    .SYNOPSIS
        Updates an existing inventory device discovery process

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER DiscoveryID
        The ID of the discovery job to update

    .PARAMETER DiscoveryStatus
        The status of the discovery job (set this to 'Active' to restart the job)

    .PARAMETER Name
        The name of the discovery job

    .PARAMETER CDPLevel
        The number of CDP levels deep to search

    .PARAMETER IPFilterList
        A list of IP addresses to skip from the search

    .PARAMETER PasswordList
        A list of passwords to use for trying to login to devices

    .PARAMETER ProtocolOrder
        The protocol order to try (not properly documented at Cisco, will ask for clarification)

    .PARAMETER Rediscovery
        A switch that specifies whether rediscovery is needed

    .PARAMETER RetryCount
        The number of times to try to discover the device (default 3)

    .PARAMETER SnmpAuthPassphrase
        Passphrase for SNMPv3 privacy (avoid, use credentials)

    .PARAMETER SnmpPrivacyProtocol
        Privacy protocol to use for SNMPv3 (DES|AES128)
        
    .PARAMETER SnmpROCommunity
        SNMPv2 read-only community string

    .PARAMETER SnmpRWCommunity
        SNMPv2 read-write community string

    .PARAMETER UsernameList
        List of usernames to try to login to devices during the discovery (correlates 1:1 with PasswordList)

    .PARAMETER GlobalCredentialIDList
        A list of GUIDs specifying login credentials for accessing devices

    .PARAMETER ParentDiscoveryID
        A GUID of a parent discovery process (needs clarification from Cisco)

    .PARAMETER SnmpVersion
        The SNMP version to use can be '2' or '3' (this is a string value)

    .PARAMETER TimeoutSeconds
        The time to wait for a response from a device in seconds (default 5)

    .PARAMETER IPAddressList
        A list of address ranges to scan for devices (format depends on DiscoveryType)

    .PARAMETER DiscoveryType
        Specifies the search method to find devices. ('auto cdp discovery'|'single'|'range'|'multi range')

    .PARAMETER SnmpMode
        Specifies the SNMPv3 operational mode (AUTHPRIV|AUTHNOPRIV|NOAUTHNOPRIV)

    .PARAMETER SnmpUsername
        Specifies the SNMPv3 Username to use when connecting to the device

    .PARAMETER Force
        Forces changes without prompt for confirmation

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        Set-APICEMInventoryDiscovery -DiscoveryID 987 -DiscoveryStatus 'Active'
        Remove-APICEMServiceTicket 
#>
Function Set-APICEMInventoryDiscovery {
    [CmdletBinding(SupportsShouldProcess = $true)]

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUserNameAndPassWordParams')]
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$DiscoveryID,

        [Parameter()]
        [string]$DiscoveryStatus,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [int]$CDPLevel,

        [Parameter()]
        [string[]]$IPFilterList,

        [Parameter()]
        [string[]]$PasswordList,

        [Parameter()]
        [string]$ProtocolOrder,

        [Parameter()]
        [switch]$Rediscovery,

        [Parameter()]
        [int]$RetryCount,

        [Parameter()]
        [string]$SnmpAuthPassphrase,

        [Parameter()]
        [string]$SnmpPrivacyProtocol,

        [Parameter()]
        [string]$SnmpROCommunity,

        [Parameter()]
        [string]$SnmpRWCommunity,

        [Parameter()]
        [string[]]$UsernameList,

        [Parameter()]
        [string[]]$GlobalCredentialIDList,

        [Parameter()]
        [string]$ParentDiscoveryID,

        [Parameter()]
        [string]$SnmpVersion,

        [Parameter()]
        [int]$TimeoutSeconds,

        [Parameter()]
        [string]$IPAddressList,

        [Parameter()]
        [string]$DiscoveryType,

        [Parameter()]
        [string]$SnmpMode,

        [Parameter()]
        [string]$SnmpUsername,

        [Parameter()]
        [switch]$Force
    )

    if (-not ($Force -or $PSCmdlet.ShouldProcess('APIC-EM discovery inventory'))) {  
        return $null  
    } 

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/discovery'

    $deviceSettings = New-Object -TypeName 'PSCustomObject'

    if(-not [string]::IsNullOrEmpty($DiscoveryID)) { Add-Member -InputObject $deviceSettings -Name 'id' -Value $DiscoveryID -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($DiscoveryStatus)) { Add-Member -InputObject $deviceSettings -Name 'discoveryStatus' -Value $DiscoveryStatus -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($Name)) { Add-Member -InputObject $deviceSettings -Name 'name' -Value $Name -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('CDPLevel')) { Add-Member -InputObject $deviceSettings -Name 'cdpLevel' -Value ([Convert]::ToString($CDPLevel)) -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('IPFilterList')) { Add-Member -InputObject $deviceSettings -Name 'ipFilterList' -Value $IPFilterList -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('PasswordList')) { Add-Member -InputObject $deviceSettings -Name 'passwordList' -Value $PasswordList -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($ProtocolOrder)) { Add-Member -InputObject $deviceSettings -Name 'protocolOrder' -Value $ProtocolOrder -MemberType NoteProperty }
    if($Rediscovery) { Add-Member -InputObject $deviceSettings -Name 'reDiscovery' -Value $true -MemberType NoteProperty }
    if($RetryCount -gt 0) { Add-Member -InputObject $deviceSettings -Name 'retry' -Value ([Convert]::ToString($RetryCount)) -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpAuthPassphrase)) { Add-Member -InputObject $deviceSettings -Name 'snmpAuthPassphrase' -Value $SnmpAuthPassphrase -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpPrivacyProtocol)) { Add-Member -InputObject $deviceSettings -Name 'snmpPrivacyProtocol' -Value $SnmpPrivacyProtocol -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpROCommunity)) { Add-Member -InputObject $deviceSettings -Name 'snmpROCommunity' -Value $SnmpROCommunity -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpRWCommunity)) { Add-Member -InputObject $deviceSettings -Name 'snmpRWCommunity' -Value $SnmpRWCommunity -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('UsernameList')) { Add-Member -InputObject $deviceSettings -Name 'usernameList' -Value $UsernameList -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('GlobalCredentialIDList')) { Add-Member -InputObject $deviceSettings -Name 'globalCredentialIdList' -Value $GlobalCredentialIDList -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($ParentDiscoveryID)) { Add-Member -InputObject $deviceSettings -Name 'parentDiscoveryID' -Value $ParentDiscoveryID -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpVersion)) { Add-Member -InputObject $deviceSettings -Name 'snmpVersion' -Value $SnmpVersion -MemberType NoteProperty }
    if($TimeoutSeconds -gt 0) { Add-Member -InputObject $deviceSettings -Name 'timeout' -Value ([Convert]::ToString($TimeoutSeconds)) -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($IPAddressList)) { Add-Member -InputObject $deviceSettings -Name 'ipAddressList' -Value $IPAddressList -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($DiscoveryType)) { Add-Member -InputObject $deviceSettings -Name 'discoveryType' -Value $DiscoveryType -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpMode)) { Add-Member -InputObject $deviceSettings -Name 'snmpMode' -Value $SnmpMode -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpUsername)) { Add-Member -InputObject $deviceSettings -Name 'snmpUsername' -Value $SnmpUsername -MemberType NoteProperty }

    $requestObject = $deviceSettings

    $response = Invoke-APICEMPutRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject

    return $response
}

<#
    .SYNOPSIS
        Returns an inventory discovery item 

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER DiscoveryID
        The discovery identifier (this is a simple integer, not a GUID)

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        Get-APICEMInventoryDiscovery -DiscoveryID 179
        Remove-APICEMServiceTicket
#>
Function Get-APICEMInventoryDiscovery {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$DiscoveryID
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/discovery/' + $DiscoveryID

    $response = Invoke-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Returns a list of inventory discovery items based on indexes and ranges.

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER Index
        The starting index to go from

    .PARAMETER Count
        The number of discovery items to return

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        Get-APICEMInventoryDiscovery -Index 0 -Count 3
        Remove-APICEMServiceTicket
#>
Function Get-APICEMInventoryDiscoveryRange {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [int]$Index=1,
        
        [Parameter(Mandatory)]
        [int]$Count
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/discovery/' + $Index.ToString() + '/' + $Count.ToString()

    $response = Invoke-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Returns the number if discovery items configured in the inventory discovery.

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        Get-APICEMInventoryCount
        Remove-APICEMServiceTicket
#>
Function Get-APICEMInventoryDiscoveryCount {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/discovery/count'

    $response = Invoke-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return [Convert]::ToUInt32($response)
}

<#
    .SYNOPSIS
        Removes a discovery item based on the discovery id

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER DiscoveryID
        The id of the discovery item to remove

    .PARAMETER NoWait
        Return the APIC-EM task id of the deletion job without waiting for it to complete

    .PARAMETER Force
        Force the deletion of the item without prompting

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        Remove-APICEMInventoryDiscovery -DiscoveryID 170
        Remove-APICEMServiceTicket
#>
Function Remove-APICEMInventoryDiscovery {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [int]$DiscoveryID,

        [Parameter()]
        [switch]$NoWait,

        [Parameter()]
        [switch]$Force
    )

    if (-not ($Force -or $PSCmdlet.ShouldProcess('APIC-EM plug and play project devices'))) {  
        return $null  
    } 

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/discovery/' + $DiscoveryID.ToString()

    $response = $null
    try {
        $response = Invoke-APICEMDeleteRequest -ServiceTicket $session.ServiceTicket -Uri $uri
        
        if($NoWait) {
            return $response.response.taskId
        }
    } catch {
        throw [System.Exception]::new(
            'Failed to issue inventory item discovery item delete request to APIC-EM',
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

        # Write-Verbose -Message ($taskResult.progress)
        # Write-Verbose -Message ('Discovery deleted successfully. # ' + $DiscoveryID.ToString())
        if($taskResult.progress -ne ('Discovery deleted successfully. #' + $DiscoveryID.ToString())) {
            throw [System.Exception]::(
                'Response from device deletion not correct'
            )
        }

        return $taskResult.progress
    } catch {
        throw [System.Exception]::new(
            'Issuing delete request to APIC-EM succeeded, but failed to wait for the result : ' + $_.Exception.Message,
            $_.Exception
        )
    }

    return [Convert]::ToUInt32($response)
}

