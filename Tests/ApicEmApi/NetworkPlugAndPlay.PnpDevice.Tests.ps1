$null = Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\APICEMPowerShell.psd1') -Force

$APICEMHost = '10.100.11.17'
$APICEMUsername = 'admin'
$APICEMPassword = 'Minions12345'

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "", Scope="Function", Target="*")]
$securePassword = ConvertTo-SecureString -asPlainText -Force -String $APICEMPassword
$creds = [System.Management.Automation.PSCredential]::new($APICEMUsername,$securePassword)

#region Cleanup first
try {
    Remove-APICEMServiceTicket -ErrorAction SilentlyContinue
} catch {
    Write-Debug -Message 'No reason to remove the ticket, none has been issued'
}
#endregion

#Clear-Host

#region Inventory Tag Tests
Describe -Name 'Get-APICEMNetworkPlugAndPlayDevice' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
        It -name 'Getting a service ticket should not throw' -test {
            { Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts } | Should Not Throw
        }
        It -name 'Getting network plug and play devices should not throw' -test {        
            { Get-APICEMNetworkPlugAndPlayDevice } | Should Not Throw
        }
        It -name 'Removing a service ticket should not throw' -test {
            { Remove-APICEMServiceTicket } | Should Not Throw
        }
    }
    Context -Name 'Execution' -Fixture {}
    Context -Name 'Output' -Fixture {
        It -name 'Getting a service ticket should not throw' -test {
           Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts
        }
        $pnpDevices = Get-APICEMNetworkPlugAndPlayDevice 
        It -name 'Devices should not be null' -test {
           { $pnpDevices } | Should Not BeNullOrEmpty
        }
        It -name 'Devices should be a PSObject' -test {
           { $pnpDevices } | Should BeOfType PSObject
        }
        It -name 'Devices should contain a hostname field' -test {
           { Get-Member -InputObject $pnpDevices -Name 'hostname' } | Should Not BeNullOrEmpty
        }        
        $pnpDeviceBySerial = Get-APICEMNetworkPlugAndPlayDevice -SerialNumber $pnpDevices[0].serialNumber
        It -name 'Get pnp device by serial number should not be null' -test {
            { $pnpDeviceBySerial } | Should Not BeNullOrEmpty
        }
        It -name 'Get pnp device by serial number should not throw if not exist' -test {
            { Get-APICEMNetworkPlugAndPlayDevice -SerialNumber 'FDO1441P08K' } | Should Not Throw
        }
        It -name 'Removing a service ticket should not throw' -test {
           Remove-APICEMServiceTicket 
        }
    }
}
#endregion 
