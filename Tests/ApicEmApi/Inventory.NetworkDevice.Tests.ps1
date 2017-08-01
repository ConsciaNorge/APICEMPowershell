$null = Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\APICEMPowerShell.psd1') -Force

$APICEMHost = '10.100.11.17'
$APICEMUsername = 'admin'
$APICEMPassword = 'Minions12345'

$InventoryDeviceHostName = 'dcsw1.nocturnal.local'
$InventoryDeviceSerialNumber = 'FDO1441P08L'
$InventoryDeviceIPAddress = '10.100.1.1'
$InventoryDeviceId = '90488b4d-34be-4a44-b9e5-0909768fdad1'

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "", Scope="Function", Target="*")]
$securePassword = ConvertTo-SecureString -asPlainText -Force -String $APICEMPassword
$creds = [System.Management.Automation.PSCredential]::new($APICEMUsername,$securePassword)

try {
    Remove-APICEMServiceTicket -ErrorAction SilentlyContinue
} catch {
    Write-Debug -Message 'No reason to remove the ticket, none has been issued'
}

#Clear-Host

#region Inventory NetworkDevices Tests
Describe -Name 'Get-APICEMNetworkDevice' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
        It -name 'Getting a service ticket should not throw' -test {
            { Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts } | Should Not Throw
        }
        It -name 'Get all inventory devices should not throw' -test {
            { Get-APICEMNetworkDevice } | Should Not Throw            
        }
        It -name 'Get inventory device by id should not throw' -test {
            { Get-APICEMNetworkDevice -DeviceID $InventoryDeviceId } | Should Not Throw            
        }
        It -name 'Get inventory device by known absent id should throw' -test {
            $testBadId = [Guid]::NewGUID()
            { Get-APICEMNetworkDevice -DeviceID $testBadId } | Should Throw ('No Device found with ID : ' + $testBadId) 
        }
        It -name 'Get inventory device by serial number should not throw' -test {
            { Get-APICEMNetworkDevice -SerialNumber $InventoryDeviceSerialNumber } | Should Not Throw            
        }
        It -name 'Get inventory device by known wrong serial number should throw' -test {
            { Get-APICEMNetworkDevice -SerialNumber 'FDO2551P18L' } | Should Throw 'No Device found with Serial Number : FDO2551P18L'            
        }
        It -name 'Get inventory device by host name should not throw' -test {
            { Get-APICEMNetworkDevice -Hostname $InventoryDeviceHostName } | Should Not Throw            
        }
        It -name 'Get inventory device by known missing host name should not throw' -test {
            { Get-APICEMNetworkDevice -Hostname 'humptydance' } | Should Not Throw            
        }
        It -name 'Get inventory device by IP address should not throw' -test {
            { Get-APICEMNetworkDevice -IPAddress $InventoryDeviceIPAddress } | Should Not Throw            
        }
        It -name 'Get inventory device by known missing host name should not throw' -test {
            { Get-APICEMNetworkDevice -IPAddress '192.168.99.99' } | Should Throw 'No Device found with IP Address : 192.168.99.99'            
        }
        It -name 'Removing a service ticket should not throw' -test {
            { Remove-APICEMServiceTicket } | Should Not Throw
        }
    }
    Context -Name 'Execution' -Fixture {}
    Context -Name 'Output' -Fixture {
        Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts
        $networkDevices = Get-APICEMNetworkDevice
        It -Name 'Network devices should not be null' -test {
            $networkDevices | Should Not BeNullOrEmpty
        }
        It -Name 'Network devices should be a PSCustomObject' -test {
            $networkDevices | Should BeOfType PSCustomObject
        }
        It -Name 'Network devices should have a member called hostname' -test {
            $networkDevices | Get-Member -Name 'hostname' | Should Not BeNullOrEmpty
        }
        It -Name ('Network devices hostname should be ' + $InventoryDeviceHostName) -test {
            $networkDevices.hostname | Should Be $InventoryDeviceHostName
        }
        It -Name 'Get network device by serial number should not return null' -test {
            $script:networkDevice = Get-APICEMNetworkDevice -SerialNumber $InventoryDeviceSerialNumber
            $script:networkDevice | Should Not BeNullOrEmpty
        }
        It -Name 'Get network device by serial number should return only one device' -test {
            $script:networkDevice | Should BeOfType PSCustomObject
        }
        It -Name 'Get network device by serial number should have the serial number requested' -test {
            $script:networkDevice.serialNumber | Should Be $InventoryDeviceSerialNumber
        }
        It -Name 'Get network device by id should not return null' -test {
            $script:networkDevice = Get-APICEMNetworkDevice -DeviceID $InventoryDeviceId
            $script:networkDevice | Should Not BeNullOrEmpty
        }
        It -Name 'Get network device by id should return only one device' -test {
            $script:networkDevice | Should BeOfType PSCustomObject
        }
        It -Name 'Get network device by id should have the id requested' -test {
            $script:networkDevice.id | Should Be $InventoryDeviceId
        }
        It -Name 'Get network device by IP address should not return null' -test {
            $script:networkDevice = Get-APICEMNetworkDevice -IPAddress $InventoryDeviceIPAddress
            $script:networkDevice | Should Not BeNullOrEmpty
        }
        It -Name 'Get network device by IP address should return only one device' -test {
            $script:networkDevice | Should BeOfType PSCustomObject
        }
        It -Name 'Get network device by IP address should have the IP address requested' -test {
            $script:networkDevice.managementIpAddress | Should Be $InventoryDeviceIPAddress
        }
        It -Name 'Get network device by hostname should not return null' -test {
            $script:networkDevice = Get-APICEMNetworkDevice -Hostname $InventoryDeviceHostName
            $script:networkDevice | Should Not BeNullOrEmpty
        }
        It -Name 'Get network device by hostname should return only one device' -test {
            $script:networkDevice | Should BeOfType PSCustomObject
        }
        It -Name 'Get network device by hostname should have the hostname requested' -test {
            $script:networkDevice.hostname | Should Be $InventoryDeviceHostName
        }
        Remove-APICEMServiceTicket 
    }
}
#endregion 
