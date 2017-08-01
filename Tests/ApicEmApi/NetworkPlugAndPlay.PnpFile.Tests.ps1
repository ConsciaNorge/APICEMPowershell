$null = Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\APICEMPowerShell.psd1') -Force

$APICEMHost = '10.100.11.17'
$APICEMUsername = 'admin'
$APICEMPassword = 'Minions12345'

$ImageFileProductID = "WS-C3850-24P"
$ImageFilePlatformID = "C3850"
$PnpFileTemplateId = 'd6dbd83c-a9da-4afc-abe0-72047ade1a06'
$PnpFileTemplateName = 'LAB_PnP'

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

#region Network plug and play file tests
Describe -Name 'Get-APICEMNetworkPlugAndPlayImageDefault' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
        It -name 'Should not throw getting a service ticket' -test {
            { Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts } | Should Not Throw
        }
        It -name ('Should not throw getting image default for unspecified platform or product') -test {
            { Get-APICEMNetworkPlugAndPlayImageDefault } | Should Not Throw
        }
        It -name ('Should not throw getting image default for platform ' + $ImageFilePlatformID) -test {
            { Get-APICEMNetworkPlugAndPlayImageDefault -PlatformID $ImageFilePlatformID } | Should Not Throw
        }
        It -name ('Should not throw getting image default for product ' + $ImageFileProductID) -test {
            { Get-APICEMNetworkPlugAndPlayImageDefault -ProductID $ImageFileProductID } | Should Not Throw
        }
        It -name 'Should not throw removing the service ticket' -test {
            { Remove-APICEMServiceTicket } | Should Not Throw
        }
    }
    Context -Name 'Execution' -Fixture {}
    Context -Name 'Output' -Fixture {
        Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts
        $imageFiles = Get-APICEMNetworkPlugAndPlayImageDefault
        It -Name 'Should not return null' -test {
            $imageFiles | Should Not BeNullOrEmpty
        }
        # It -Name 'Should be an object array' -test {
        #     $imageFiles | Should BeOfType Object[]
        # }
        It -Name 'Should return 6 platform files' -test {
            $imageFiles.Count | Should Be 7
        }
        $imageFilesForPlatform = Get-APICEMNetworkPlugAndPlayImageDefault -PlatformID $ImageFilePlatformID
        It -Name ('Should not return null for platform : ' + $ImageFilePlatformID) -test {
            $imageFilesForPlatform | Should Not BeNullOrEmpty
        }
        It -Name 'Should return 2 platform files' -test {
            $imageFilesForPlatform.Count | Should Be 2
        }
        # $imageFilesForProduct = Get-APICEMNetworkPlugAndPlayImageDefault -ProductID $ImageFileProductID
        # It -Name ('Should not return null for product : ' + $ImageFileProductID) -test {
        #     $imageFilesForProduct | Should Not BeNullOrEmpty
        # }
        # It -Name 'Should return 2 product files' -test {
        #     $imageFilesForProduct.Count | Should Be 2
        # }
        
        Remove-APICEMServiceTicket 
    }
}

Describe -Name 'Get-APICEMNetworkPlugAndPlayFileTemplate' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
        It -name 'Should not throw getting a service ticket' -test {
            { Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts } | Should Not Throw
        }
        It -name ('Should not throw getting all file templates') -test {
            { Get-APICEMNetworkPlugAndPlayFileTemplate } | Should Not Throw
        }
        It -name ('Should not throw getting file template by file template id') -test {
            { Get-APICEMNetworkPlugAndPlayFileTemplate -FileTemplateId $PnpFileTemplateId } | Should Not Throw
        }
        It -name ('Should not throw getting file template by unknown file template id') -test {
            { Get-APICEMNetworkPlugAndPlayFileTemplate -FileTemplateId ([GUID]::NewGUID()) } | Should Not Throw
        }
        It -name ('Should not throw getting file template by file name') -test {
            { Get-APICEMNetworkPlugAndPlayFileTemplate -Name $PnpFileTemplateName } | Should Not Throw
        }
        It -name ('Should not throw getting file template by unknown file name') -test {
            { Get-APICEMNetworkPlugAndPlayFileTemplate -Name 'BOBKEVINSTUART' } | Should Not Throw
        }
        It -name 'Should not throw removing the service ticket' -test {
            { Remove-APICEMServiceTicket } | Should Not Throw
        }
    }
    Context -Name 'Execution' -Fixture {}
    Context -Name 'Output' -Fixture {
        Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts
        $fileTemplates = Get-APICEMNetworkPlugAndPlayFileTemplate
        It -Name 'Should not return null' -test {
            $fileTemplates | Should Not BeNullOrEmpty
        }
        $fileTemplateById = Get-APICEMNetworkPlugAndPlayFileTemplate -FileTemplateId $PnpFileTemplateId
        It -Name 'Getting plug and play file template by ID should not be null' -test {
            { $fileTemplateById } | Should Not BeNullOrEmpty
        }
        # $fileTemplateByBadId = Get-APICEMNetworkPlugAndPlayFileTemplate -FileTemplateId ([guid]::NewGuid())
        # It -Name 'Getting plug and play file template by ID should not be null' -test {
        #     $fileTemplateByBadId | Should BeNullOrEmpty
        # }
        $fileTemplateByName = Get-APICEMNetworkPlugAndPlayFileTemplate -Name $PnpFileTemplateName
        It -Name 'Getting plug and play file template by name should not be null' -test {
            $fileTemplateByName | Should Not BeNullOrEmpty
        }
        $fileTemplateByBadName = Get-APICEMNetworkPlugAndPlayFileTemplate -Name 'BOBKEVINSTUART'
        It -Name 'Getting plug and play file template by bad name should be null' -test {
            $fileTemplateByBadName | Should BeNullOrEmpty
        }

        Remove-APICEMServiceTicket 
    }
}
#endregion 

