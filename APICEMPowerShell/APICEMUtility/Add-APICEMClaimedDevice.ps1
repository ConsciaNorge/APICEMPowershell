<#
    .SYNOPSIS
        Command to claim a network device within APIC-EM

    .NOTES
        This is not an APIC-EM API, it is a utility command that is built upon
        APIC-EM API primitives.
#>
Function Add-APICEMClaimedDevice
{
    Param(
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$SerialNumber,

        [Parameter(Mandatory)]
        [string]$TemplateFilename,

        [Parameter(Mandatory)]
        [string]$ProjectName,

        [Parameter(Mandatory)]
        $ConfigProperties,

        [Parameter()]
        [string]$HasAAA,

        [Parameter(Mandatory)]
        [string]$Hostname,

        [Parameter()]
        [bool]$PkiEnabled,

        [Parameter()]
        [bool]$SudiRequired
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    Write-Host "Finding network device"
    # Get the plug and play network device object corresponding to the device serial number
    $plugAndPlayDevice = Get-APICEMNetworkPlugAndPlayDevice @session -SerialNumber $SerialNumber
    if($null -eq $plugAndPlayDevice) {
        throw [System.Exception]::new(
            'Could not find APIC-EM Plug and Play network device [' + $SerialNumber + ']'
        )
    }

    Write-Host "Getting plug and play file template"
    # Get a handle to the file template corresponding to the given file name
    $fileTemplate = Get-APICEMNetworkPlugAndPlayFileTemplate @session -Name $TemplateFilename

    if($null -eq $fileTemplate) {
        throw [System.IO.FileNoteFoundException]::new(
            'Could not find template file on APIC-EM [' + $TemplateFileName + ']'
        )
    }

    # Get the template object referred to by the file template object
    $template = Get-APICEMNetworkPlugAndPlayTemplate @session -FileID $fileTemplates.id
    if($null -eq $template) {
        throw [System.Exception]::new(
            'Fatal error, could not find PnP template referenced by PnP template file [' + $TemplateFileName + ']' 
        )
    }

    # TODO : Verify that all unset parameters needed by Velocity script are provided
    # $fileContents = Get-APICEMFile -FileID $fileTemplate.id
    # $requiredConfigValues = (Get-VelocityDocumentInformation -Source $fileContents).UnsetVariables

    # Create a template configuration that links a template and a set of configuration properties
    $templateConfigJob = Set-APICEMNetworkPlugAndPlayTemplateProperties @session -TemplateID $template.id -ConfigProperties $ConfigProperties
    $templateConfigStatus = Wait-APICEMTaskEnded @session -TaskID $templateConfigJob.taskId

    # If the template configuration failed to create, throw and exception
    if($null -eq $templateConfigStatus) {
        throw [System.Exception]::new(
            'Timeout while creating template configuration'
        )
    }

    # Extract the template configuration job result from the task status
    $templateConfigJobResult = ConvertFrom-JSON $templateConfigStatus.progress

    # Verify the existance of the newly created template configuration
    $templateConfig = Get-APICEMNetworkPlugAndPlayTemplateConfig @session -ConfigID $templateConfigJobResult.id

    if($null -eq $templateConfig) {
        throw [System.Exception]::new(
            'Failed to obtain a copy of the newly created template configuration'
        )
    }
    
    # Get the plug and play project information
    $project = Get-APICEMNetworkPlugAndPlayProject @session -Name $ProjectName
    
    if($null -eq $project) {
        throw [System.Exception]::new(
            'Failed to get information about the PnP project [' + $projectName + ']'
        )
    }

    # Claim the device
    $claimDeviceParameters = @{
        ProjectID = $project.id 
        HostName = $Hostname
        PlatformId = $plugAndPlayDevice.platformId 
        SerialNumber = $SerialNumber 
        PkiEnabled = $PkiEnabled 
        SudiRequired = $SudiRequired 
        TemplateConfigId = $templateConfig.id
    }

    $claimDeviceJob = Add-APICEMNetworkPlugAndPlayProjectDevice @session @claimDeviceParameters
    $claimDeviceStatus = Wait-APICEMTaskEnded @session -TaskID $claimDeviceJob.taskId

    if($null -eq $claimDeviceStatus) {
        throw [System.Exception]::new(
            'Timeout while claiming Plug and Play Network Device ' + $unclaimedDevice.serialNumber
        )
    }

    # Extract the job result from the task status
    $claimDeviceJobResult = ConvertFrom-JSON $claimDeviceStatus.progress
    
    return $claimDeviceJobResult
}
