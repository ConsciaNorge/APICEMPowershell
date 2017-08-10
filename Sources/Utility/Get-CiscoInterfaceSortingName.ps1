
<#
    .SYNOPSIS
        Given a Cisco interface name (Gigabit0/0) returns a sortable value
    
    .PARAMETER Name
        The interface name, can be abbreviate or long form

    .EXAMPLE
        Get-CiscoInterfaceSortingName -Name 'Gig0/1'

        returns
        gi00000/00000/00000/00000/00001.00000000
#>
Function Get-CiscoInterfaceSortingName {
    Param(
        [Parameter(Mandatory)]
        $Name
    )

    $match = [RegEx]::Match($Name, '^\s*(?<abbreviation>[A-Za-z]{2})(?>\w*[A-Za-z]\s*)(?<numbers>\d+)(?>\/(?<numbers>\d+))*(?>\.(?<subinterface>\d+))?\s*$')
    if($null -eq $match) {
        throw [System.ArgumentException]::new(
            'Invalid interface name format ' + $Name
        )
    }

    $abbreviation = $match.Groups['abbreviation'].Value.ToLower()

    $numbers = $match.Groups['numbers'].Captures.Value

    while($numbers.Count -lt 5) {
        $numbers = @(0) + $numbers
    }

    $subinterface = [int64]($match.Groups['subinterface'].Value)

    return $abbreviation + ($numbers.foreach({ '{0:d5}' -f [int64]$_ }) -join '/') + ('.{0:d8}' -f $subinterface)
}

#Get-CiscoInterfaceSortingName -Name 'Gigabit0/0/0/0.23' | Out-Host
#Get-CiscoInterfaceSortingName -Name 'Dot11Radio 1' | Out-Host
