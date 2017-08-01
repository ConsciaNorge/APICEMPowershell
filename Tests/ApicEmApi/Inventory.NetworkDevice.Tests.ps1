$null = Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\APICEMPowerShell.psd1') -Force

$APICEMHost = '10.100.11.17'
$APICEMUsername = 'admin'
$APICEMPassword = 'Minions12345'

$InventoryDeviceHostName = 'dcsw1.nocturnal.local'
$InventoryDeviceSerialNumber = 'FDO1441P08L'

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
        It -name 'Calling Get-APICEMNetworkDevice not throw' -test {
            { Get-APICEMNetworkDevice } | Should Not Throw
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
        Remove-APICEMServiceTicket 
    }
}

Describe -Name 'Get-APICEMNetworkDevice with serial number' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
        It -name 'Getting a service ticket should not throw' -test {
            { Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts } | Should Not Throw
        }
        It -name 'Calling Get-APICEMNetworkDevice should not throw' -test {
            { Get-APICEMNetworkDevice -SerialNumber $InventoryDeviceSerialNumber } | Should Not Throw
        }
        It -name 'Removing a service ticket should not throw' -test {
            { Remove-APICEMServiceTicket } | Should Not Throw
        }
    }
    Context -Name 'Execution' -Fixture {}
    Context -Name 'Output' -Fixture {
        Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts
        $networkDevices = Get-APICEMNetworkDevice -SerialNumber $InventoryDeviceSerialNumber
        It -Name 'Network device should not be null' -test {
            $networkDevices | Should Not BeNullOrEmpty
        }
        It -Name 'Network device should be a PSCustomObject' -test {
            $networkDevices | Should BeOfType PSCustomObject
        }
        It -Name 'Network device should have a member called hostname' -test {
            $networkDevices | Get-Member -Name 'hostname' | Should Not BeNullOrEmpty
        }
        It -Name ('Network devices hostname should be ' + $InventoryDeviceHostName) -test {
            $networkDevices.hostname | Should Be $InventoryDeviceHostName
        }
        It -Name ('Get-APICEMNetworkDevice by serial number should throw if device does not exist') -test {
            { Get-APICEMNetworkDevice -SerialNumber 'FDO1441P08K' } | Should Throw 'No Device found with Serial Number : FDO1441P08K'
        }
        Remove-APICEMServiceTicket 
    }
}
#endregion 
