<#
    .SYNOPSIS
        Returns a the contents of a file by File ID

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER FileID
        The GUID which represents the requested file

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -HostIP 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMFile -HostIP 'apicvip.company.local' -ServiceTicket $serviceTicket -FileID 'd6dbd83c-a9da-4afc-abe0-72047ade1a06'
#>
Function Get-APICEMFile {
    Param (
        [Parameter()]
        [string]$HostIP,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$FileID
    )

    $session = Internal-APICEMHostIPAndServiceTicket -HostIP $HostIP -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.Host + '/api/v1/file/' + $FileID) -Raw

    return $response
}

<#
    .SYNOPSIS
        Returns a file namespace

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER Namespace
        The file namespace to return

    .EXAMPLE
        Get-APICEMServiceTicket -HostIP 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMFileNamespace -Namespace 'config'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMFileNamespace {
    Param (
        [Parameter()]
        [string]$HostIP,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$Namespace
    )

    $session = Internal-APICEMHostIPAndServiceTicket -HostIP $HostIP -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.Host + '/api/v1/file/namespace/' + $Namespace)

    return $response
}

<#
    .SYNOPSIS
        Returns a list of APIC-EM registered file namespaces

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        Get-APICEMServiceTicket -HostIP 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMFileNamespaces
        Remove-APICEMServiceTicket
#>
Function Get-APICEMFileNamespaces {
    Param (
        [Parameter()]
        [string]$HostIP,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Internal-APICEMHostIPAndServiceTicket -HostIP $HostIP -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.Host + '/api/v1/file/namespace')

    return $response
}

