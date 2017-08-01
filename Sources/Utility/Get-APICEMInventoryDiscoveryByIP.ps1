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
Function ConvertIPToUInt32 {
    Param(
        [Parameter(Mandatory)]
        [string]$IPAddress
    )

    $octets = ($IPAddress -split '\.').ForEach{ [Convert]::ToUInt32($_) }
    if(($null -eq $octets) -or ($octets.Count -ne 4)) {
        throw [System.ArgumentException]::new(
            'There must be 4 octets in an IP address',
            'IPAddress'
        )
    }

    $octets.foreach{
        if($_ -gt 255) {
            throw [System.ArgumentException]::new(
                'Only Sandra Bullock is allowed to use octet values greater than 255',
                'IPAddress'
            )
        }
    }

    return (($octets[0] -shl 24) -bor ($octets[1] -shl 16) -bor ($octets[2] -shl 8) -bor $octets[3])
}

Function Get-APICEMIsInDiscoveryRange {
    Param(
        [Parameter(Mandatory)]
        [string]$DiscoveryType,

        [Parameter(Mandatory)]
        [string]$IPAddressRange,

        [Parameter(Mandatory)]
        [string]$IPAddress
    )

    if($DiscoveryType -eq 'Single') {
        return ($IPAddress -eq $IPAddressRange.Trim())
    }

    if($DiscoveryType -eq 'Range') {
        $addressValue = ConvertIPToUInt32($IPAddress)

        $ranges = $IPAddressRange -split ','
        foreach($range in $ranges) {
            $addresses = $range -split '-'
            if($addresses.Count -ne 2) {
                throw [System.ArgumentException]::new(
                    'IPAddressRange for discovery type range must be IP-IP',
                    'IPAddressRange'
                )
            }

            $lowValue = ConvertIPToUInt32($addresses[0])
            $highValue = ConvertIPToUInt32($addresses[1])
        
            if(($lowValue -le $addressValue) -and ($addressValue -le $highValue)) {
                return $true
            }
        }
    }

    return $false
}

<#
    .SYNOPSIS
        Scans all the discovery items on the APIC-EM until it finds a discovery which matches the given IP address

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER IPAddress
        The IP address to find discovery items for

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        $foundItems = Get-APICEMInventoryDiscoveryByIP -IPAddress '192.168.1.1'
        Remove-APICEMServiceTicket

    .NOTES
        This function is to compensate for the severe short-coming in APIC-EM which does not provide
        a means of getting discovery tasks based on anything other than an ID and it doesn't provide
        a reverse pointer on DiscoveryJob records to work back to the discovery task. Therefore it is
        not possible to remove a job if you don't know which job it is.

        As there may be overlapping discovery items which may cover the same IP address, this function
        will scan discovery items 500 at a time until it reaches the first 500 items which contain matches.
        It will then filter the 500 items to return only the discovery items within that batch.

        If this is a limitation for you that is unacceptable, then report an issue and I can change it 
        easily enough to support a scan all condition.
#>
Function Get-APICEMInventoryDiscoveryByIP {
    Param(
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$IPAddress
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $count = Get-APICEMInventoryDiscoveryCount

    $foundItems = $null
    for($i=0; (($i -lt $count) -and ($null -eq $foundItems)); $i += 500) {
        $passCount = [Math]::Max(500, ($count % 500))
        $items = Get-APICEMInventoryDiscoveryRange @session -Index ($i + 1) -Count $passCount

        $foundItems = $items | Where-Object { Get-APICEMIsInDiscoveryRange -DiscoveryType $_.discoveryType -IPAddressRange $_.ipAddressList -IPAddress $IPAddress }
    }

    return $foundItems
}


