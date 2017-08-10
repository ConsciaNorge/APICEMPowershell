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

Function Get-NetworkPrefixParts {
    param(
        [Parameter(Mandatory)]
        [string]$Prefix
    )

    $parts = $Prefix -split '/'
    [System.Net.IPAddress]$ipAddress = $null
    
    if(
        ($null -eq $parts) -or
        (-not ($parts -is [string[]])) -or
        ($parts.Count -ne 2) -or
        (-not [System.Net.IPAddress]::TryParse($parts[0], [ref]$ipAddress)) -or
        ($null -eq ($parts[1] -Match '0*((3[0-2])|([12]?[0-9]))'))
    ) {
        throw [System.ArgumentException]::new(
            'Invalid format for network prefix which must be similar to 192.168.0.0/24',
            'Prefix'
        )
    }

    return ($ipAddress.ToString()),([Convert]::ToInt32($parts[1]))
}

Function Test-IsInNetwork {
    Param(
        [Parameter(Mandatory)]
        [string]$Prefix,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$IPAddress
    )

    if([string]::IsNullOrEmpty($IPAddress)) {
        return $false
    }

    $ipPrefix,$prefixLength = Get-NetworkPrefixParts -Prefix $Prefix

    $prefixAsUInt32 = ConvertIPToUInt32 -IPAddress $ipPrefix
    $addressAsUint32 = ConvertIPToUInt32 -IPAddress $IPAddress
    $mask = [uint32]"0xffffffff" -shl (32 - $prefixLength)

    return (($prefixAsUInt32 -band $mask) -eq ($addressAsUint32 -band $mask))
}

Function Get-APICEMPnPDevicesByNetwork {
    Param(
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$NetworkPrefix,

        [Parameter()]
        [switch]$Unclaimed
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $pnpDevices = if($Unclaimed) {
        Get-APICEMNetworkPlugAndPlayDevice @session -Unclaimed 
    } else {
        Get-APICEMNetworkPlugAndPlayDevice @session
    }

    return $pnpDevices | Where-Object { Test-IsInNetwork -Prefix $NetworkPrefix -IPAddress $_.ipAddress }
}



