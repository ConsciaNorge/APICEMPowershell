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

#region Network plug and play config tests
Describe -Name 'Get-APICEMNetworkPlugAndPlayTemplateConfig' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
        It -name 'Should not throw getting a service ticket' -test {
            { Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts } | Should Not Throw
        }
        It -name ('Should not throw getting all template configs ') -test {
            { Get-APICEMNetworkPlugAndPlayTemplateConfig } | Should Not Throw
        }
        It -name 'Should not throw removing the service ticket' -test {
            { Remove-APICEMServiceTicket } | Should Not Throw
        }
    }
    Context -Name 'Execution' -Fixture {}
    Context -Name 'Output' -Fixture {
        Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts
        $templateConfigs = Get-APICEMNetworkPlugAndPlayTemplateConfig
        It -Name 'Should not return null' -test {
            $templateConfigs | Should Not BeNullOrEmpty
        }
        Remove-APICEMServiceTicket 
    }
}

Describe -Name 'Set-APICEMNetworkPlugAndPlayTemplateProperties' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
        It -name 'Should not throw getting a service ticket' -test {
            { Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts } | Should Not Throw
        }
        It -name ('Should not throw creating a template config with default parameters') -test {
            $templates = Get-APICEMNetworkPlugAndPlayTemplate
            { Set-APICEMNetworkPlugAndPlayTemplateProperties -TemplateID $PnpTemplateId -ConfigProperties $templates[0].defaultProperty } | Should Not Throw
        }
        It -name 'Should not throw removing the service ticket' -test {
            { Remove-APICEMServiceTicket } | Should Not Throw
        }
    }
    Context -Name 'Execution' -Fixture {}
    Context -Name 'Output' -Fixture {
        Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts
        It -name ('Creating a template config with default parameters should return a GUID') -test {
            $templates = Get-APICEMNetworkPlugAndPlayTemplate
            $templateConfigId = Set-APICEMNetworkPlugAndPlayTemplateProperties -TemplateID $PnpTemplateId -ConfigProperties $templates[0].defaultProperty 
            { [Guid]::Parse($templateConfigId) } | Should Not Throw
        }
        Remove-APICEMServiceTicket 
    }
}
#endregion 

