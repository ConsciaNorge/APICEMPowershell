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
        Returns a list of APIC-EM plug and play active rendered template in the cache by ID

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER RendererID
        The template renderer ID representing the rendering job

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        Get-APICEMNetworkPlugAndPlayTemplateRenderer -RendererID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayTemplateRenderer {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$RendererID
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/template-renderer'
    
    if(-not [string]::IsNullOrEmpty($RendererID)) {
        uri += '/' + $RendererID
    }

    $response = Invoke-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Renders an APIC-EM Template with the given parameters

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER FileId
        The file id of the template to get

    .PARAMETER ConfigProperties
        The properties to pass to the template for rendering

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        $configProperties = @{
            Parameter1 = 'Hello'
            Parameter2 = 'World'
        }
        $renderJob = Publish-APICEMNetworkPlugAndPlayFileTemplate -FileID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a' -ConfigProperties $configProperties
        Remove-APICEMServiceTicket
#>
Function Publish-APICEMNetworkPlugAndPlayFileTemplate {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$FileId,

        [Parameter(Mandatory)]
        $ConfigProperties
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/template-renderer'

    $requestObject = @(
        @{
            fileId = $FileId
            configProperty = $ConfigProperties
        }
    )

    $response = Invoke-APICEMPostRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject

    return $response
}
