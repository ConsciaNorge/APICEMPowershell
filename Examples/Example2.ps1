Clear-Host

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\APICEMPowerShell\APICEMPowerShell.psd1') -Force

$user = 'admin'
$pass = 'Minions12345'
$apicEMHostIP = '10.100.11.17'

# $user = 'darren'
# $pass = 'Minions12345'
# $apicEMHostIP = '172.16.96.68'

Function Add-APICEMClaimDeviceWithTemplate
{
    Param(
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$SerialNumber,

        [Parameter(Mandatory)]
        [string]$ProjectName,

        [Parameter(Mandatory)]
        [string]$TemplateName,

        [Parameter(Mandatory)]
        [string]$DeviceHostName,

        [Parameter(Mandatory)]
        [string]$DeviceIPAddress
    )

    if((-not [string]::IsNullOrEmpty($ApicHost)) -or (-not [string]::IsNullOrEmpty($ServiceTicket))) {
        if([string]::IsNullOrEmpty($ApicHost) -or [string]::IsNullOrEmpty($ServiceTicket)) {
            throw [System.ArgumentException]::new(
                'If providing HostIP or ServiceTicket, then both must be provided'
            )
        }

        $session = @{
            ApicHost = $ApicHost
            ServiceTicket = $ServiceTicket
        }
    }

    $unclaimedDevice = Get-APICEMNetworkPlugAndPlayDevice @session -SerialNumber $SerialNumber
    if($null -eq $unclaimedDevice) {
        throw [System.Exception]::new(
            'Failed to find APIC-EM PnP device [' + $SerialNumber + ']'
        )
    }

    $configValues = @{
        'HOSTNAME'     = $DeviceHostName
        'ProductID'    = $unclaimedDevice.platformId
        'IP-ADDRESS'   = $DeviceIPAddress
    }

    $claimDeviceParams = @{
        SerialNumber       = $unclaimedDevice.serialNumber
        TemplateFileName   = $TemplateName
        ProjectName        = $ProjectName
        ConfigProperties   = $configValues
        Hostname           = $DeviceHostName
        PkiEnabled         = $unclaimedDevice.pkiEnabled
        SudiRequired       = $unclaimedDevice.sudiRequired
    }

    return Add-APICEMClaimedDevice @claimDeviceParams 
}

# Get the service ticket which is basically a session token... kind of like a cookie
Get-APICEMServiceTicket -ApicHost $apicEMHostIP -Username $user -Password $pass -IgnoreBadCerts

$TemplateName = 'LAB_PnP'
$ProjectName = 'SYSTEM-NBN'
$NewHostName = 'BOB-KEVIN-STUART'
$NewDeviceIP = '10.100.5.101'

$unclaimedPlugAndPlayDevices = Get-APICEMNetworkPlugAndPlayDevices -Unclaimed
$unclaimedPlugAndPlayDevices | Select-Object serialNumber,ipAddress,platformId

Add-APICEMClaimDeviceWithTemplate `
    -SerialNumber $unclaimedPlugAndPlayDevices[0].serialNumber `
    -TemplateName $TemplateName `
    -ProjectName $ProjectName `
    -DeviceHostName $NewHostName `
    -DeviceIPAddress $NewDeviceIP

Remove-APICEMServiceTicket 
