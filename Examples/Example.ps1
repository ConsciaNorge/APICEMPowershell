Clear-Host

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\APICEMPowerShell\APICEMPowerShell.psd1') -Force

$user = 'admin'
$pass = 'Minions12345'
$apicEMHostIP = '10.100.11.17'

<#
    This code is a Powershell workaround to allow self-signed certificates to be used without installing it as a trust 
#>
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;

        public class IDontCarePolicy : ICertificatePolicy {
        public IDontCarePolicy() {}
        public bool CheckValidationResult(
            ServicePoint sPoint, X509Certificate cert,
            WebRequest wRequest, int certProb) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = new-object IDontCarePolicy 


# Get the service ticket which is basically a session token... kind of like a cookie
$serviceTicket = Get-APICEMServiceTicket -HostIP $apicEMHostIP -Username 'admin' -Password 'Minions12345'

# Make a simply session structure to avoid having to pass all the values all the time
$apicEMSession = @{
    HostIP = $apicEMHostIP
    ServiceTicket = $serviceTicket
}

$networkDevices = Get-APICEMNetworkDevices @apicEMSession 

$networkDeviceConfig = Get-APICEMNetworkDeviceConfig @apicEMSession -DeviceId $networkDevices.id

$networkDeviceModules = Get-APICEMNetworkDeviceModules @apicEMSession -DeviceId $networkDevices.id

$networkDeviceManagementInfo = Get-APICEMNetworkDeviceManagementInfo @apicEMSession -DeviceId $networkDevices.id

$networkDevicelocation = Get-APICEMNetworkDeviceLocation @apicEMSession -DeviceId $networkDevices.id

$networkDevice = Get-APICEMNetworkDevice @apicEMSession -SerialNumber $networkDevices.serialNumber

$plugAndPlayDevices = Get-APICEMNetworkPlugAndPlayDevices @apicEMSession

$deviceHistory = Get-APICEMNetworkPlugAndPlayDeviceHistory @apicEMSession -SerialNumber $plugAndPlayDevices[0].serialNumber

$plugAndPlayDevice = Get-APICEMNetworkPlugAndPlayDevice @apicEMSession -DeviceID $plugAndPlayDevices[0].id

$templates = Get-APICEMNetworkPlugAndPlayTemplates @apicEMSession 

$templateFile = Get-APICEMFile @apicEMSession -FileID $templates[0].fileId

$result = Remove-APICEMServiceTicket @apicEMSession
