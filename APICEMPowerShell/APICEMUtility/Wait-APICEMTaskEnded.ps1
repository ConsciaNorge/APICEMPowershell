<#
    .SYNOPSIS
        Waits for a specified APIC-EM task to complete
#>
Function Wait-APICEMTaskEnded {
    Param(
        [Parameter(Mandatory)]
        [string]$TaskID,

        [Parameter()]
        [int]$TimeOutSeconds = 20,

        [Parameter()]
        [int]$RefreshIntervalSeconds = 1
    )

    # Setup the timeout timer
    $timeNow = [DateTime]::Now
    $endTime = $timeNow.AddSeconds($TimeOutSeconds)

    # Get the task status
    $taskStatusTree = Get-APICEMTask -TaskID $TaskId -tree

    # While time has not expired and the task status does not contain a field named 'endTime'
    while(
            ($timeNow -lt $endTime) -and 
            ((($taskStatusTree | Get-Member | Where-Object { $_.Name -eq 'endTime' }).Count) -eq 0)
    ) {
        Start-Sleep -Seconds $RefreshIntervalSeconds
        $taskStatusTree = Get-APICEMTask -TaskID $TaskId -tree
        $timeNow = [DateTime]::Now
    }

    # If there is still no 'endTime' field, then return $null
    if ((($taskStatusTree | Get-Member | Where-Object { $_.Name -eq 'endTime' }).Count) -eq 0) {
        return $null
    }

    return $taskStatusTree
}
