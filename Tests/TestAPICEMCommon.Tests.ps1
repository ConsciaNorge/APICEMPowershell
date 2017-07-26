Clear-ApicHost

$null = Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\APICEMPowerShell\APICEMPowerShell.psd1') -Force

$APICEMHost = '10.100.11.17'
$APICEMUsername = 'admin'
$APICEMPassword = 'Minions12345'

#region Global Tests
Describe -Name 'APICEMPowershell Module Load' -Tag $Global -Fixture {
  Context -Name 'Input' -Fixture {
  }
  Context -Name 'Execution' -Fixture {
    It -Name 'There should be 6 commands.' -test {
      $Commands = @(Get-Command -Module 'APICEMPowerShell' | Select-Object -ExpandProperty Name)
      $Commands.Count | Should Be 6
    }
  }
  Context -Name 'Output' -Fixture {
  }
}

Describe -Name 'Get-APICEMServiceTicket' -Tags $Utility -Fixture {
  Context -Name 'Input' -Fixture {
    It -name 'Should not throw' -test {
      { Get-APICEMServiceTicket -ApicHost $APICEMHost -Username $APICEMUsername -Password $APICEMPassword } | Should Not Throw
    }
  }
  Context -Name 'Execution' -Fixture {}
  Context -Name 'Output' -Fixture {
	  It -Name 'Should produce correct output' -test {
		  $Command = @(Get-APICEMServiceTicket -ApicHost $APICEMHost -Username $APICEMUsername -Password $APICEMPassword)
      $Command | Should BeLike "ST-*"
	  }
  }
}
#endregion 
