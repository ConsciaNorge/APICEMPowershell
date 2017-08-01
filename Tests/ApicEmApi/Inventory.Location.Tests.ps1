$null = Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\APICEMPowerShell.psd1') -Force

$APICEMHost = '10.100.11.17'
$APICEMUsername = 'admin'
$APICEMPassword = 'Minions12345'

$InventoryDeviceHostName = 'dcsw1.nocturnal.local'
$InventoryDeviceId = '90488b4d-34be-4a44-b9e5-0909768fdad1'
$InventorySerialNumber = 'FDO1441P08L'

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
    $location = Get-APICEMInventoryLocation -Name 'MinionVille'
    Remove-APICEMInventoryLocation -LocationID $location.id -ErrorAction SilentlyContinue
} catch {
    Write-Debug -Message 'No reason to remove PizzaPizza, it probably does not exist'
}
Remove-APICEMServiceTicket 
#endregion

#Clear-Host

#region Inventory Location Tests
Describe -Name 'Create and delete inventory location' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
        It -name 'Getting a service ticket should not throw' -test {
            { Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts } | Should Not Throw
        }
        It -name 'Creating a new inventory location should not throw' -test {
            { New-APICEMInventoryLocation -Name 'MinionVille' } | Should Not Throw
        }
        It -name 'Getting a handle to the new location should not throw' -test {
            { $script:newLocation = Get-APICEMInventoryLocation -Name 'MinionVille' } | Should Not Throw
        }
        It -name 'Removing an inventory locations should not throw' -test {
            { Remove-APICEMInventoryLocation -LocationID $script:newLocation.id } | Should Not Throw
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
        It -name 'Removing a known to be absent inventory location should throw' -test {
           $testId = [Guid]::NewGuid()
           { Remove-APICEMInventoryLocation -LocationID $testId } | Should Throw 
        }
        It -name 'Creating a new inventory location without -NoWait should return a GUID' -test {
           $script:inventoryLocationId = New-APICEMInventoryLocation -Name 'MinionVille' 
           { [GUID]::Parse($script:inventoryLocationId) } | Should Not Throw 
        }
        It -name 'Removing an inventory location should succeed' -test {
           Remove-APICEMInventoryLocation -LocationID $script:inventoryLocationId | Should BeLike 'Location deleted successfully #*'
        }
        It -name 'Removing a service ticket should not throw' -test {
           Remove-APICEMServiceTicket 
        }
    }
}
#endregion 
