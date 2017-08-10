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
        Returns a network topology built from identifying relationships between PnP devices

    .DESCRIPTION
        The information returned from this function is useful for mapping a network topology which
        has not yet been claimed. Get-APICEMNetworkPlugAndPlayDevice returns topology information in
        the terms of CDP neighbor information. The information returned is on a device by device basis
        and the relationship between devices is not seen other than via MAC address.

        This function uses the MAC addresses to find the names of the remote devices by MAC which is
        useful for creating network diagrams.

    .PARAMETER PnPDevices
        The APIC-EM Network PnP device list to build a topology from

    .EXAMPLE
        $pnpDevices = Get-APICEMNetworkPlugAndPlayDevice -Unclaimed
        $topology = Get-APICEMNetworkTopologyFromPnPDevices -PnpDevices $pnpDevices
#>
Function Get-APICEMNetworkTopologyFromPnPDevices {
    Param(
        [Parameter(Mandatory)]
        [PSCustomObject[]]$PnPDevices
    )

    if($null -eq $PnPDevices) {
        throw [System.ArgumentNullException]::new(
            'PnPDevices cannot be null'
        )
    }

    [PSCustomObject[]]$result = $PnpDevices | Where-Object { $null -ne $_.topologyInfo } | ForEach-Object {
        $pnpDevice = [PSCustomObject]$_
        [PSCustomObject]@{
            SerialNumber           = $pnpDevice.serialNumber
            PlatformID             = $pnpDevice.platformId
            Hostname               = $pnpDevice.hostName
            IPAddress              = $pnpDevice.ipAddress
            NeighborInformation    = Get-APICEMNeighborInformationFromTopologyInfo -TopologyInfo $pnpDevice.topologyInfo
        }
    }

    if(($null -eq $result) -or ($result.Count -lt 2)) {
        # There is no point figuring out neighbors if there's less than two devices.
        return $result
    }

    foreach($item in $result) {
        foreach($ni in $item.NeighborInformation) {
            $connectedDevice = $result | Where-Object { $null -ne ($_.NeighborInformation | Where-Object { $_.LocalMacAddress -eq $ni.RemoteMACAddress } ) }
            if($null -ne $connectedDevice) {
                $ni.RemoteSerialNumber = $connectedDevice.SerialNumber
            } else {
                $ni.RemoteSerialNumber = '<unknown device>'
            }
        }
    }
    return $result
}
$result | Where-Object { $null -ne ($_.NeighborInformation | Where-Object { $_.LocalMacAddress -eq $ni.RemoteMACAddress } ) }
