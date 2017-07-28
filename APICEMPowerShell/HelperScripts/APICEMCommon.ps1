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
        Internal function to simplify preparing headers and making POST requests to an APIC-EM server

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
        Internal function to simplify preparing headers and making PUT requests to an APIC-EM server

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
Function Internal-APICEMPutRequest {
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
        Method = 'Put'
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

