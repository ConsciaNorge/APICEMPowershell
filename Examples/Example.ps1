Clear-Host

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\APICEMPowerShell.psd1') -Force

$username = 'admin'
$password = 'Minions12345'
$apicEMHostIP = '10.100.11.17'

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', 'result')]
$result = Remove-APICEMServiceTicket -ErrorAction SilentlyContinue

# $user = 'darren'
# $pass = 'Minions12345'
# $apicEMHostIP = '172.16.96.68'


[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "", Scope="Function", Target="*")]
$securePassword = ConvertTo-SecureString -asPlainText -Force -String $password

$creds = [System.Management.Automation.PSCredential]::new($username,$securePassword)


# Get the service ticket which is basically a session token... kind of like a cookie
#Get-APICEMServiceTicket -ApicHost $apicEMHostIP -Username $user -Password $pass
Get-APICEMServiceTicket -ApicHost $apicEMHostIP -Credentials $creds

# Make a simply session structure to avoid having to pass all the values all the time

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', 'networkDevices')]
$networkDevices = Get-APICEMNetworkDevice

#$networkDeviceConfig = Get-APICEMNetworkDeviceConfig -DeviceId $networkDevices[0].id

New-APICEMInventoryDiscovery -Name 'DAVE' -UsernameList @('Bob') -PasswordList @('Minions8675309') -IPAddressList '172.16.1.1' -DiscoveryType 'single' -ProtocolOrder 'ssh'

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$networkDeviceModules = Get-APICEMNetworkDeviceModules -DeviceId $networkDevices[0].id

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$networkDeviceManagementInfo = Get-APICEMNetworkDeviceManagementInfo -DeviceId $networkDevices[0].id

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$networkDevicelocation = Get-APICEMNetworkDeviceLocation -DeviceId $networkDevices[0].id

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$networkDevice = Get-APICEMNetworkDevice -SerialNumber $networkDevices[0].serialNumber

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$plugAndPlayDevices = Get-APICEMNetworkPlugAndPlayDevices 

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$unclaimedPlugAndPlayDevices = Get-APICEMNetworkPlugAndPlayDevices -Unclaimed

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$deviceHistory = Get-APICEMNetworkPlugAndPlayDeviceHistory  -SerialNumber $plugAndPlayDevices[0].serialNumber

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$plugAndPlayDevice = Get-APICEMNetworkPlugAndPlayDevice -DeviceId $plugAndPlayDevices[0].id

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$templates = Get-APICEMNetworkPlugAndPlayTemplates  

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$templateFile = Get-APICEMFile -FileID $templates[0].fileId



[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$fileTemplates = Get-APICEMNetworkPlugAndPlayFileTemplates

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$fileTemplateContent = Get-APICEMFile -FileID $fileTemplates[0].id

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$fileNamespaces = Get-APICEMFileNamespaces 

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$configFileNamespace = Get-APICEMFileNamespace -Namespace 'config'

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$templateFileNamespace = Get-APICEMFileNamespace -Namespace 'template'

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$imageFileNamespace = Get-APICEMFileNamespace -Namespace 'image'

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$pnpProjects = Get-APICEMNetworkPlugAndPlayProjects

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$pnpProjectById = Get-APICEMNetworkPlugAndPlayProject -ProjectID $pnpProjects[0].id

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$pnpProjectByName = Get-APICEMNetworkPlugAndPlayProject -Name $pnpProjects[1].siteName

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$pnpProjectDevices = Get-APICEMNetworkPlugAndPlayProjectDevices -ProjectID $pnpProjects[0].id

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$pnpPlatformFiles = Get-APICEMNetworkPlugAndPlayPlatformFiles  

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$activeTemplateRenderers = Get-APICEMNetworkPlugAndPlayTemplateRenderers

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$templateIndex = 3


[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$rendererJob = Render-APICEMNetworkPlugAndPlayFileTemplate -FileID $templates[$templateIndex].fileId -ConfigProperties $templates[$templateIndex].defaultProperty

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$taskStatusTree = Get-APICEMTask -TaskID $rendererJob.taskId -tree
while((($taskStatusTree | Get-Member | Where-Object { $_.Name -eq 'endTime' }).Count) -eq 0) {
    Start-Sleep -Seconds 1
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
    $taskStatusTree = Get-APICEMTask -TaskID $rendererJob.taskId -tree
}

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$progress = ConvertFrom-Json $taskStatusTree.progress

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$templateRenderer = Get-APICEMNetworkPlugAndPlayTemplateRenderer -RendererID $progress.Id

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$templateConfigs = Get-APICEMNetworkPlugAndPlayTemplateConfigs

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$templateConfig = Get-APICEMNetworkPlugAndPlayTemplateConfig -TemplateID $templates[2].id

$templateConfigParameters = @{
    ProductID = ""
    SWITCHTYPE = "undefined"
    HOSTNAME = ""
    SWITCHTYPE_ADC = "undefined"
    PVLAN = ""
    PALOALTO = ""
    DOWNLINK = "undefined"
    IFPORT = "undefined"
    IPSPILT = "undefined"
    'IP-ADDRESS' = ""
    EEMTIMER = "undefined"
    KRONNAME = "undefined"
}

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$setTemplateConfigJob = Set-APICEMNetworkPlugAndPlayTemplateProperties -TemplateID $templates[$templateIndex].id -ConfigProperties $templateConfigParameters
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$templateConfigJobTree = Get-APICEMTask -TaskID $setTemplateConfigJob.taskId -tree
while((($templateConfigJobTree | Get-Member | Where-Object { $_.Name -eq 'endTime' }).Count) -eq 0) {
    Start-Sleep -Seconds 1
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
    $templateConfigJobTree = Get-APICEMTask -TaskID $setTemplateConfigJob.taskId -tree
}

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$configProgress = ConvertFrom-Json $templateConfigJobTree.progress


[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$parameters = @{
    ProjectID = $pnpProjects[1].id
    HasAAA = '262'
    HostName = 'NBN-12345-SA-PIZZAHUT'
    PlatformId = 'WS-C3560CX-12TC'
    SerialNumber = 'FOC2103Z355'
    PkiEnabled = $false
    SudiRequired = $false
    TemplateConfigId = $configProgress.id
}
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$claimDeviceJob = Add-APICEMNetworkPlugAndPlayProjectDevice @parameters

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
$claimDeviceJobTree = Get-APICEMTask -TaskID $claimDeviceJob.taskId -tree
while((($claimDeviceJobTree | Get-Member | Where-Object { $_.Name -eq 'endTime' }).Count) -eq 0) {
    Start-Sleep -Seconds 1
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment')]
    $claimDeviceJobTree = Get-APICEMTask -TaskID $claimDeviceJob.taskId -tree
}

