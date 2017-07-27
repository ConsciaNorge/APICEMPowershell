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
        Returns a list of location tags

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMInventoryTags 
        Remove-APICEMServiceTicket 
#>
Function Get-APICEMInventoryTags {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/tag')

    return $response
}

<#
    .SYNOPSIS
        Returns a location tag

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER Name
        The name of the tag to return

    .PARAMETER TagID
        The GUID of the tag to return

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMInventoryTag -Name FuzzyBunny
        Remove-APICEMServiceTicket 
#>
Function Get-APICEMInventoryTag {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$TagID
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/tag'

    if(-not [string]::IsNullOrEmpty($Name)) {
        $uri += '?tag=' + $Name
    } elseif (-not [string]::IsNullOrEmpty($TagID)) {
        $uri += '/' + $TagID
    } else {
        throw [System.ArgumentException]::new(
            'Either the tag name or ID must be provided'
        )
    }

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Creates a new APIC-EM inventory tag

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER Name
        The name of the tag

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        $newTagJob = New-APICEMInventoryTag -Name 'FuzzyBunny' 
        Remove-APICEMServiceTicket
#>
Function New-APICEMInventoryTag {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$Name
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/tag'

    $tag  = New-Object -TypeName 'PSCustomObject'
    if(-not [string]::IsNullOrEmpty($Name)) { Add-Member -InputObject $tag -Name 'tag' -Value $Name -MemberType NoteProperty }

    $requestObject = $tag

    $response = Internal-APICEMPostRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject

    return $response
}

<#
    .SYNOPSIS
        Removes a location tag

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER TagID
        The GUID of the tag to return

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Remove-APICEMInventoryTag -TagID '0ad107df-2261-4d30-ba4b-c3a374e6b7e0'
        Remove-APICEMServiceTicket 
#>
Function Remove-APICEMInventoryTag {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$TagID
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/tag/' + $TagID

    $response = Internal-APICEMDeleteRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}


<#
    .SYNOPSIS
        Gets all the resources associated with a tag with maximum limit of 500.

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER Name
        The name of the tag

    .PARAMETER TagID
        The GUID of the tag

    .PARAMETER NetworkDevices
        Set this switch if searching for network device tags

    .PARAMETER Interfaces
        Set this switch if searching for interface tags

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMInventoryTagAssociations -Name FuzzyBunny
        Remove-APICEMServiceTicket 
#>
Function Get-APICEMInventoryTagAssociations {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$TagID,

        [Parameter()]
        [switch]$NetworkDevices,

        [Parameter()]
        [switch]$Interfaces
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/tag/association'

    if(-not [string]::IsNullOrEmpty($Name)) {
        $uri += '?tag=' + $Name + '&'
    } elseif (-not [string]::IsNullOrEmpty($TagID)) {
        $uri += '/' + $TagID + '?'
    } else {
        throw [System.ArgumentException]::new(
            'Either the tag name or ID must be provided'
        )
    }

    if($NetworkDevices) {
        $uri += 'resourceType=network-device'
    } elseif($Interface) {
        uri += 'resourceType=interface'
    } else {
        throw [System.ArgumentException]::new(
            'Either -NetworkDevices or -Interfaces must be selected'
        )
    }

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Associate a tag with a network device or an interface

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER Name
        The name of the tag

    .PARAMETER TagID
        The GUID of the tag

    .PARAMETER NetworkDeviceID
        The GUID of a network device

    .PARAMETER InterfaceID
        The GUID of a network interface

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        $associateTagJob = New-APICEMInventoryTagAssociation -Name FuzzyBunny -NetworkDeviceId '0ad107df-2261-4d30-ba4b-c3a374e6b7e0'
        Remove-APICEMServiceTicket 
#>
Function New-APICEMInventoryTagAssociation {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$TagID,

        [Parameter()]
        [string]$NetworkDeviceID,

        [Parameter()]
        [string]$InterfaceID
    )

    if (
        ((-not [string]::IsNullOrEmpty($Name)) -and (-not [string]::IsNullOrEmpty($TagID))) -or
        (([string]::IsNullOrEmpty($Name)) -and ([string]::IsNullOrEmpty($TagID)))
    ) {
        throw [System.ArgumentException]::new(
            'Either -Name or -TagID must be set, but not both'
        )
    }

    if (
        ((-not [string]::IsNullOrEmpty($NetworkDeviceID)) -and (-not [string]::IsNullOrEmpty($InterfaceID))) -or
        (([string]::IsNullOrEmpty($NetworkDeviceID)) -and ([string]::IsNullOrEmpty($InterfaceID)))
    ) {
        throw [System.ArgumentException]::new(
            'Either -NetworkDeviceID or -InterfaceID must be set, but not both'
        )
    }

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/tag/association'

    $tagAssociation = New-Object -TypeName 'PSCustomObject'
    if(-not [string]::IsNullOrEmpty($Name)) { Add-Member -InputObject $tagAssociation -Name 'tag' -Value $Name -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($TagID)) { Add-Member -InputObject $tagAssociation -Name 'id' -Value $TagID -MemberType NoteProperty }

    if(-not [string]::IsNullOrEmpty($NetworkDeviceID)) 
    { 
        Add-Member -InputObject $tagAssociation -Name 'resourceId' -Value $NetworkDeviceID -MemberType NoteProperty 
        Add-Member -InputObject $tagAssociation -Name 'resourceType' -Value 'network-device' -MemberType NoteProperty 
    } elseif(-not [string]::IsNullOrEmpty($InterfaceID)) { 
        Add-Member -InputObject $tagAssociation -Name 'resourceId' -Value $InterfaceID -MemberType NoteProperty 
        Add-Member -InputObject $tagAssociation -Name 'resourceType' -Value 'interface' -MemberType NoteProperty 
    }

    $requestObject = $tagAssociation
    
    $response = Internal-APICEMPostRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject

    return $response
}

<#
    .SYNOPSIS
        Removes a tag from an associated network device or interface

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER TagID
        The GUID of the tag to return

    .PARAMETER NetworkDeviceID
        The GUID of a network device

    .PARAMETER InterfaceID
        The GUID of a network interface

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Remove-APICEMInventoryTagAssociation -TagID '0ad107df-2261-4d30-ba4b-c3a374e6b7e0' -NetworkDevice '35f5477c-cec5-49ee-9867-08c91e1f24ee'
        Remove-APICEMServiceTicket 
#>
Function Remove-APICEMInventoryTagAssociation {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$TagID,

        [Parameter()]
        [string]$NetworkDeviceID,

        [Parameter()]
        [string]$InterfaceID
    )

    if (
        ((-not [string]::IsNullOrEmpty($NetworkDeviceID)) -and (-not [string]::IsNullOrEmpty($InterfaceID))) -or
        (([string]::IsNullOrEmpty($NetworkDeviceID)) -and ([string]::IsNullOrEmpty($InterfaceID)))
    ) {
        throw [System.ArgumentException]::new(
            'Either -NetworkDeviceID or -InterfaceID must be set, but not both'
        )
    }

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/tag/association/' + $TagID
    
    if(-not [string]::IsNullOrEmpty($NetworkDeviceID)) 
    { 
        $uri += '?resourceId=' + $NetworkDeviceID + '&resourceType=network-device'
    } elseif(-not [string]::IsNullOrEmpty($InterfaceID)) { 
        $uri += '?resourceId=' + $InterfaceID + '&resourceType=interface'
    }

    $response = Internal-APICEMDeleteRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}
