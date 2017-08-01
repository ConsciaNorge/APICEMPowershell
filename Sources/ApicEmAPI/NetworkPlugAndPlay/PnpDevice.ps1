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
        Returns a list of network plug and play device by device ID

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER DeviceID
        The GUID which represents the device

    .PARAMETER State
        The state the device must be in to query it

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        Get-APICEMNetworkPlugAndPlayDevice -DeviceID '5fb95f97-6558-4c1a-82ca-f732f05acab3'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayDevice {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$DeviceID,

        [Parameter()]
        [string]$SerialNumber,

        [Parameter()]
        [string]$State,

        [Parameter()]
        [switch]$Unclaimed
    )

    if((-not [string]::IsNullOrEmpty($DeviceID)) -and (-not [string]::IsNullOrEmpty($SerialNumber))) {
        throw [System.ArgumentException]::new(
            'Either -DeviceID or -SerialNumber my be provided, but not both'
        )
    }

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-device'

    $uri = Add-StringPathToUriIfNotEmpty -Uri $uri -Value $DeviceID
    $uri = Add-StringParameterToUriIfNotEmpty -Uri $uri -Name 'serialNumber' -Value $SerialNumber
    $uri = Add-StringParameterToUriIfNotEmpty -Uri $uri -Name 'state' -Value $State -ForceUpper
    $uri = Add-StringParameterToUriIfTrue -Uri $uri -Name 'state' -Value 'UNCLAIMED' -TestValue $Unclaimed

    $response = Invoke-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Returns a plug and play device's history by its serial number

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER SerialNumber
        The serial number of the device to query

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local'
        $devices = Get-APICEMNetworkPlugAndPlayDevices 
        Get-APICEMNetworkPlugAndPlayDeviceHistory -SerialNumber $devices[0].SerialNumber
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayDeviceHistory {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$SerialNumber
    )

    $session = Get-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Invoke-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/pnp-device-history?serialNumber=' + $SerialNumber)

    return $response
}
