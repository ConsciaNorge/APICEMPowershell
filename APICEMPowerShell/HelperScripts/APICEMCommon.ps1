<#
    .SYNOPSIS
        Internal function to simplify preparing headers and making GET requests to an APIC-EM server

    .PARAMETER Uri
        The full APIC-EM URI to make the request against

    .PARAMETER ServiceTicket
        The service ticket issued by Get-APICEMServiceTicket after authentication

    .RETURNVALUE
        The return value from the REST call if it completed successfully.
#>
Function Internal-APICEMGetRequest {
    Param (
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter(Mandatory)]
        [string]$ServiceTicket
    )

    # Create the headers to pass as part of the HTTP request
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("content-type", 'application/json')
    $headers.Add("X-Auth-Token", $ServiceTicket)

    # Setup the parameters to pass to Invoke-RESTMethod (splatting)
    $parameters = @{
        Method = 'Get'
        Uri = $Uri
        Headers = $headers
    }

    $result = $null
    try {
        # Make the REST API call
        $result = Invoke-RestMethod @parameters
    } catch {
        # Upon error, attempt to classify it and throw an exception
        if ($_.Exception -is [System.Net.WebException]) {
            throw [System.Exception]::new(
                'Http exception',
                $_.Exception
            )

        } else {
            throw [System.Exception]::new(
                'Failed to get a list of network devices from APIC-EM',
                $_.Exception
            )
        }
    }

    # Return what came back from the APIC-EM server
    return $result.response
}

<#
    .SYNOPSIS
        Internal function to simplify preparing headers and making DELETE requests to an APIC-EM server

    .PARAMETER Uri
        The full APIC-EM URI to make the request against

    .PARAMETER ServiceTicket
        The service ticket issued by Get-APICEMServiceTicket after authentication

    .RETURNVALUE
        The return value from the REST call if it completed successfully.
#>
Function Internal-APICEMDeleteRequest {
    Param (
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter(Mandatory)]
        [string]$ServiceTicket
    )

    # Create the headers to pass as part of the HTTP request
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("content-type", 'application/json')
    $headers.Add("X-Auth-Token", $ServiceTicket)

    # Setup the parameters to pass to Invoke-RESTMethod (splatting)
    $parameters = @{
        Method = 'Delete'
        Uri = $Uri
        Headers = $headers
    }

    $result = $null
    try {
        # Make the REST API call
        $result = Invoke-RestMethod @parameters
    } catch {
        # Upon error, attempt to classify it and throw an exception
        if ($_.Exception -is [System.Net.WebException]) {
            throw [System.Exception]::new(
                'Http exception',
                $_.Exception
            )

        } else {
            throw [System.Exception]::new(
                'Failed to get a list of network devices from APIC-EM',
                $_.Exception
            )
        }
    }

    # Return what came back from the APIC-EM server
    return $result
}

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

    .RETURNVALUE
        A string containing the service ticket required by all follow up calls

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -HostIP 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'

    .NOTES
        This function doesn't follow Powershell 'best practices for security and should use a PSCredentials structure instead,
        however the goal for now is usability.
#>
Function Get-APICEMServiceTicket {
    Param (
        [Parameter(Mandatory)]
        [string]$HostIP,

        [Parameter(Mandatory)]
        [string]$Username,

        [Parameter(Mandatory)]
        [string]$Password
    )

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
        Uri = 'https://' + $HostIP + '/api/v1/ticket'
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

    # Return the service ticket
    return $result.response.serviceTicket
}

<#
    .SYNOPSIS
        Deletes an APIC-EM session and invalidates the service ticket for future operations

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -HostIP 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Remove-APICEMServiceTicket -HostIP 'apicvip.company.local' -ServiceTicket $serviceTicket 
#>
Function Remove-APICEMServiceTicket {
    Param (
        [Parameter(Mandatory)]
        [string]$HostIP,

        [Parameter(Mandatory)]
        [string]$ServiceTicket
    )

    $response = Internal-APICEMDeleteRequest -ServiceTicket $ServiceTicket -Uri ('https://' + $HostIP + '/api/v1/ticket/' + $ServiceTicket)

    return $response
}
