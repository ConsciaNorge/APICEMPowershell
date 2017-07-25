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
        [Parameter(Mandatory)]
        [string]$HostIP,

        [Parameter(Mandatory)]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$FileID
    )

    $response = Internal-APICEMGetRequest -ServiceTicket $ServiceTicket -Uri ('https://' + $HostIP + '/api/v1/file/' + $FileID) -Raw

    return $response
}

