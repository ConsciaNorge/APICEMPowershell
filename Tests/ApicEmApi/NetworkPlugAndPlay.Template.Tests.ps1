$null = Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\APICEMPowerShell.psd1') -Force

$APICEMHost = '10.100.11.17'
$APICEMUsername = 'admin'
$APICEMPassword = 'Minions12345'

$ImageFileProductID = "WS-C3850-24P"
$ImageFilePlatformID = "C3850"
$PnpFileTemplateId = 'd6dbd83c-a9da-4afc-abe0-72047ade1a06'
$PnpFileTemplateName = 'LAB_PnP'
$PnpTemplateId = '7b689c55-032b-4080-abe1-1cc3bcaef898'

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

#region Network plug and play template tests
Describe -Name 'Get-APICEMNetworkPlugAndPlayTemplate' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
        It -name 'Should not throw getting a service ticket' -test {
            { Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts } | Should Not Throw
        }
        It -name ('Should not throw getting all templates ') -test {
            { Get-APICEMNetworkPlugAndPlayTemplate } | Should Not Throw
        }
        It -name ('Should not throw getting template by id ') -test {
            { Get-APICEMNetworkPlugAndPlayTemplate -TemplateID $PnpTemplateId } | Should Not Throw
        }
        It -name ('Should throw getting template by bad template id ') -test {
            { Get-APICEMNetworkPlugAndPlayTemplate -TemplateID ([guid]::NewGuid()) } | Should Throw 'Template resource not found.'
        }
        It -name 'Should not throw removing the service ticket' -test {
            { Remove-APICEMServiceTicket } | Should Not Throw
        }
    }
    Context -Name 'Execution' -Fixture {}
    Context -Name 'Output' -Fixture {
        Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts
        $templates = Get-APICEMNetworkPlugAndPlayTemplate
        It -Name 'Should not return null' -test {
            $templates | Should Not BeNullOrEmpty
        }
        Remove-APICEMServiceTicket 
    }
}

#endregion 

