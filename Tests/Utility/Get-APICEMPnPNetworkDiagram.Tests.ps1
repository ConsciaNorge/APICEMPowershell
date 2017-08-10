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
            { $script:pnpDevices = Get-APICEMNetworkPlugAndPlayDevice } | Should Not Throw
        }
        It -name 'Generating a network diagram should not throw' -test {        
            { $script:dot = Get-APICEMPnPNetworkDiagram -PnpDevices $script:pnpDevices -SwitchIconPath (Join-Path -Path $PSScriptRoot -ChildPath 'switchicon.ps1') } | Should Not Throw
        }
        Set-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath 'testdot.vz') -Value $script:dot
        It -name 'Removing a service ticket should not throw' -test {
            { Remove-APICEMServiceTicket } | Should Not Throw
        }
    }
    Context -Name 'Execution' -Fixture {}
    Context -Name 'Output' -Fixture {
    }
}
#endregion 
