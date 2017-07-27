
<#
    .SYNOPSIS
        Returns a list of locations

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMInventoryLocations 
        Remove-APICEMServiceTicket 
#>
Function Get-APICEMInventoryLocations {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/location')

    return $response
}

<#
    .SYNOPSIS
        Returns an inventory location

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER LocationID
        The GUID of the location to return

    .PARAMETER Name
        The name of the location to return

    .PARAMETER Tag
        The tag to get the location(s) by
    
    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMInventoryLocation -Name 'Minionville'
        Remove-APICEMServiceTicket 
#>
Function Get-APICEMInventoryLocation {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$Tag,

        [Parameter()]
        [string]$LocationID
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/location'

    if(-not [string]::IsNullOrEmpty($Name)) {
        $uri += '/location-name/' + $Name
    } elseif(-not [string]::IsNullOrEmpty($LocationID)) {
        $uri += '/' + $LocationID
    } elseif(-not [string]::IsNullOrEmpty($Tag)) {
        $uri += '/' + $LocationID
    } else {
        throw [System.ArgumentException]::new(
            'Either a location name or ID must be provided'
        )
    }

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Creates a new location with the attributes given

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER Name
        The name of the location

    .PARAMETER Description
        A free-form description of the location

    .PARAMETER CivicAddress
        A free form postal address

    .PARAMETER GeopgraphicAddress
        The coordinates of the address in the form of 'latitude/longitude' (American decimal point)

    .PARAMETER Tag
        A search tag associated with the location

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        $newLocationJob = New-APICEMInventoryLocation -Name 'Minionville' -Description 'Where Bob, Kevin and Stuart really party'
        Remove-APICEMServiceTicket
#>
Function New-APICEMInventoryLocation {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [string]$CivicAddress,

        [Parameter()]
        [string]$GeopgraphicAddress,

        [Parameter()]
        [string]$Tag
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/location'

    $location = New-Object -TypeName 'PSCustomObject'
    if(-not [string]::IsNullOrEmpty($Name)) { Add-Member -InputObject $location -Name 'locationName' -Value $Name -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($Description)) { Add-Member -InputObject $location -Name 'description' -Value $Description -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($CivicAddress)) { Add-Member -InputObject $location -Name 'civicAddress' -Value $CivicAddress -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($GeopgraphicAddress)) { Add-Member -InputObject $location -Name 'geographicAddress' -Value $TFTPPath -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($Tag)) { Add-Member -InputObject $location -Name 'tag' -Value $Tag -MemberType NoteProperty }

    $requestObject = $location

    $response = Internal-APICEMPostRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject

    return $response
}

<#
    .SYNOPSIS
        Removes an inventory location

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER LocationID
        The GUID of the location to remove

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Remove-APICEMInventoryLocation -LocationID '0ad107df-2261-4d30-ba4b-c3a374e6b7e0'
        Remove-APICEMServiceTicket 
#>
Function Remove-APICEMInventoryLocation {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$LocationID
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/location/' + $LocationID

    $response = Internal-APICEMDeleteRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response.response
}

