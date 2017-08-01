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
        Waits for a specified APIC-EM inventory discovery to complete (or timeout)

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER DiscoveryID
        The ID of the inventory discovery job to wait on

    .PARAMETER TimeOutSeconds
        The total amount of time to run this task before timing out

    .PARAMETER RefreshIntervalSeconds
        The amount of time to wait between polling the status of the job
#>
Function Wait-APICEMDiscoveryComplete
{
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$DiscoveryID,

        [Parameter()]
        [int]$TimeOutSeconds = 20,

        [Parameter()]
        [int]$RefreshIntervalSeconds = 3
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    # Setup the timeout timer
    $timeNow = [DateTime]::Now
    $endTime = $timeNow.AddSeconds($TimeOutSeconds)

    $discoveryResult = Get-APICEMInventoryDiscovery @session -DiscoveryID $DiscoveryId
    while(
        ($timeNow -lt $endTime) -and 
        (($null -eq $discoveryResult) -or ($discoveryResult.discoveryCondition -ne 'Complete'))
    ) {
        Start-Sleep $RefreshIntervalSeconds
        $discoveryResult = Get-APICEMInventoryDiscovery @session -DiscoveryID $DiscoveryId
        $timeNow = [DateTime]::Now
    }

    return $discoveryResult
}
