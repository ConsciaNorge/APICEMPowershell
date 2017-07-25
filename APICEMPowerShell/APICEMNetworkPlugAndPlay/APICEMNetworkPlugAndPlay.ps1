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
