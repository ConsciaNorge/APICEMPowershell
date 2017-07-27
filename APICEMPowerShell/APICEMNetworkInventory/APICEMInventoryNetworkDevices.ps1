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
        Returns a list of the registered network devices

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkDevices
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkDevices {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/network-device')

    return $response
}

<#
    .SYNOPSIS
        Returns a registered network device by serial number

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER SerialNumber
        The serial number of the device (usually starts with an F)

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkDevice -SerialNumber 'FDO1441P08L'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkDevice {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$SerialNumber
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/network-device/serial-number/' + $SerialNumber)

    return $response
}

<#
    .SYNOPSIS
        Returns the running config of the device with the specified device ID number

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER DeviceID
        The ID of the device to query (this is a GUID and can be found using Get-APICEMNetworkDevices)

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkDeviceConfig -DeviceID '90488b4d-34be-4a44-b9e5-0909768fdad1'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkDeviceConfig {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$DeviceId
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/network-device/config?id=' + $DeviceID)

    return $response.RunningConfig
}

<#
    .SYNOPSIS
        Returns the module inventory of the device with the specified device ID number

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER DeviceID
        The ID of the device to query (this is a GUID and can be found using Get-APICEMNetworkDevices)

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkDeviceModules -DeviceID '90488b4d-34be-4a44-b9e5-0909768fdad1'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkDeviceModules {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$DeviceId
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/network-device/module?deviceId=' + $DeviceID)

    return $response
}

<#
    .SYNOPSIS
        Returns the configured management information of the device with the specified device ID number

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER DeviceID
        The ID of the device to query (this is a GUID and can be found using Get-APICEMNetworkDevices)

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkDeviceManagementInfo -DeviceID '90488b4d-34be-4a44-b9e5-0909768fdad1'
        Remove-APICEMServiceTicket

    .NOTES
        Be aware that the structure returned here contains passwords for SSH and SNMP. It is recommended to only execute this command if
        the connection to the APIC-EM is considered secure even when using HTTPS.
#>
Function Get-APICEMNetworkDeviceManagementInfo {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$DeviceId
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/network-device/management-info?id=' + $DeviceID)

    return $response
}

<#
    .SYNOPSIS
        Returns the location of the device with the specified device ID number

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER DeviceID
        The ID of the device to query (this is a GUID and can be found using Get-APICEMNetworkDevices)

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkDeviceLocation -DeviceID '90488b4d-34be-4a44-b9e5-0909768fdad1'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkDeviceLocation {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$DeviceId
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/network-device/location?id=' + $DeviceID)

    return $response
}

<#
    .SYNOPSIS
        Configures the role of a network device.

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER DeviceId
        The GUID representing the switch

    .PARAMETER DeviceRole
        The ID of the device to query (this is a GUID and can be found using Get-APICEMNetworkDevices). If this
        value is missing, then the device role source will be configured as Auto. Otherwise it will be configured as
        manual.

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Set-APICEMNetworkDeviceRole -DeviceID '90488b4d-34be-4a44-b9e5-0909768fdad1' -DeviceRole 'DISTRIBUTION'
        Remove-APICEMServiceTicket
#>
Function Set-APICEMNetworkDeviceRole {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$DeviceId,

        [Parameter()]
        [string]$DeviceRole
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/network-device/brief'

    $deviceBrief = New-Object -TypeName 'PSCustomObject'
    if(-not [string]::IsNullOrEmpty($DeviceId)) { Add-Member -InputObject $deviceBrief -Name 'id' -Value $DeviceID -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($DeviceRole)) 
    { 
        Add-Member -InputObject $deviceBrief -Name 'roleSource' -Value 'MANUAL' -MemberType NoteProperty 
        Add-Member -InputObject $deviceBrief -Name 'role' -Value ($DeviceRole.ToUpper()) -MemberType NoteProperty 
    } else  { 
        Add-Member -InputObject $deviceBrief -Name 'roleSource' -Value 'AUTO' -MemberType NoteProperty 
        Add-Member -InputObject $deviceBrief -Name 'role' -Value 'UNKNOWN' -MemberType NoteProperty 
    }

    $requestObject = $deviceBrief
    
    $response = Internal-APICEMPutRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject

    return $response
}