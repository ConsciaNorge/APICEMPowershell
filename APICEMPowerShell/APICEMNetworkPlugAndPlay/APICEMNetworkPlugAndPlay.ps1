<#
    .SYNOPSIS
        Returns a list of network plug and play device by device ID

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER DeviceID
        The GUID which represents the device

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayDevice -ApicHost 'apicvip.company.local' -ServiceTicket $serviceTicket -DeviceID '5fb95f97-6558-4c1a-82ca-f732f05acab3'
#>
Function Get-APICEMNetworkPlugAndPlayDevice {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$DeviceID,

        [Parameter()]
        [string]$SerialNumber
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-device'

    if(-not [string]::IsNullOrEmpty($DeviceID)) {
        $uri += '/' + $DeviceID
    } elseif (-not [string]::IsNullOrEmpty($SerialNumber)) {
        $uri += '?serialNumber=' + $SerialNumber
    } else {
        throw [System.ArgumentException]::new(
            'You must supply a device ID or serial number'
        )
    }

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Returns a list of network plug and play devices

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayDevices -ApicHost 'apicvip.company.local' -ServiceTicket $serviceTicket
#>
Function Get-APICEMNetworkPlugAndPlayDevices {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [switch]$Unclaimed
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-device'

    if($Unclaimed) {
        $uri += '?state=UNCLAIMED'
    }

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Returns a plug and play device's history by its serial number

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER SerialNumber
        The serial number of the device to query

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        $devices = Get-APICEMNetworkPlugAndPlayDevices -ApicHost 'apicvip.company.local' -ServiceTicket $serviceTicket
        Get-APICEMNetworkPlugAndPlayDeviceHistory -ApicHost 'apicvip.company.local' -ServiceTicket $serviceTicket -SerialNumber $devices[0].SerialNumber
#>
Function Get-APICEMNetworkPlugAndPlayDeviceHistory {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$SerialNumber
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/pnp-device-history?serialNumber=' + $SerialNumber)

    return $response
}

<#
    .SYNOPSIS
        Returns a list of network plug and play device templates

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayTemplates -ApicHost 'apicvip.company.local' -ServiceTicket $serviceTicket
#>
Function Get-APICEMNetworkPlugAndPlayTemplates {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/template')

    return $response
}

<#
    .SYNOPSIS
        Returns a network plug and play device template

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER TemplateID
        The GUID of the template to retrieve

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayTemplate -TemplateID dc846aaa-0f26-4d08-bbe0-4ae032971b5a
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayTemplate {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$TemplateID, 

        [Parameter()]
        [string]$FileID
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/template'
    if(-not [string]::IsNullOrEmpty($TemplateID)) {
        $uri += '/' + $TemplateID
    } elseif (-not [string]::IsNullOrEmpty($FileID)) {
        $uri += '?fileId=' + $FileID
    } else {
        throw [System.ArgumentException]::new(
            'Either TemplateID or FileID must be specified'
        )
    }

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Returns a list of network plug and play device template files

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        $serviceTicket = Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayFileTemplates -ApicHost 'apicvip.company.local' -ServiceTicket $serviceTicket

    .NOTES
        This is the function which returns the raw template files, the Get-APICEMNetworkPlugAndPlayTemplates returns a list
        of files generated by the templates
#>
Function Get-APICEMNetworkPlugAndPlayFileTemplates {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/pnp-file/template')

    return $response
}

<#
    .SYNOPSIS
        Returns a network plug and play device template file

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER FileId
        The file id of the template to get

    .PARAMETER Name
        The name of the plug and play file object

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayFileTemplate -FileID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a'
        Remove-APICEMServiceTicket

    .NOTES
        This is the function which returns the raw template files, the Get-APICEMNetworkPlugAndPlayTemplates returns a list
        of files generated by the templates
#>
Function Get-APICEMNetworkPlugAndPlayFileTemplate {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$FileId,

        [Parameter()]
        [string]$Name
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-file/template'
    
    if(-not [string]::IsNullOrEmpty($FileID)) {
        $uri += '?fileId=' + $FileId
    } elseif (-not [string]::IsNullOrEmpty($Name)) {
        $uri += '?name=' + $Name
    }

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Returns a list of APIC-EM registered projects

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayProjects
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayProjects {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/pnp-project')

    return $response
}

<#
    .SYNOPSIS
        Returns a specific APIC-EM registered project

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER ProjectID
        The GUID of the project

    .PARAMETER Name
        The name of the project

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayProject -Name 'minions'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayProject {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$ProjectID,

        [Parameter()]
        [string]$Name
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-project'

    if(-not [string]::IsNullOrEmpty($ProjectID)) {
        $uri += '/' + $ProjectID 
    } elseif (-not [string]::IsNullOrEmpty($Name)) {
        $uri += '?siteName=' + $Name 
    } else {
        throw [System.ArgumentException]::new(
            'Either a ProjectID or Name must be specified'
        )
    }

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Returns the devices associated with a plug and play project

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER ProjectID
        The GUID of the project

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayProjectDevices -ProjectID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayProjectDevices {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$ProjectID
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-project/' + $ProjectID + '/device'

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Returns the device associated with a plug and play project and device id

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER ProjectID
        The GUID of the project

    .PARAMETER DeviceID
        The GUID of the device

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayProjectDevice -ProjectID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a' -DeviceID '0ae8e543-ee35-4e15-a268-3121b144d542'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayProjectDevice {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$ProjectID,

        [Parameter(Mandatory)]
        [string]$DeviceID
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-project/' + $ProjectID + '/device/' + $DeviceID

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Returns a list of APIC-EM plug and play platform files

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayPlatforms
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayPlatformFiles {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/pnp-file/platform')

    return $response
}

<#
    .SYNOPSIS
        Returns a list of APIC-EM plug and play active rendered templates in the cache

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayTemplateRenderers
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayTemplateRenderers {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/template-renderer')

    return $response
}

<#
    .SYNOPSIS
        Returns a list of APIC-EM plug and play active rendered template in the cache by ID

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER RendererID
        The template renderer ID representing the rendering job

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayTemplateRenderer -RendererID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayTemplateRenderer {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$RendererID
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/template-renderer/' + $RendererID

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Renders an APIC-EM Template with the given parameters

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER FileId
        The file id of the template to get

    .PARAMETER ConfigProperties
        The properties to pass to the template for rendering

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        $configProperties = @{
            Parameter1 = 'Hello'
            Parameter2 = 'World'
        }
        $renderJob = Render-APICEMNetworkPlugAndPlayFileTemplate -FileID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a' -ConfigProperties $configProperties
        Remove-APICEMServiceTicket
#>
Function Render-APICEMNetworkPlugAndPlayFileTemplate {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$FileId,

        [Parameter(Mandatory)]
        $ConfigProperties
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/template-renderer'

    $requestObject = @(
        @{
            fileId = $FileId
            configProperty = $ConfigProperties
        }
    )

    $response = Internal-APICEMPostRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject

    return $response
}

<#
    .SYNOPSIS
        Returns a list of APIC-EM plug and play template configs

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayTemplateConfigs
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayTemplateConfigs {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/template-config')

    return $response
}

<#
    .SYNOPSIS
        Returns a list of APIC-EM plug and play template configs

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayTemplateConfigs
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayTemplateConfigs {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri ('https://' + $session.ApicHost + '/api/v1/template-config')

    return $response
}

<#
    .SYNOPSIS
        Returns an APIC-EM plug and play template config

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER ConfigID
        The GUID of the template config to return

    .PARAMETER TemplateID
        The GUID of template which the config is associated

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayTemplateConfig -ConfigID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a'
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayTemplateConfig {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$ConfigID,

        [Parameter()]
        [string]$TemplateID
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/template-config'

    if(-not [string]::IsNullOrEmpty($ConfigID)) {
        $uri += '/' + $ConfigID
    } elseif (-not [string]::IsNullOrEmpty($TemplateID)) {
        $uri += '?templateId=' + $TemplateID
    } else {
        throw [System.ArgumentException]::new(
            'Either ConfigID or TemplateID must be provided'
        )
    }

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Sets the configuration properties for an APIC-EM plug and play template

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER TemplateID
        The GUID of the template to the set parameters on

    .PARAMETER ConfigProperties
        The properties to pass to the template for rendering

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        $configProperties = @{
            Parameter1 = 'Hello'
            Parameter2 = 'World'
        }
        $templatePropertiesJob = Set-APICEMNetworkPlugAndPlayTemplateProperties -TemplateID 'dc846aaa-0f26-4d08-bbe0-4ae032971b5a' -ConfigProperties $configProperties
        Remove-APICEMServiceTicket
#>
Function Set-APICEMNetworkPlugAndPlayTemplateProperties {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$TemplateID,

        [Parameter(Mandatory)]
        $ConfigProperties
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/template-config'

    $requestObject = @(
        @{
            templateId = $TemplateID
            configProperty = $ConfigProperties
        }
    )

    $response = Internal-APICEMPostRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject

    return $response
}

<#
    .SYNOPSIS
        Claims a plug and play device within a project (Create a new device under a given project)

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER ProjectID
        The GUID of the APIC-EM project

    .PARAMETER PlatformID
        The GUID of the platform of the device (see Get-APICEMNetworkPlugAndPlayPlatformFiles)

    .PARAMETER HostName
        The hostname of the device to claim

    .PARAMETER HasAAA
        Specifies that the configuration template has AAA

    .PARAMETER SerialNumber
        The serial number of the device to claim

    .PARAMETER PkiEnabled
        Configures whether the device should have PKI enabled

    .PARAMETER SudiRequired
        Configures whether a secure device unique identifier is required

    .PARAMETER TemplateConfigID
        The GUID of the template config to apply to the device

    .PARAMETER ImageId
        The ImageId (GUID) of the IOS (or other firmware) to apply to the claimed device

    .PARAMETER Role
        The device role as it should be configured in the inventory (ACCESS/DISTRIBUTION/CORE)

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        $parameters = @{
            HasAAA = '262'
            HostName = 'PIZZAHUT'
            PlatformId = 'WS-C3560CX-12TC'
            SerialNumber = 'FOC8675X309'
            PkiEnabled = $false
            SudiRequired = $false
            TemplateConfigId = '9e5c9259-9125-4c9b-859b-bc5cb3ead1c3'
        }
        $claimDeviceJob = Add-APICEMNetworkPlugAndPlayProjectDevice @parameters
        Remove-APICEMServiceTicket
#>
Function Add-APICEMNetworkPlugAndPlayProjectDevice {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$ProjectID,

        [Parameter()]
        [string]$HasAAA,

        [Parameter(Mandatory)]
        [string]$HostName,

        [Parameter(Mandatory)]
        [string]$PlatformId,

        [Parameter()]
        [string]$SerialNumber,

        [Parameter()]
        [bool]$PkiEnabled,

        [Parameter()]
        [bool]$SudiRequired,

        [Parameter()]
        [string]$TemplateConfigId,

        [Parameter()]
        [string]$ImageId,

        [Parameter()]
        [string]$DeviceRole
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-project/' + $ProjectID + '/device'

    $deviceSettings = New-Object -TypeName 'PSCustomObject'
    if(-not [string]::IsNullOrEmpty($HasAAA)) { Add-Member -InputObject $deviceSettings -Name 'hasAAA' -Value $HasAAA -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($Hostname)) { Add-Member -InputObject $deviceSettings -Name 'hostName' -Value $Hostname -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($PlatformId)) { Add-Member -InputObject $deviceSettings -Name 'platformId' -Value $PlatformId -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SerialNumber)) { Add-Member -InputObject $deviceSettings -Name 'serialNumber' -Value $SerialNumber -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('PkiEnabled')) { Add-Member -InputObject $deviceSettings -Name 'pkiEnabled' -Value $PkiEnabled -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('SudiRequired')) { Add-Member -InputObject $deviceSettings -Name 'sudiRequired' -Value $SudiRequired -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($TemplateConfigId)) { Add-Member -InputObject $deviceSettings -Name 'templateConfigId' -Value $TemplateConfigId -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($ImageId)) { Add-Member -InputObject $deviceSettings -Name 'imageId' -Value $ImageId -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($DeviceRole)) { Add-Member -InputObject $deviceSettings -Name 'role' -Value $DeviceRole -MemberType NoteProperty }

    $requestObject = @(
        $deviceSettings
    )

    $response = Internal-APICEMPostRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject

    return $response
}

<#
    .SYNOPSIS
        Returns a list of images and the platforms for which they are a default

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayImages
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayImages {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-file/image'

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response.images
}

<#
    .SYNOPSIS
        Returns the default image for a given platform or product ID

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER PlatformID
        The name of the platform (example C3850)

    .PARAMETER ProductID
        The name of the product (example WS-C3850-24P)

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMNetworkPlugAndPlayImageDefault
        Remove-APICEMServiceTicket
#>
Function Get-APICEMNetworkPlugAndPlayImageDefault {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [string]$PlatformID,

        [Parameter()]
        [string]$ProductID
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-file/image/default'

    if(-not [string]::IsNullOrEmpty($PlatformID)) {
        $uri += '?platformId=' + $PlatformID
    } elseif (-not [string]::IsNullOrEmpty($ProductID)) {
        $uri += '?productId=' + $ProductID
    }

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}

<#
    .SYNOPSIS
        Creates a new APIC-EM PnP project

    .PARAMETER ApicHost
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER Name
        The name of the project

    .PARAMETER ProvisionedBy
        The name of the user who provisioned the project

    .PARAMETER TFTPServer
        TFTP Server Host name or IP

    .PARAMETER TFTPPath
        TFTP Server path

    .PARAMETER Notes
        Notes to be stored with the project

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        $newProjectJob = New-APICEMNetworkPlugAndPlayProject -Name 'Minions'
        Remove-APICEMServiceTicket
#>
Function New-APICEMNetworkPlugAndPlayProject {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [string]$ProvisionedBy,

        [Parameter()]
        [string]$TFTPServer,

        [Parameter()]
        [string]$TFTPPath,

        [Parameter()]
        [string]$Notes
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri = 'https://' + $session.ApicHost + '/api/v1/pnp-project'

    $site = New-Object -TypeName 'PSCustomObject'
    if(-not [string]::IsNullOrEmpty($Name)) { Add-Member -InputObject $site -Name 'siteName' -Value $Name -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($ProvisionedBy)) { Add-Member -InputObject $site -Name 'provisionedBy' -Value $ProvisionedBy -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($TFTPServer)) { Add-Member -InputObject $site -Name 'tftpServer' -Value $TFTPServer -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($TFTPPath)) { Add-Member -InputObject $site -Name 'tftpPath' -Value $TFTPPath -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($Notes)) { Add-Member -InputObject $site -Name 'note' -Value $Notes -MemberType NoteProperty }

    $requestObject = @(
        $site
    )

    $response = Internal-APICEMPostRequest -ServiceTicket $session.ServiceTicket -Uri $uri -BodyValue $requestObject

    return $response
}
