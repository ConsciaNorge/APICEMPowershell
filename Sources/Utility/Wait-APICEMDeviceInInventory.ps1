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

    .PARAMETER Unreachable
        Runs the scan only against unreachable devices
#>
Function Wait-APICEMDeviceInInventory 
{
    Param(
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$SerialNumber,

        [Parameter()]
        [string]$IPAddress,

        [Parameter()]
        [int]$TimeOutSeconds = 600,

        [Parameter()]
        [int]$RefreshIntervalSeconds = 10,

        [Parameter()]
        [switch]$ResyncOnUnreachable
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    # Setup the timers
    [DateTime]$startTime = [DateTime]::Now
    [DateTime]$timeNow = $startTime
    [DateTime]$endTime = $timeNow.AddSeconds($TimeOutSeconds)
    [DateTime]$timeOfLastProbe = [DateTime]::new(1970, 1, 1, 0, 0, 0)
    [DateTime]$timeOfLastSync = [DateTime]::new(1970, 1, 1, 0, 0, 0)

    # Keep running until : Timeout, Device is found, or Device is reachable
    $networkDevice = $null
    Write-Progress -Activity ('Waiting for device ' + $IPAddress + ' to appear in the inventory')
    while(
        ($timeNow -lt $endTime) -and
        (
            ($null -eq $networkDevice) -or
            ($networkDevice.reachabilityStatus.ToLower() -ne 'reachable') -or
            ($networkDevice.serialNumber -ne $SerialNumber)
        )
    ) {
        # Update the timer
        $timeNow = [DateTime]::Now

        # If it's time to fetch the network device again, do it
        if($timeNow.Subtract($timeOfLastProbe).TotalSeconds -ge $RefreshIntervalSeconds) {
            try {
                $timeOfLastProbe = $timeNow
                $networkDevice = Get-APICEMNetworkDevice @session -IPAddress $IPAddress -ErrorAction SilentlyContinue
            } catch {
                # Nothing to catch here, just avoiding errors
                # TODO : Consider handling unexpected errors
            }
        }


        # If the device is not found or not reachable, see if something must be done
        if(
            ($null -eq $networkDevice) -or
            ($networkDevice.reachabilityStatus.ToLower() -ne 'reachable')
        ) {
            Write-Progress -Activity ('Waiting for device ' + $IPAddress + ' to appear in the inventory as reachable')
            
            # If requested, send a resync request to the server. This can be time consuming (20-30 seconds)
            if(
                ($null -ne $networkDevice) -and
                ($networkDevice.reachabilityStatus.ToLower() -eq 'unreachable') -and
                ($timeNow.Subtract($timeOfLastSync).TotalSeconds -ge 30) -and
                $ResyncOnUnreachable
            ) {
                $timeOfLastSync = $timeNow
                $resyncResult = Invoke-APICEMNetworkDeviceResync @session -DeviceID @($networkDevice.id) 
                if(-not ($resyncResult -ilike 'Synced devices:*')) {
                    throw 'Failed to initiate syncing of device ' + $SerialNumber
                }
                $timeNow = [DateTime]::Now
            }

            # If the network device is still not reachable, sleep
            if(
                ($null -eq $networkDevice) -or
                ($networkDevice.reachabilityStatus.ToLower() -ne 'reachable')
            ) {
                Start-Sleep -Seconds 1
            }

            <# Update progress bar
                  x        $timeNow - $startTime
               ------- = -------------------------
                 100         $timeoutSeconds
            #>  
            $progressPercent = [Convert]::ToInt32([Convert]::ToDouble($timeNow.Subtract($startTime).TotalSeconds * 100) / [Convert]::ToDouble($timeOutSeconds))
            Write-Progress -Activity 'Inventory presence' -CurrentOperation 'Waiting for device presence in inventory' -PercentComplete $progressPercent
        } 
    }

    if($null -ne $networkDevice) {
        Write-Progress -Activity 'Inventory presence' -CurrentOperation 'Waiting for device presence in inventory' -Status 'Completed' -Completed
    } else {
        Write-Progress -Activity 'Inventory presence' -CurrentOperation 'Waiting for device presence in inventory' -Status 'Timed out' -Completed 
    }

    return $networkDevice
}
