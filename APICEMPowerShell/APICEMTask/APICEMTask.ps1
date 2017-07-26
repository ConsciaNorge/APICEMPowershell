<#
    .SYNOPSIS
        Returns an APIC-EM task by ID

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER TaskID
        The ID of the task to get status information about

    .PARAMETER Tree
        Specified whether to return just the task or the entire task tree

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMTask -TaskID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a'
        Remove-APICEMServiceTicket 
#>
Function Get-APICEMTask {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$TaskID,

        [Parameter()]
        [switch]$Tree
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/task/' + $TaskID

    if($Tree) {
        $uri += '/tree'
    }

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}
