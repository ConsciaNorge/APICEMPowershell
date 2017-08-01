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
        Returns an APIC-EM plug and play template config

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER ConfigID
        The GUID of the template config to return

    .PARAMETER TemplateID
        The GUID of template which the config is associated

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        Get-APICEMNetworkPlugAndPlayTemplateConfig -ConfigID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayTemplateConfig {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$ConfigID,

        [Parameter()]
        [string]$TemplateID
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/template-config'

    if(-not [string]::IsNullOrEmpty($ConfigID)) {
        $uri += '/' + $ConfigID
    } elseif (-not [string]::IsNullOrEmpty($TemplateID)) {
        $uri += '?templateId=' + $TemplateID
    }

    $response = Invoke-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Sets the configuration properties for an APIC-EM plug and play template

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER TemplateID
        The GUID of the template to the set parameters on

    .PARAMETER ConfigProperties
        The properties to pass to the template for rendering

    .PARAMETER NoWait
        Force the command to return upon issuing the request with a task id instead of waiting for completion

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        $configProperties = @{
            Parameter1 = 'Hello'
            Parameter2 = 'World'
        }
        $templatePropertiesJob = Set-APICEMNetworkPlugAndPlayTemplateProperties -TemplateID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a' -ConfigProperties $configProperties
        Remove-APICEMServiceTicket
#>
Function Set-APICEMNetworkPlugAndPlayTemplateProperties {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Scope="Function", Target="Set-APICEMNetworkPlugAndPlayTemplateProperties")]
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$TemplateID,

        [Parameter(Mandatory)]
        $ConfigProperties,

        [Parameter()]
        [switch]$NoWait,

        [Parameter()]
        [switch]$Force
    )

    if (-not ($Force -or $PSCmdlet.ShouldProcess('APIC-EM plug and play template properties'))) {  
        return $null  
    } 

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/template-config'

    $requestObject = @(
        @{
            templateId = $TemplateID
            configProperty = $ConfigProperties
        }
    )

    try {
        $response = Invoke-APICEMPostRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject
    } catch {
        throw [System.Exception]::new(
            'Failed to issue request to make new template config : ' + $_.Exception.Message,
            $_.Exception
        )
    }

    if($NoWait) {
        return $response.taskId
    }

    try {
        $taskResult = Wait-APICEMTaskEnded @session -TaskID $response.taskId

        if($null -eq $taskResult) {
            throw [System.Exception]::new(
                'No result received from APIC-EM, timed out'
            )
        }

        if($taskResult.isError) {
            throw [System.Exception]::new(
                'Error deleting tag : ' + $taskResult.progress
            )
        }

        $taskResponse = ConvertFrom-Json -InputObject $taskResult.progress

        if($taskResponse.message -ne 'Successfully added the Ztd Template Config') {
            throw [System.Exception]::(
                'Response from tag deletion not correct'
            )
        }

        return $taskResponse.id       
    } catch {
        throw [System.Exception]::new(
            'Successfully issued request to make a new template, but failed to wait for completion : ' + $_.Exception.Message,
            $_.Exception
        )
    }
}
