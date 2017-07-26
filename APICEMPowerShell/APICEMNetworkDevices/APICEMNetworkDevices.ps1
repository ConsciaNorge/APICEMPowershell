
<#
    .SYNOPSIS
        Returns a list of the registered network devices

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkDevices -ApicHost 'apicvip.company.local' -ServiceTicket $serviceTicket
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
        $serviceTicket = Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkDevice -ApicHost 'apicvip.company.local' -ServiceTicket $serviceTicket -SerialNumber 'FDO1441P08L'
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
        $serviceTicket = Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkDeviceConfig -ApicHost 'apicvip.company.local' -ServiceTicket $serviceTicket -DeviceID '90488b4d-34be-4a44-b9e5-0909768fdad1'
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
        $serviceTicket = Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkDeviceModules -ApicHost 'apicvip.company.local' -ServiceTicket $serviceTicket -DeviceID '90488b4d-34be-4a44-b9e5-0909768fdad1'
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
        $serviceTicket = Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkDeviceManagementInfo -ApicHost 'apicvip.company.local' -ServiceTicket $serviceTicket -DeviceID '90488b4d-34be-4a44-b9e5-0909768fdad1'

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
        $serviceTicket = Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkDeviceLocation -ApicHost 'apicvip.company.local' -ServiceTicket $serviceTicket -DeviceID '90488b4d-34be-4a44-b9e5-0909768fdad1'
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
