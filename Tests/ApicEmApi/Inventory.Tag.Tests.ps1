$null = Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\APICEMPowerShell.psd1') -Force

$APICEMHost = '10.100.11.17'
$APICEMUsername = 'admin'
$APICEMPassword = 'Minions12345'

$InventoryDeviceHostName = 'dcsw1.nocturnal.local'

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "", Scope="Function", Target="*")]
$securePassword = ConvertTo-SecureString -asPlainText -Force -String $APICEMPassword
$creds = [System.Management.Automation.PSCredential]::new($APICEMUsername,$securePassword)

#region Cleanup first
try {
    Remove-APICEMServiceTicket -ErrorAction SilentlyContinue
} catch {
    Write-Debug -Message 'No reason to remove the ticket, none has been issued'
}

Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts
try {
    Remove-APICEMInventoryTag -Name 'PizzaPizza' -ErrorAction SilentlyContinue
} catch {
    Write-Debug -Message 'No reason to remove PizzaPizza, it probably does not exist'
}
Remove-APICEMServiceTicket 
#endregion

#Clear-Host

#region Inventory Tag Tests
Describe -Name 'Create and delete inventory tag' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
        It -name 'Getting a service ticket should not throw' -test {
            { Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts } | Should Not Throw
        }
        It -name 'Creating a new inventory tag should not throw' -test {
            { New-APICEMInventoryTag -Name 'PizzaPizza' } | Should Not Throw
        }
        It -name 'Removing an inventory tag should not throw' -test {
            { Remove-APICEMInventoryTag -Name 'PizzaPizza' } | Should Not Throw
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
        It -name 'Removing a known to be absent inventory tag should throw' -test {
           { Remove-APICEMInventoryTag -Name 'UglyDuckling' } | Should Throw 'Could not find APIC-EM inventory tag UglyDuckling'
        }
        It -name 'Creating a new inventory tag without -NoWait should return a GUID' -test {
           $inventoryTagId = New-APICEMInventoryTag -Name 'PizzaPizza' 
           { [GUID]::Parse($inventoryTagId) } | Should Not Throw 
        }
        It -name 'Removing an inventory tag should succeed' -test {
           Remove-APICEMInventoryTag -Name 'PizzaPizza' | Should BeLike 'Tag * deleted successfully'
        }
        It -name 'Removing a service ticket should not throw' -test {
           Remove-APICEMServiceTicket 
        }
    }
}
#endregion 
