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
        Returns an inventory location

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER LocationID
        The GUID of the location to return

    .PARAMETER Name
        The name of the location to return

    .PARAMETER Tag
        The tag to get the location(s) by
    
    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        Get-APICEMInventoryLocation -Name 'Minionville'
        Remove-APICEMServiceTicket 
#>
Function Get-APICEMInventoryLocation {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$Tag,

        [Parameter()]
        [string]$LocationID
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/location'

    if(-not [string]::IsNullOrEmpty($Name)) {
        $uri += '/location-name/' + $Name
    } elseif(-not [string]::IsNullOrEmpty($LocationID)) {
        $uri += '/' + $LocationID
    } elseif(-not [string]::IsNullOrEmpty($Tag)) {
        $uri += '/' + $LocationID
    } 

    $response = Invoke-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Creates a new location with the attributes given

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER Name
        The name of the location

    .PARAMETER Description
        A free-form description of the location

    .PARAMETER CivicAddress
        A free form postal address

    .PARAMETER GeopgraphicAddress
        The coordinates of the address in the form of 'latitude/longitude' (American decimal point)

    .PARAMETER Tag
        A search tag associated with the location

    .PARAMETER NoWait
        Returns the APIC-EM task id for the job and does not wait for it to complete

    .PARAMETER Force
        Forces changes without prompt for confirmation

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        $newLocationJob = New-APICEMInventoryLocation -Name 'Minionville' -Description 'Where Bob, Kevin and Stuart really party'
        Remove-APICEMServiceTicket
#>
Function New-APICEMInventoryLocation {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [string]$CivicAddress,

        [Parameter()]
        [string]$GeopgraphicAddress,

        [Parameter()]
        [string]$Tag,

        [Parameter()]
        [switch]$NoWait,

        [Parameter()]
        [switch]$Force
    )

    if (-not ($Force -or $PSCmdlet.ShouldProcess('APIC-EM inventory locations'))) {  
        return $null  
    } 

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/location'

    $location = New-Object -TypeName 'PSCustomObject'
    if(-not [string]::IsNullOrEmpty($Name)) { Add-Member -InputObject $location -Name 'locationName' -Value $Name -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($Description)) { Add-Member -InputObject $location -Name 'description' -Value $Description -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($CivicAddress)) { Add-Member -InputObject $location -Name 'civicAddress' -Value $CivicAddress -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($GeopgraphicAddress)) { Add-Member -InputObject $location -Name 'geographicAddress' -Value $TFTPPath -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($Tag)) { Add-Member -InputObject $location -Name 'tag' -Value $Tag -MemberType NoteProperty }

    $requestObject = $location

    $response = $null
    try {
        $response = Invoke-APICEMPostRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject
    } catch {
        throw [System.Exception]::new(
            'Failed to post job to APIC-EM to add a location : ' + $_.Exception.Message,
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
                $taskResult.progress
            )
        }

        # TODO : Cisco bug? Should return JSON and message, not raw location id
        if($null -eq ($taskResult.Progress -Match '[0-9A-Za-z]{8}-[0-9A-Za-z]{4}-[0-9A-Za-z]{4}-[0-9A-Za-z]{12}')) {
                throw [System.Exception]::(
                'Response from creating a new location not correct'
            )
        }

        return $taskResult.Progress       
    } catch {
        throw [System.Exception]::new(
            'Successfully issued request to create a location, but failed to wait for completion : ' + $_.Exception.Message,
            $_.Exception
        )
    }

    return $response
}

<#
    .SYNOPSIS
        Removes an inventory location

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER LocationID
        The GUID of the location to remove

    .PARAMETER NoWait
        Return an APIC-EM Task ID and return immediately without waiting for completion

    .PARAMETER Force
        Forces changes without prompt for confirmation

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        Remove-APICEMInventoryLocation -LocationID '0ad107df-2261-4d30-ba4b-c3a374e6b7e0'
        Remove-APICEMServiceTicket 
#>
Function Remove-APICEMInventoryLocation {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$LocationID,

        [Parameter()]
        [switch]$NoWait,

        [Parameter]
        [switch]$Force
    )

    if (-not ($Force -or $PSCmdlet.ShouldProcess('APIC-EM discovery inventory'))) {  
        return $null  
    } 

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/location/' + $LocationID

    $response = $null
    try {
        $response = Invoke-APICEMDeleteRequest -ServiceTicket $session.ServiceTicket -Uri $uri
        
        if($NoWait) {
            return $response.response.taskId
        }
    } catch {
        throw [System.Exception]::new(
            'Failed to issue location delete request to APIC-EM',
            $_.Exception
        )
    }

    try {
        $taskResult = Wait-APICEMTaskEnded -TaskID $response.response.taskId
        if($taskResult.isError) {
            throw [System.Exception]::new(
                $taskResult.progress + ' - ' + $taskResult.failureReason
            )
        }

        if($taskResult.progress -notlike 'Location deleted successfully #*') {
            throw [System.Exception]::(
                'Response from location deletion not correct'
            )
        }

        return $taskResult.progress
    } catch {
        throw [System.Exception]::new(
            'Issuing delete request to APIC-EM succeeded, but failed to wait for the result',
            $_.Exception
        )
    }
}
