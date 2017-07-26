$script:InternalAPICEMSession = $null

<#
    This code is a Powershell workaround to allow self-signed certificates to be used without installing it as a trust 
#>
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;

        public class IDontCarePolicy : ICertificatePolicy {
        public IDontCarePolicy() {}
        public bool CheckValidationResult(
            ServicePoint sPoint, X509Certificate cert,
            WebRequest wRequest, int certProb) {
            return true;
        }
    }
"@

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

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [switch]$Raw
    )

    
    if ([string]::IsNullOrEmpty($ServiceTicket)) {
        if($null -eq $script:InternalAPICEMSession) {
            throw [System.Security.SecurityException]::new(
                'No service ticket available for making requests against APIC-EM'
            )
        }

        $uriInfo = [System.Uri]::new($uri)
        if($uriInfo.Host -ne $script:InternalAPICEMSession.Host) {
            throw [System.Security.SecurityException]::new(
                'Stored APIC-EM service ticket is for ' + $script:InternalAPICEMSession.Host + ' not for ' + $uriInfo.Host
            )
        }

        $ServiceTicket = $script:InternalAPICEMSession.ServiceTicket
    }

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
                'Failed to perform get against APIC-EM',
                $_.Exception
            )
        }
    }

    # Return the raw result if JSON is not prefered
    if ($Raw) {
        return $result
    }

    # Return what came back from the APIC-EM server
    return $result.response
}

<#
    .SYNOPSIS
        Internal function to simplify preparing headers and making GET requests to an APIC-EM server

    .PARAMETER Uri
        The full APIC-EM URI to make the request against

    .PARAMETER ServiceTicket
        The service ticket issued by Get-APICEMServiceTicket after authentication

    .PARAMETER Raw
        When this switch is set, then the raw content of the response is returned instead of the value of the JSON object response

    .PARAMETER BodyValue
        An object to convert to JSON to transfer as the body of the request

    .RETURNVALUE
        The return value from the REST call if it completed successfully.
#>
Function Internal-APICEMPostRequest {
    Param (
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [switch]$Raw,

        [Parameter()]
        [Object]$BodyValue
    )

    if ([string]::IsNullOrEmpty($ServiceTicket)) {
        if($null -eq $script:InternalAPICEMSession) {
            throw [System.Security.SecurityException]::new(
                'No service ticket available for making requests against APIC-EM'
            )
        }

        $uriInfo = [System.Uri]::new($uri)
        if($uriInfo.Host -ne $script:InternalAPICEMSession.Host) {
            throw [System.Security.SecurityException]::new(
                'Stored APIC-EM service ticket is for ' + $script:InternalAPICEMSession.Host + ' not for ' + $uriInfo.Host
            )
        }

        $ServiceTicket = $script:InternalAPICEMSession.ServiceTicket
    }

    # Create the headers to pass as part of the HTTP request
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("content-type", 'application/json')
    $headers.Add("X-Auth-Token", $ServiceTicket)

    # Convert the BodyValue parameter to JSON
    $bodyText = ConvertTo-Json -InputObject $BodyValue 

    # Setup the parameters to pass to Invoke-RESTMethod (splatting)
    $parameters = @{
        Method = 'Post'
        Uri = $Uri
        Headers = $headers
        Body = $bodyText
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
                'Failed to perform get against APIC-EM',
                $_.Exception
            )
        }
    }

    # Return the raw result if JSON is not prefered
    if ($Raw) {
        return $result
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

        [Parameter()]
        [string]$ServiceTicket
    )

    if ([string]::IsNullOrEmpty($ServiceTicket)) {
        if($null -eq $script:InternalAPICEMSession) {
            throw [System.Security.SecurityException]::new(
                'No service ticket available for making requests against APIC-EM'
            )
        }

        $uriInfo = [System.Uri]::new($uri)
        if($uriInfo.Host -ne $script:InternalAPICEMSession.Host) {
            throw [System.Security.SecurityException]::new(
                'Stored APIC-EM service ticket is for ' + $script:InternalAPICEMSession.Host + ' not for ' + $uriInfo.Host
            )
        }

        $ServiceTicket = $script:InternalAPICEMSession.ServiceTicket
    }

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
