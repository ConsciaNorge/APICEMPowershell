# APIC-EM For PowerShell
The code in this module is intended for a project I'm working on for automating APIC-EM from within Powershell for a large scale network deployment. For the moment, it contains the functions and documentation I need and nothing more. I am willing to expand it upon request and to accept pull requests.

## Contributions
At the time of writing this, the code already contains 50 (hand-tested) API calls to the APIC-EM and automates the process of claiming a device within the limitations which it was needed. 
Contributions are very much welcomed if the code meets the coding guidelines.
As of this time, the code will not pass PSScriptAnalyzer, though in the near future and attempt will be made to do so. The module will likely change name as well and there will be some namespace cleanup.

## Coding guidelines
### Documentation
All commands added to the module must be properly documented with at least one example to operate in a friendly fashion with Get-Help

### Naming
All commands will be (Get|Set|Add|Remove|New)-APICEM(APIC-EM Module)(API Function) this can be seen in all parts of the scope with the exception of APICEMInventoryNetworkDevices.ps1 which was the first code written and might not be up to snuff.

### File structure
* Files should all be .PS1
* Folders should be made for each APIC-EM module
* All commands should be found in their repsective PS1
* All PS1 files should be dot-sourced into the APICEMPowerShell.psm1 file
* All exported commands should be found in APICEMPowerShell.psm1 
* Non-exported code should be found in HelperScripts
* All code should be released under the MIT license... adding the author's name to the top of the module is ok(... if you actually did more than change spacing.)
* Unit tests should be written in the Tests directory and should work when Pester is run. The more thorough the better. I'll post more guidlines on this soon as I haven't had time for full unit tests since I wrote most of this in 2.5 days.
* All non-APIC-EM APIs should be found in APICEMUtility. I'd prefer one exported command per file. If it gets ridiculous, we can add subdirectories the structure.
* Examples should be found in the examples directory. This will be cleaned up soon. 

## Official site
I've docked this in my personal GitHub for now. I'll move this to an official Conscia or Cisco GitHub as soon as we decide where to make it have a home

## Automated code
Cisco's documentation in the APIC-EM repository is relatively poor and it's YAML and other exports are not well done. In many cases, the documentation is written by people who barely speak English. Until Cisco assigns a proper documentation and code-review team to the project, I'd prefer that automated import mechanisms are avoided.

