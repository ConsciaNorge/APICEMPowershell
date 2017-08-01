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

Function Invoke-APICEMRestMethod {
    Param (
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [bool]$Raw,

        [Parameter(Mandatory)]
        [string]$Method,

        [Parameter()]
        [Object]$BodyValue
    )
 
    # Make sure there is a valid APIC-EM service ticket before continuing
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
        Method = $Method
        Uri = $Uri
        Headers = $headers
    }

    # Convert the BodyValue parameter to JSON
    $bodyParameter = @{}
    if($null -ne $BodyValue) {
        Write-Debug -Message ('Converting body values')
        
        $bodyText = ConvertTo-Json -InputObject $BodyValue
        Write-Debug -Message $bodyText

        $bodyParameter = @{
            Body = $bodyText
        }
    }

    $result = $null
    try {
        # Make the REST API call
        $result = Invoke-RestMethod @parameters @bodyParameter
    } catch {
        # Upon error, attempt to classify it and throw an exception
        if ($_.Exception -is [System.Net.WebException]) {
            if(
                ($null -ne (Get-Member -InputObject $_.Exception -Name 'Response'))
            ) {
                $responseBody = ([System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())).ReadToEnd()
                $errorResponse = ConvertFrom-Json -InputObject $responseBody
                if(
                    ($null -ne (Get-Member -InputObject $errorResponse -Name 'response')) -and
                    ($null -ne (Get-Member -InputObject $errorResponse.response -Name 'detail'))
                ) {
                    throw [System.Exception]::new(
                        $errorResponse.response.detail,
                        $_.Exception
                    )
                }
            }

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

    .RETURNVALUE
        The return value from the REST call if it completed successfully.
#>
Function Invoke-APICEMGetRequest {
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

    return Invoke-APICEMRestMethod -Method 'Get' -Uri $Uri -ServiceTicket $ServiceTicket -Raw $Raw -BodyValue $BodyValue
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
Function Invoke-APICEMPostRequest {
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

    return Invoke-APICEMRestMethod -Method 'Post' -Uri $Uri -ServiceTicket $ServiceTicket -Raw $Raw -BodyValue $BodyValue
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
Function Invoke-APICEMPutRequest {
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

    return Invoke-APICEMRestMethod -Method 'Put' -Uri $Uri -ServiceTicket $ServiceTicket -Raw $Raw -BodyValue $BodyValue
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
Function Invoke-APICEMDeleteRequest {
    Param (
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter()]
        [string]$ServiceTicket
    )

    return Invoke-APICEMRestMethod -Method 'Delete' -Uri $Uri -ServiceTicket $ServiceTicket -Raw $true -BodyValue $BodyValue
}

Function Get-UriParameterQuery {
    Param (
        [Parameter(Mandatory)]
        [string[]]$Items
    )

    $queryString = $QueryItems -join '&'

    if(-not [string]::IsNullOrEmpty($queryString)) {
        return '?' + $queryString
    }

    return ''
}

Function Add-ParameterToUri {
    Param (
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Value
    )

    if([string]::IsNullOrEmpty()) {
        return $Uri
    }

    [System.UriBuilder]$uriBuilder = [System.UriBuilder]::new($uri)
        $query = $uriBuilder.Query
    if($query.StartsWith('?')) {
        $query = $query.Substring(1)
    }

    if([string]::IsNullOrEmpty($uriBuilder.Query)) {
        $query += $Name + '=' + $Value
    } else {
        $query += '&' + $Name + '=' + $Value        
    }

    $uriBuilder.Query = $query

    return $uriBuilder.Uri
}

Function Add-StringParameterToUriIfNotEmpty {
    Param (
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [string]$Value,

        [Parameter()]
        [switch]$ForceUpper
    )

    if([string]::IsNullOrEmpty($Value)) {
        return $Uri
    }

    if($ForceUpper) {
        $Value = $Value.ToUpper()
    }

    [System.UriBuilder]$uriBuilder = [System.UriBuilder]::new($uri)
    $query = $uriBuilder.Query
    if($query.StartsWith('?')) {
        $query = $query.Substring(1)
    }

    if([string]::IsNullOrEmpty($uriBuilder.Query)) {
        $query += $Name + '=' + $Value
    } else {
        $query += '&' + $Name + '=' + $Value        
    }

    $uriBuilder.Query = $query

    return $uriBuilder.Uri
}

Function Add-StringParameterToUriIfTrue {
    Param (
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Value,

        [Parameter(Mandatory)]
        [bool]$TestValue
    )

    if(-not $TestValue) {
        return $Uri
    }

    [System.UriBuilder]$uriBuilder = [System.UriBuilder]::new($uri)
    $query = $uriBuilder.Query
    if($query.StartsWith('?')) {
        $query = $query.Substring(1)
    }

    if([string]::IsNullOrEmpty($uriBuilder.Query)) {
        $query += $Name + '=' + $Value
    } else {
        $query += '&' + $Name + '=' + $Value        
    }

    $uriBuilder.Query = $query

    return $uriBuilder.Uri
}

Function Add-StringPathToUriIfNotEmpty {
    Param (
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter()]
        [string]$Value
    )

    if([string]::IsNullOrEmpty($Value)) {
        return $uri
    }

    $uri += '/' + $Value

    return $uri
}
