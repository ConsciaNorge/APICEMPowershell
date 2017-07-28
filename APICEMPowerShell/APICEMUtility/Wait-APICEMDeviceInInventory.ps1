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
        Waits for an APIC-EM plug and play device to be added to the APIC-EM inventory

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER SerialNumber
        The serial number of the device to wait for being present in the inventory

    .PARAMETER TimeOutSeconds
        The total amount of time to run this task before timing out

    .PARAMETER RefreshIntervalSeconds
        The amount of time to wait between polling the status of the job
#>
Function Wait-APICEMDeviceInInventory 
{
    Param(
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$SerialNumber,

        [Parameter()]
        [int]$TimeOutSeconds = 600,

        [Parameter()]
        [int]$RefreshIntervalSeconds = 10
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    # Setup the timeout timer
    [DateTime]$timeNow = [DateTime]::Now
    [DateTime]$endTime = $timeNow.AddSeconds($TimeOutSeconds)

    $networkDevice = Get-APICEMNetworkDevice @session -SerialNumber $SerialNumber
    while(
            ($timeNow -lt $endTime) -and 
            ($null -eq $networkDevice)
    ) {
        Write-Progress -Activity 'Inventory presence' -CurrentOperation 'Waiting for device presence in inventory' -SecondsRemaining $endTime.Subtract($timeNow).Seconds
        Write-Host -NoNewline '.'
        Start-Sleep -Seconds $RefreshIntervalSeconds
        $networkDevice = Get-APICEMNetworkDevice @session -SerialNumber $SerialNumber
        $timeNow = [DateTime]::Now    
    }

    if($null -ne $networkDevice) {
        Write-Progress -Activity 'Inventory presence' -CurrentOperation 'Waiting for device presence in inventory' -Status 'Completed' -Completed
        Write-Host 'done'
    } else {
        Write-Progress -Activity 'Inventory presence' -CurrentOperation 'Waiting for device presence in inventory' -Status 'Timed out' -Completed 
        Write-Host 'timed out'
    }

    return ($null -ne $networkDevice)
}
