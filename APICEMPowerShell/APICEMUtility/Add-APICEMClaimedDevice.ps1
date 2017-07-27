<#
This code is written and maintained by Darren R. Starr from Conscia Norway AS.

License :

Copyright (c) 2017 Conscia Norway AS

Permission is hereby granted, free of charge, to any person obtaining a 
copy of this software and associated documentation files (the "Software"), 
to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software 
is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

<#
    .SYNOPSIS
        Command to claim a network device within APIC-EM

    .NOTES
        This is not an APIC-EM API, it is a utility command that is built upon
        APIC-EM API primitives.

        Got some help here from https://communities.cisco.com/servlet/JiveServlet/showImage/38-8381-102160/summary-api.png
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
        [bool]$SudiRequired,

        [Parameter()]
        [string]$DeviceRole,

        [Parameter()]
        [switch]$UseDefaultImage
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    # Get the plug and play network device object corresponding to the device serial number
    $plugAndPlayDevice = Get-APICEMNetworkPlugAndPlayDevice @session -SerialNumber $SerialNumber
    if($null -eq $plugAndPlayDevice) {
        throw [System.Exception]::new(
            'Could not find APIC-EM Plug and Play network device [' + $SerialNumber + ']'
        )
    }

    # Get the default image id if it is available    
    $imageId = $null
    if($UseDefaultImage) {
        # TODO : Trim -S (license info) from end if necessary 
        $defaultImage = Get-APICEMNetworkPlugAndPlayImageDefault @session -ProductID $plugAndPlayDevice.platformId
        if($null -ne $defaultImage) {
            $imageId = $defaultImage.imageId
        }
    }

    # Get a handle to the file template corresponding to the given file name
    $fileTemplate = Get-APICEMNetworkPlugAndPlayFileTemplate @session -Name $TemplateFilename

    if($null -eq $fileTemplate) {
        throw [System.IO.FileNoteFoundException]::new(
            'Could not find template file on APIC-EM [' + $TemplateFileName + ']'
        )
    }

    # Get the template object referred to by the file template object
    $template = Get-APICEMNetworkPlugAndPlayTemplate @session -FileID $fileTemplate.id
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

    # Prepare the argument splat for claiming the device
    $claimDeviceParameters = @{
        ProjectID = $project.id 
        HostName = $Hostname
        PlatformId = $plugAndPlayDevice.platformId 
        SerialNumber = $SerialNumber 
        PkiEnabled = $PkiEnabled 
        SudiRequired = $SudiRequired 
        TemplateConfigId = $templateConfig.id
        ImageId = $imageId
        DeviceRole = $DeviceRole
    }

    # Claim the device
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
