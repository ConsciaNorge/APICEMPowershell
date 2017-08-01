$null = Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\APICEMPowerShell.psd1') -Force

$APICEMHost = '10.100.11.17'
$APICEMUsername = 'admin'
$APICEMPassword = 'Minions12345'

$PnPExistingProjectName = 'FILET_MINIONS'
$PnPExistingProjectId = '779afb3f-a6fd-442c-ae3f-736a107024f1'
$claimDeviceParameters = @{
    HasAAA = '262'
    HostName = 'PIZZAHUT'
    PlatformId = 'WS-C3560CX-12TC'
    SerialNumber = 'FOC8675X309'
    PkiEnabled = $false
    SudiRequired = $false
    TemplateConfigId = '9e5c9259-9125-4c9b-859b-bc5cb3ead1c3'
}

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

#region Network plug and play project tests
Describe -Name 'Get-APICEMNetworkPlugAndPlayProject' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
        It -name 'Should not throw getting a service ticket' -test {
            { Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts } | Should Not Throw
        }
        It -name ('Should not throw getting all projects') -test {
            { Get-APICEMNetworkPlugAndPlayProject } | Should Not Throw
        }
        It -name ('Should not throw getting project by name') -test {
            { Get-APICEMNetworkPlugAndPlayProject -Name $PnPExistingProjectName } | Should Not Throw
        }
        It -name ('Should not throw getting project by bad name') -test {
            { Get-APICEMNetworkPlugAndPlayProject -Name 'FUNKY-CHICKEN' } | Should Not Throw
        }
        It -name ('Should not throw getting project by id') -test {
            { Get-APICEMNetworkPlugAndPlayProject -ProjectID $PnPExistingProjectId } | Should Not Throw
        }
        It -name ('Should throw getting project by bad id') -test {
            { Get-APICEMNetworkPlugAndPlayProject -ProjectID ([Guid]::NewGuid()) } | Should Throw 'Pnp project not found.'
        }
        It -name 'Should not throw removing the service ticket' -test {
            { Remove-APICEMServiceTicket } | Should Not Throw
        }
    }
    Context -Name 'Execution' -Fixture {}
    Context -Name 'Output' -Fixture {
        Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts
        $projects = Get-APICEMNetworkPlugAndPlayProject
        It -Name 'Getting all projects should not return null' -test {
            $projects | Should Not BeNullOrEmpty
        }
        It -Name ('Gettings all projects should contain project ' + $PnPExistingProjectName) -test {
            { ($projects | Where-Object { $_.Name -eq $PnPExistingProjectName }) } | Should Not BeNullOrEmpty
        }
        $projectByName = Get-APICEMNetworkPlugAndPlayProject -Name $PnPExistingProjectName
        It -Name ('Gettings projects by name should not be null') -test {
            $projectByName | Should Not BeNullOrEmpty
        }
        It -Name ('Gettings projects by name should have the right name') -test {
            $projectByName.siteName | Should Be $PnPExistingProjectName
        }
        It -Name ('Gettings projects by bad name should be null') -test {
            $badNameProject = Get-APICEMNetworkPlugAndPlayProject -Name 'FUNKY-CHICKEN' 
            $badNameProject | Should BeNullOrEmpty
        }
        $projectById = Get-APICEMNetworkPlugAndPlayProject -ProjectID $PnPExistingProjectId
        It -Name ('Gettings projects by id should not be null') -test {
            $projectById | Should Not BeNullOrEmpty
        }        
        $projectById = Get-APICEMNetworkPlugAndPlayProject -ProjectID $PnPExistingProjectId
        It -Name ('Gettings projects by id should have the right name') -test {
            $projectById.siteName | Should Be $PnPExistingProjectName
        }        
        Remove-APICEMServiceTicket 
    }
}
Describe -Name 'Add-APICEMNetworkPlugAndPlayProjectDevice and Remove-APICEMNetworkPlugAndPlayProjectDevice' -Tags $Utility -Fixture {
    Context -Name 'Input' -Fixture {
    }
    Context -Name 'Execution' -Fixture {}
    Context -Name 'Output' -Fixture {
        Get-APICEMServiceTicket -ApicHost $APICEMHost -Credentials $creds -IgnoreBadCerts
        $script:claimedDevice = $null
        $pnpProject = Get-APICEMNetworkPlugAndPlayProject -Name $PnPExistingProjectName

        It -Name 'Claiming a PnP device should not throw' -test {
            { $script:claimedDeviceId = Add-APICEMNetworkPlugAndPlayProjectDevice @claimDeviceParameters -ProjectID $pnpProject.id } | Should Not Throw
        }
        It -Name 'Claiming a device should  not return null' -test {
            $script:claimedDeviceId | Should Not BeNullOrEmpty
        }
        It -Name 'Claiming a device should return a GUID' -test {
            { [Guid]::Parse($script:claimedDeviceId) } | Should Not Throw
        }
        It -Name 'Getting project device should not throw' -test {
            { $script:claimedDevice = Get-APICEMNetworkPlugAndPlayProjectDevice -ProjectID $pnpProject.id -SerialNumber $claimDeviceParameters.SerialNumber } | Should Not Throw
        }
        It -Name 'Claimed device should not be null' -test {
            $script:claimedDevice | Should Not BeNullOrEmpty
        }
        It -Name ('Claimed device serial number should be ' + $claimDeviceParameters.SerialNumber) -test {
            $script:claimedDevice.serialNumber | Should Be $claimDeviceParameters.SerialNumber
        }
        It -Name ('Claimed device hostname should be ' + $claimDeviceParameters.HostName) -test {
            $script:claimedDevice.hostName | Should Be $claimDeviceParameters.HostName
        }
        It -Name 'Claimed device state should be pending' -test {
            $script:claimedDevice.state | Should Be 'PENDING'
        }
        It -Name 'Unclaiming a PnP device should not throw' -test {
            { $script:unclaimResult = Remove-APICEMNetworkPlugAndPlayProjectDevice -ProjectID $pnpProject.id -DeviceID $script:claimedDevice.id } | Should Not Throw
        }
        It -Name ('Unclaimed device result should be "' + 'Success Deleting Site Device(Rule): id# ' + $script:claimedDevice.id) -test {
            $script:unclaimResult | Should Be ('Success Deleting Site Device(Rule): id# ' + $script:claimedDevice.id)
        }
        Remove-APICEMServiceTicket 
    }
}
#endregion 

