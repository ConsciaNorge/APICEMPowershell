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
        [string]$HostIP,

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
        [string]$HostName,

        [Parameter()]
        [bool]$PkiEnabled,

        [Parameter()]
        [bool]$SudiRequired
    )

    $session = Internal-APICEMHostIPAndServiceTicket -HostIP $HostIP -ServiceTicket $ServiceTicket        

    # Get the plug and play network device object corresponding to the device serial number
    $plugAndPlayDevice = Get-APICEMNetworkPlugAndPlayDevice -SerialNumber $SerialNumber
    if($null -eq $plugAndPlayDevice) {
        throw [System.Exception]::new(
            'Could not find APIC-EM Plug and Play network device [' + $SerialNumber + ']'
        )
    }

    # Get a handle to the file template corresponding to the given file name
    $fileTemplate = Get-APICEMNetworkPlugAndPlayFileTemplate -Name $TemplateFilename

    if($null -eq $fileTemplate) {
        throw [System.IO.FileNoteFoundException]::new(
            'Could not find template file on APIC-EM [' + $TemplateFileName + ']'
        )
    }

    # Get the template object referred to by the file template object
    $template = Get-APICEMNetworkPlugAndPlayTemplate -FileID $fileTemplates.id
    if($null -eq $template) {
        throw [System.Exception]::new(
            'Fatal error, could not find PnP template referenced by PnP template file [' + $TemplateFileName + ']' 
        )
    }

    # TODO : Verify that all unset parameters needed by Velocity script are provided
    # $fileContents = Get-APICEMFile -FileID $fileTemplate.id
    # $requiredConfigValues = (Get-VelocityDocumentInformation -Source $fileContents).UnsetVariables

    # Create a template configuration that links a template and a set of configuration properties
    $templateConfigJob = Set-APICEMNetworkPlugAndPlayTemplateProperties -TemplateID $template.id -ConfigProperties $ConfigProperties
    $templateConfigStatus = Wait-APICEMTaskEnded -TaskID $templateConfigJob.taskId

    # If the template configuration failed to create, throw and exception
    if($null -eq $templateConfigStatus) {
        throw [System.Exception]::new(
            'Timeout while creating template configuration'
        )
    }

    # Extract the template configuration job result from the task status
    $templateConfigJobResult = ConvertFrom-JSON $templateConfigStatus.progress

    # Verify the existance of the newly created template configuration
    $templateConfig = Get-APICEMNetworkPlugAndPlayTemplateConfig -ConfigID $templateConfigJobResult.id

    if($null -eq $templateConfig) {
        throw [System.Exception]::new(
            'Failed to obtain a copy of the newly created template configuration'
        )
    }
    
    # Get the plug and play project information
    $project = Get-APICEMNetworkPlugAndPlayProject -Name $ProjectName
    
    if($null -eq $project) {
        throw [System.Exception]::new(
            'Failed to get information about the PnP project [' + $projectName + ']'
        )
    }

    # Claim the device
    $claimDeviceParameters = @{
        ProjectID = $project.id 
        HostName = $HostName
        PlatformId = $plugAndPlayDevice.platformId 
        SerialNumber = $SerialNumber 
        PkiEnabled = $PkiEnabled 
        SudiRequired = $SudiRequired 
        TemplateConfigId = $templateConfig.id
    }
    $claimDeviceJob = Add-APICEMNetworkPlugAndPlayProjectDevice @claimDeviceParameters

    $claimDeviceStatus = Wait-APICEMTaskEnded -TaskID $claimDeviceJob.taskId

    if($null -eq $claimDeviceStatus) {
        throw [System.Exception]::new(
            'Timeout while claiming Plug and Play Network Device ' + $unclaimedDevice.serialNumber
        )
    }

    $claimDeviceJobResult = ConvertFrom-JSON $claimDeviceStatus.progress
    
    return $claimDeviceJobResult
}