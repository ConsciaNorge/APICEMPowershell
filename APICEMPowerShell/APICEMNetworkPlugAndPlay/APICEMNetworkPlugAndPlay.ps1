<#
    .SYNOPSIS
        Returns a list of network plug and play device by device ID

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER ServiceTicket
        The GUID which represents the device

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -HostIP 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayDevice -HostIP 'apicvip.company.local' -ServiceTicket $serviceTicket -DeviceID '5fb95f97-6558-4c1a-82ca-f732f05acab3'
#>
Function Get-APICEMNetworkPlugAndPlayDevice {
    Param (
        [Parameter(Mandatory)]
        [string]$HostIP,

        [Parameter(Mandatory)]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$DeviceID
    )

    $response = Internal-APICEMGetRequest -ServiceTicket $ServiceTicket -Uri ('https://' + $HostIP + '/api/v1/pnp-device/' + $DeviceID)

    return $response
}

<#
    .SYNOPSIS
        Returns a list of network plug and play devices

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -HostIP 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayDevices -HostIP 'apicvip.company.local' -ServiceTicket $serviceTicket
#>
Function Get-APICEMNetworkPlugAndPlayDevices {
    Param (
        [Parameter(Mandatory)]
        [string]$HostIP,

        [Parameter(Mandatory)]
        [string]$ServiceTicket
    )

    $response = Internal-APICEMGetRequest -ServiceTicket $ServiceTicket -Uri ('https://' + $HostIP + '/api/v1/pnp-device')

    return $response
}

<#
    .SYNOPSIS
        Returns a plug and play device's history by its serial number

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER SerialNumber
        The serial number of the device to query

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -HostIP 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        $devices = Get-APICEMNetworkPlugAndPlayDevices -HostIP 'apicvip.company.local' -ServiceTicket $serviceTicket
        Get-APICEMNetworkPlugAndPlayDeviceHistory -HostIP 'apicvip.company.local' -ServiceTicket $serviceTicket -SerialNumber $devices[0].SerialNumber
#>
Function Get-APICEMNetworkPlugAndPlayDeviceHistory {
    Param (
        [Parameter(Mandatory)]
        [string]$HostIP,

        [Parameter(Mandatory)]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$SerialNumber
    )

    $response = Internal-APICEMGetRequest -ServiceTicket $ServiceTicket -Uri ('https://' + $HostIP + '/api/v1/pnp-device-history?serialNumber=' + $SerialNumber)

    return $response
}

<#
    .SYNOPSIS
        Returns a list of network plug and play device templates

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -HostIP 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayTemplates -HostIP 'apicvip.company.local' -ServiceTicket $serviceTicket
#>
Function Get-APICEMNetworkPlugAndPlayTemplates {
    Param (
        [Parameter(Mandatory)]
        [string]$HostIP,

        [Parameter(Mandatory)]
        [string]$ServiceTicket
    )

    $response = Internal-APICEMGetRequest -ServiceTicket $ServiceTicket -Uri ('https://' + $HostIP + '/api/v1/template')

    return $response
}
