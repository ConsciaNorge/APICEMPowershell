$null = Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\APICEMPowerShell.psd1') -Force

$APICEMHost = '10.100.11.17'
$APICEMUsername = 'admin'
$APICEMPassword = 'Minions12345'

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "", Scope="Function", Target="*")]
$securePassword = ConvertTo-SecureString -asPlainText -Force -String $APICEMPassword
$creds = [System.Management.Automation.PSCredential]::new($APICEMUsername,$securePassword)

#Clear-Host
try {
    Remove-APICEMServiceTicket -ErrorAction SilentlyContinue
} catch {
    Write-Debug -Message 'No reason to remove the ticket, none has been issued'
}

#region Global Tests
Describe -Name 'APICEMPowershell Module Load' -Tag $Global -Fixture {
    Context -Name 'Input' -Fixture {
    }
    Context -Name 'Execution' -Fixture {
        It -Name 'There should be 46 commands.' -test {
            $Commands = @(Get-Command -Module 'APICEMPowerShell' | Select-Object -ExpandProperty Name)
            $Commands.Count | Should Be 46
        }
    }
    Context -Name 'Output' -Fixture {
    }
}

Describe -Name 'Get-APICEMServiceTicket' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
        It -name 'Getting a service ticket should not throw' -test {
            { Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts } | Should Not Throw
        }
        It -name 'Removing a service ticket should not throw' -test {
            { Remove-APICEMServiceTicket } | Should Not Throw
        }
    }
    Context -Name 'Execution' -Fixture {}
    Context -Name 'Output' -Fixture {
        It -Name 'Should return a ticket starting with ST-' -test {
            $Command = @(Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts -Passthru)
            $Command | Should BeLike "ST-*"
            Remove-APICEMServiceTicket -ApicHost $APICEMHost -ServiceTicket $Command[0]
        }
    }
}
#endregion 
