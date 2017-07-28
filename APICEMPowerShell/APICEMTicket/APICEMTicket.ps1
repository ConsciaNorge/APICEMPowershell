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
        Storage for APIC-EM service ticket and host once a ticket has been issued
#>
$script:InternalAPICEMSession = $null

<#
    .SYNOPSIS
        Call the APIC-EM Server to authenticate a session

    .DESCRIPTION
        APIC-EM maintains a session through the use of a 'granted ticket' which is similar in nature
        to a cookie but without the requirement of storing session information in the client's cookie
        store which could otherwise be perpetual.

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server. This is typically the virtual IP.

    .PARAMETER Username
        The username to use in order to authenticate against the server.

    .PARAMETER Password
        The password to use in order to authenticate against the server.

    .PARAMETER Passthru
        Returns the service ticket when this is true, otherwise, it sets a global session variable

    .RETURNVALUE
        A string containing the service ticket required by all follow up calls when -Passthru is set. Otherwise, there is
        no return value

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345' -Passthru

    .NOTES
        This function doesn't follow Powershell 'best practices for security and should use a PSCredentials structure instead,
        however the goal for now is usability.
#>
Function Get-APICEMServiceTicket {
    Param (
        [Parameter(Mandatory)]
        [string]$ApicHost,

        [Parameter(Mandatory)]
        [string]$Username,

        [Parameter(Mandatory)]
        [string]$Password,

        [Parameter()]
        [switch]$Passthru,

        [Parameter()]
        [switch]$IgnoreBadCerts
    )

    if($IgnoreBadCerts) {
        [System.Net.ServicePointManager]::CertificatePolicy = [IDontCarePolicy]::new() 
    }

    if ((-not $PassThru) -and ($null -ne $script:InternalAPICEMSession)) {
        throw [System.ArgumentException]::new(
            'When initiating a second instance of APIC-EM, it is necessary to use -Passthru and to manually maintain reference to the service ticket'
        )
    }

    # Add the content-type of 'application/json' to the header
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("content-type", 'application/json')

    # Create the HTTP request body
    $requestBody = @{
        username = $Username
        password = $Password
    }

    # Create the parameters necessary to make the request against the server
    $parameters = @{
        Method = 'Post'
        Uri = 'https://' + $ApicHost + '/api/v1/ticket'
        Headers = $headers
        Body = ConvertTo-Json -InputObject $requestBody
    }

    $result = $null
    try {
        # Call the APIC-EM server
        $result = Invoke-RestMethod @parameters
    } catch {
        # Generate an exception if this fails
        throw [System.Exception]::new(
            'Failed to acquire service ticket from APIC-EM',
            $_.Exception
        )
    }

    if($Passthru) {
        # Return the service ticket
        return $result.response.serviceTicket
    }

    $script:InternalAPICEMSession = @{
        ApicHost = $ApicHost
        ServiceTicket = $result.response.serviceTicket
    }
}

<#
    .SYNOPSIS
        Deletes an APIC-EM session and invalidates the service ticket for future operations

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Remove-APICEMServiceTicket  
#>
Function Remove-APICEMServiceTicket {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket

    $response = Internal-APICEMDeleteRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/ticket/' + $session.ServiceTicket)

    $script:InternalAPICEMSession = $null

    return $response
}

Function Internal-APICEMHostIPAndServiceTicket {
    Param(
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    # If the HostIP and ServiceTicket are provided 
    if((-not [string]::IsNullOrEmpty($ApicHost)) -and (-not [string]::IsNullOrEmpty($ServiceTicket))) {
        # Return the provided HostIP and ServiceTicket
        return @{
            ApicHost = $ApicHost
            ServiceTicket = $ServiceTicket
        }
    } 
    
    # If either the HostIP or the ServiceTicket are provided
    if((-not [string]::IsNullOrEmpty($ApicHost)) -or (-not [string]::IsNullOrEmpty($ServiceTicket))) {
        throw [System.ArgumentException]::new(
            'When using argument HostIP or ServiceTicket it is necessary to use both'
        )
    }

    # If there are no APIC-EM session credentials stored
    if($null -eq $script:InternalAPICEMSession) {
        throw [System.Security.SecurityException]::new(
            'A service ticket has not been obtained from APIC-EM or provided as arguments'
        )
    }

    # Return the stored Host and ServiceTicket
    return @{
        ApicHost = $script:InternalAPICEMSession.ApicHost
        ServiceTicket = $script:InternalAPICEMSession.ServiceTicket
    }
}
