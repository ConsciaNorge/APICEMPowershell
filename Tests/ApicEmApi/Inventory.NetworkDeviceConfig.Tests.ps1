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
Describe -Name 'Get-APICEMNetworkDeviceConfig' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
        It -name 'Getting a service ticket should not throw' -test {
            { Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts } | Should Not Throw
        }
        It -name 'Get a network device config by ID should not throw' -test {
            { Get-APICEMNetworkDeviceConfig -DeviceId $InventoryDeviceId } | Should Not Throw            
        }
        It -name 'Get a network device config by bad ID should throw' -test {
            $testId = [Guid]::NewGuid()
            { Get-APICEMNetworkDeviceConfig -DeviceId $testId } | Should Throw ('No device found with id ' + $testId)            
        }
        It -name 'Removing a service ticket should not throw' -test {
            { Remove-APICEMServiceTicket } | Should Not Throw
        }
    }
    Context -Name 'Execution' -Fixture {}
    Context -Name 'Output' -Fixture {
        Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts
        It -Name 'Get-APICEMNetworkDeviceConfig should not return null' -test {
            $script:deviceConfig = Get-APICEMNetworkDeviceConfig -DeviceId $InventoryDeviceId 
            $script:deviceConfig | Should Not BeNullOrEmpty
        }
        It -Name 'Get-APICEMNetworkDeviceConfig should return a string' -test {
            $script:deviceConfig | Should BeOfType System.String
        }
        It -Name 'Device config starts with Building configuration' -test {
            $script:deviceConfig | Should BeLike 'Building configuration*'
        }
        Remove-APICEMServiceTicket 
    }
}
#endregion 
