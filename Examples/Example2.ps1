Clear-Host

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\APICEMPowerShell\APICEMPowerShell.psd1') -Force

# $user = 'admin'
# $pass = 'Minions12345'
# $apicEMHostIP = '10.100.11.17'

$user = 'darren'
$pass = 'Minions12345'
$apicEMHostIP = '172.16.96.68'

Function Add-APICEMClaimDeviceWithTemplate
{
    Param(
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$SerialNumber,

        [Parameter(Mandatory)]
        [string]$TemplateName,

        [Parameter(Mandatory)]
        [string]$DeviceHostName,

        [Parameter(Mandatory)]
        [string]$DeviceIPAddress,

        [Parameter(Mandatory)]
        [string]$Location,

        [Parameter()]
        [string]$LocationDescription,

        [Parameter()]
        [switch]$Force
    )

    # Check to see if the ApicHost and ServiceTicket are valid (they can be blank too)
    if((-not [string]::IsNullOrEmpty($ApicHost)) -or (-not [string]::IsNullOrEmpty($ServiceTicket))) {
        if([string]::IsNullOrEmpty($ApicHost) -or [string]::IsNullOrEmpty($ServiceTicket)) {
            throw [System.ArgumentException]::new(
                'If providing HostIP or ServiceTicket, then both must be provided'
            )
        }

        $session = @{
            ApicHost = $ApicHost
            ServiceTicket = $ServiceTicket
        }
    }

    # Get the unclaimed device by its serial number
    Write-Verbose -Message ('Getting information about device with serial number : ' + $SerialNumber)
    $unclaimedDevice = Get-APICEMNetworkPlugAndPlayDevice @session -SerialNumber $SerialNumber
    if($null -eq $unclaimedDevice) {
        throw [System.Exception]::new(
            'Failed to find APIC-EM PnP device [' + $SerialNumber + ']'
        )
    }

    # We'll expect to continue with provisioning the device unless we discover a reason not to.
    $continueProvision = $true

    # Attempt to parse the Project Name, Site Number, Device type, Device role and Site Description from the DeviceHostName
    Write-Verbose -Message ('Extracting settings from hostname : ' + $DeviceHostName)
    $hostNameBreakdown = [RegEx]::Match($DeviceHostName, '^(?<ProjectName>[A-Z][A-Z0-9]*)-(?<SiteNumber>\d{5})-(?<DeviceType>[RSF])(?<DeviceRole>[A-D])-(?<Description>[A-Z][A-Z0-9]*)$')
    if(($null -eq $hostNameBreakdown) -or (-not $hostNameBreakdown.Success)) {
        throw [System.ArgumentException]::new(
            'Hostname should be formatted as ''{Project Name}-{Site Number(5)}-{Device Type(R|S|F)}{Device Role(C|D|A|B)}-{Description}'', example : ABC-12345-SA-MINIONSRULE',
            $DeviceHostName
        )
    }

    # Expand the device role to a name
    $deviceRole = switch($hostNameBreakdown.Groups['DeviceRole'].Value) {
        'A' { 'Access' }
        'B' { 'Border Router' }
        'C' { 'Core' }
        'D' { 'Distribution' }
        default { throw [System.Exception]::new('Invalid DeviceHostname format: valid device roles = C,D,A or B') }
    }
    Write-Verbose -Message ('Identified device to be claimed as role : ' + $deviceRole)

    # Expand the device type to a name
    $deviceType = switch($hostNameBreakdown.Groups['DeviceType'].Value) {
        'S' { 'Switch' }
        'R' { 'Router' }
        'F' { 'Firewall' }
        default { throw [System.Exception]::new('Invalid DeviceHostname format: valid device roles = S,R,F') }
    }
    Write-Verbose -Message ('Identified device to be claimed as type : ' + $deviceType)

    # Extract the project name
    $projectName = $hostNameBreakdown.Groups['ProjectName'].Value
    Write-Verbose -Message ('Identified project name to be : ' + $projectName)

    # Get the project. If it doesn't exist attempt to create it
    Write-Verbose -Message ('Querying APIC-EM for existing project : ' + $projectName)
    $project = Get-APICEMNetworkPlugAndPlayProject @session -Name $projectName
    if($null -eq $project) {
        if($Force) {
            Write-Verbose -Message ('Attempting to create project with name ' + $projectName)
            $newProjectJob = New-APICEMNetworkPlugAndPlayProject @session -Name $projectName
            $newProjectStatus = Wait-APICEMTaskEnded @session -TaskID $newProjectJob.taskId

            if($null -eq $newProjectStatus) {
                throw [System.Exception]::new(
                    'Failed to create new project [' + $ProjectName + ']'
                )
            }

            $newProjectResult = ConvertFrom-JSON $newProjectStatus.progress
            $project = Get-APICEMNetworkPlugAndPlayProject @session -ProjectID $newProjectResult.siteId
            Write-Verbose -Message ('Project ' + $projectName + ' created and is identified by APIC-EM as ' + $project.id)
        } else {
            Write-Error -Message ('Project [' + $projectName + '] does not exist, use -Force to create it')
            $continueProvision = $false
        }
    }

    # Get the location ID. If the location doesn't exist, attempt to create it
    # TODO : Consider making not found return more gracefully to avoid silently continue
    Write-Verbose -Message ('Querying APIC-EM for existing location : ' + $Location)
    $locationObject = Get-APICEMInventoryLocation @session -Name $Location -ErrorAction SilentlyContinue
    if($null -eq $locationObject) {
        if($Force) {
            Write-Verbose -Message ('Attempting to create APIC-EM location : ' + $Location)
            $newLocationJob = New-APICEMInventoryLocation @session -Name $Location -Description $LocationDescription 
            $newLocationStatus = Wait-APICEMTaskEnded @session -TaskID $newLocationJob.taskId

            if($null -eq $newLocationStatus) {
                throw [System.Exception]::new(
                    'Failed to create new location[' + $Location + ']'
                )
            }

            $newLocationId = $newLocationStatus.progress

            $locationObject = Get-APICEMInventoryLocation @session -LocationID $newLocationId
            Write-Verbose -Message ('Location ' + $Location + ' created and is identified by APIC-EM as ' + $locationObject.id)
        } else {
            Write-Error -Message ('Location [' + $Location + '] does not exist, use -Force to create it')
            $continueProvision = $false
        }
    }

    if($continueProvision) {
        # These are the variable that are used by the template. If more values are needed
        # they can be added here by name. If you use $HAPPY as a value in your script, then
        # you should define 'HAPPY' here.
        $configValues = @{
            'deviceDescription'  = $hostNameBreakdown.Groups['Description'].Value # Description extracted from hostname
            'deviceHostname'     = $DeviceHostName                                # User provided hostname for the device
            'deviceIpAddress'    = $DeviceIPAddress                               # User provided new IP address for the device (meant for when changing VLANs)
            'deviceRole'         = $deviceRole                                    # Device role (Access|Distribution|Core|Branch Router) extracted from hostname
            'deviceType'         = $deviceType                                    # Device type (Switch|Router|Firewall) extracted from hostname
            'firmwareVersion'    = $unclaimedDevice.versionString                 # IOS version reported by APIC-EM's PnP API for the PnP device
            'productID'          = $unclaimedDevice.platformId                    # PlatformID the platform ID reported by APIC-EM's PnP API for the PnP device
            'projectName'        = $projectName                                   # The first part of the user provided hostname preceeding the first hyphen in the name
            'rootStoragePath'    = $unclaimedDevice.fileDestination               # The file destination (root drive) reported by APIC-EM for the PnP device
            'siteNumber'         = $hostNameBreakdown.Groups['SiteNumber'].Value  # The site number, a series of digits extracted from the second part of the user provided hostname
        }

        # These are the arguments passed to the code which actually does all the work claiming
        # a device. Be comfortable with "advanced powershell" before changing this structure.
        $claimDeviceParams = @{
            SerialNumber       = $unclaimedDevice.serialNumber
            TemplateFileName   = $TemplateName
            ProjectName        = $projectName
            ConfigProperties   = $configValues
            Hostname           = $DeviceHostName
            PkiEnabled         = $unclaimedDevice.pkiEnabled
            SudiRequired       = $unclaimedDevice.sudiRequired
        }

        Write-Verbose -Message ('Begining process of claiming PnP device with serial number : ' + $SerialNumber)
        # Claim the device and return the result
        $claimedDevice = Add-APICEMClaimedDevice @session @claimDeviceParams -UseDefaultImage

        if($null -eq $claimedDevice) {
            throw [System.Exception]::new(
                'Failed to claim PnP device [' + $DeviceHostName + ']'
            )
        }

        Write-Verbose -Message ('APIC-EM PnP device ' + $DeviceHostName + ' is claimed, beginning provisioning process')
        Write-Warning -Message ('This step will generally require rebooting the device. Please be patient, if this does not succeed, this process will fail after 10 minutes')
        # Wait for the device to be provisioned
        $provisioned = Wait-APICEMDeviceProvisioned @session -SerialNumber $SerialNumber

        if(-not $provisioned) {
            throw [System.TimeoutException]::new(
                'Failed to provision claimed device ' + $DeviceHostName + ' within APIC-EM. Manual intervention within APIC-EM required'
            )
        }

        Write-Verbose -Message ('Device ' + $DeviceHostName + ' provisioned within APIC-EM. Beginning process to add the device to the device inventory')
        # Add the device to the inventory
        $discoveredDeviceId = Add-APICEMDeviceToInventory @session -IPAddress $DeviceIPAddress -DiscoveryJobName ('DISCOVERY-' + $DeviceHostName)

        if([string]::IsNullOrEmpty($discoveredDeviceId)) {
            throw [System.Exception]::new(
                'Failed to discover device [' + $DeviceHostName + '] at IP address [' + $DeviceIPAddress + ']'
            )
        }

        Write-Verbose -Message ('Device ' + $DeviceHostName + ' is discovered as APIC-EM ID ' + $discoveredDeviceId + ' waiting for it to be found in the inventory')
        $presentInInventory = Wait-APICEMDeviceInInventory -SerialNumber $SerialNumber
        if(-not $provisioned) {
            throw [System.TimeoutException]::new(
                'Failed to make device ' + $DeviceHostName + ' present within APIC-EM inventory. Manual intervention within APIC-EM required'
            )
        }
        
        # Set the device inventory location
        Write-Verbose -Message ('Device found in inventory, setting device location to : ' + $Location)
        $setLocationJob = Set-APICEMNetworkDeviceLocation @session -DeviceId $discoveredDeviceId -LocationID $locationObject.id
        $setLocationStatus = Wait-APICEMTaskEnded @session -TaskID $setLocationJob.taskId

        if($null -eq $setLocationStatus) {
            throw [System.Exception]::new(
                'Failed to associate location[' + $Location + '] with the newly provisioned device'
            )
        }

        # Set the device role
        Write-Verbose -Message ('Device location set, setting device role to : ' + $deviceRole)
        $setRoleJob = Set-APICEMNetworkDeviceRole @session -DeviceId $discoveredDeviceId -DeviceRole $deviceRole
        $setRoleStatus = Wait-APICEMTaskEnded @session -TaskID $setRoleJob.taskId

        if($null -eq $setRoleStatus) {
            throw [System.Exception]::new(
                'Failed to associate role[' + $deviceRole + '] with the newly provisioned device'
            )
        }

        Write-Verbose -Message ('Device role set. Job complete')

        return $discoveredDeviceId
    }

    throw [System.Exception]::new(
        'Failed to provision device, refer to error messages above and correct them before continuing'
    )
}

# Get the service ticket which is basically a session token... kind of like a cookie
Get-APICEMServiceTicket -ApicHost $apicEMHostIP -Username $user -Password $pass -IgnoreBadCerts

# Get a list of unclaimed network devices
$unclaimedPlugAndPlayDevices = Get-APICEMNetworkPlugAndPlayDevices -Unclaimed

# Display a list with just the serial number, ip address and platform ID of each device
$unclaimedPlugAndPlayDevices | Select-Object serialNumber,ipAddress,platformId | Out-Host

# Randomly take the first unclaimed device to test with
$DeviceToClaim = $unclaimedPlugAndPlayDevices[0]

# Claim the device
Add-APICEMClaimDeviceWithTemplate -Verbose -SerialNumber $DeviceToClaim.serialNumber -TemplateName 'Template_PnP_V001' -DeviceHostName 'NSN-15243-SD-PIZZAHUT' -Location 'RagingMonkey' -LocationDescription 'Fear the force of the chimp' -Force -DeviceIPAddress $DeviceToClaim.IPAddress

# Logs out of the APIC-EM
Remove-APICEMServiceTicket 
