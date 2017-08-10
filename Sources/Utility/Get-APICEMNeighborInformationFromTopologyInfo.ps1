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

Function Get-CiscoInterfaceShortName
{
    Param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $match = [RegEx]::Matches($Name, '(?<abbr>[A-Z][A-Za-z])[A-Za-z]*(?<number>[0-9]+(\/[0-9]+)*)')

    return $match[0].Groups['abbr'].Value + $match[0].Groups['number'].Value
}

<#
    .SYNOPSIS
        Parses the topologyInformation data returned by Get-APICEMNetworkPlugAndPlayDevice

    .PARAMETER TopologyInfo
        The topologyInformation string returned by Get-APICEMNetworkPlugAndPlayDevice

    .EXAMPLE
        $devices = Get-APICEMNetworkPlugAndPlayDevice -Unclaimed
        $neighborInformation = Get-APICEMNeighborInformationFromTopologyInfo -TopologyInfo $devices[0].topologyInfo

    .NOTES
        While this information is useful by itself, when used through Get-APICEMNetworkTopologyFromPnPDevices,
        a full network topology is represented.

        Also, short interface names are provided as a bonus so that it's not necessary to translate them when
        needed for network diagramming
#>
Function Get-APICEMNeighborInformationFromTopologyInfo {
    Param(
        [Parameter(Mandatory)]
        [string]$TopologyInfo
    )

    $neighborLinkMatches = [RegEx]::Matches($TopologyInfo, 'neighborLink:\s+Local Interface\=(?<localInterface>[A-Z][A-Za-z]*([0-9]+(\/[0-9]+)*(\.\d+)?))\sLocal MacAddress\=(?<localMacAddress>[0-9A-Fa-f]{4}(\.[0-9A-Fa-f]{4}){2})\s+Remote Interface\=(?<remoteInterface>[A-Z][A-Za-z]*([0-9]+(\/[0-9]+)*(\.\d+)?))\s+Remote MacAddress\=(?<remoteMacAddress>[0-9A-Fa-f]{4}(\.[0-9A-Fa-f]{4}){2})\s+Remote DeviceName\=(?<remoteDeviceName>\S+)\s+Remote Platform\=(?<remotePlatform>[^;]*);\s+')
    
    return $neighborLinkMatches.foreach{
        [PSCustomObject]@{
            LocalInterface = $_.Groups['localInterface'].Value
            LocalInterfaceShort = Get-CiscoInterfaceShortName -Name $_.Groups['localInterface'].Value
            LocalMACAddress = $_.Groups['localMacAddress'].Value
            RemoteInterface = $_.Groups['remoteInterface'].Value
            RemoteInterfaceShort = Get-CiscoInterfaceShortName -Name $_.Groups['remoteInterface'].Value
            RemoteMACAddress = $_.Groups['remoteMacAddress'].Value
            RemoteDeviceName = $_.Groups['remoteDeviceName'].Value
            RemotePlatform = $_.Groups['remotePlatform'].Value
            RemoteSerialNumber = ''
        }
    }   
}
