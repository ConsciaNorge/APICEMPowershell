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
        Waits for a specified APIC-EM task to complete
#>
Function Wait-APICEMTaskEnded {
    Param(
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$TaskID,

        [Parameter()]
        [int]$TimeOutSeconds = 20,

        [Parameter()]
        [int]$RefreshIntervalSeconds = 1
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    # Setup the timeout timer
    $timeNow = [DateTime]::Now
    $endTime = $timeNow.AddSeconds($TimeOutSeconds)

    # Get the task status
    $taskStatusTree = Get-APICEMTask @session -TaskID $TaskId -Tree

    # While time has not expired and the task status does not contain a field named 'endTime'
    while(
            ($timeNow -lt $endTime) -and 
            (
                ($null -eq $taskStatusTree) -or
                ((Get-Member -InputObject $taskStatusTree -Name 'endTime').Count -eq 0)
            )
    ) {
        # Handle odd case where APIC-EM sends stacked results 
        if($null -ne $taskStatusTree) {
            $endedTree = $taskStatusTree | Where-Object { (Get-Member -InputObject $_ -Name 'endTime').Count -ne 0 }
            if($null -ne $endedTree) {
                return $endedTree[0]
            }
        }

        Start-Sleep -Seconds $RefreshIntervalSeconds
        $taskStatusTree = Get-APICEMTask @session -TaskID $TaskId -Tree
        $timeNow = [DateTime]::Now
    }

    # If there is still no 'endTime' field, then return $null
    if(
        ($null -eq $taskStatusTree) -or
        ((Get-Member -InputObject $taskStatusTree -Name 'endTime').Count -eq 0)
    ) {
        return $null
    }

    return $taskStatusTree
}

