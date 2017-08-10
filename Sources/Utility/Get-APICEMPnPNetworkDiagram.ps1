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

Function Get-APICEMPnPNetworkDiagram {
    Param(
        [Parameter(Mandatory)]
        [PSCustomObject[]]$PnPDevices,

        [Parameter()]
        [int]$DeviceFontSize=24,

        [Parameter()]
        [int]$LinkFontSize=16
    )

    $DiagramData = Get-APICEMNetworkTopologyFromPnPDevices -PnPDevices $PnPDevices

    $sortedData = $DiagramData | Sort-Object -Property @{Expression={$_.NeighborInformation.Count};Descending=$True}

    [PSObject[]]$links = @()
    foreach($item in $sortedData) {
        foreach($ni in $item.NeighborInformation) {
            $link = @{
                DeviceB = $item.SerialNumber
                IntB = $ni.LocalInterfaceShort
                DeviceA = $ni.RemoteSerialNumber
                IntA = $ni.RemoteInterfaceShort
            }
            if(
                ($null -eq 
                    ($links | Where-Object { 
                        ($_.DeviceA -eq $link.DeviceA) -and
                        ($_.DeviceB -eq $link.DeviceB) -and
                        ($_.LinkA -eq $link.LinkA) -and
                        ($_.LinkB -eq $link.LinkB)
                    })
                ) -and
                ($null -eq 
                    ($links | Where-Object { 
                        ($_.DeviceA -eq $link.DeviceB) -and
                        ($_.DeviceB -eq $link.DeviceA) -and
                        ($_.LinkA -eq $link.LinkB) -and
                        ($_.LinkB -eq $link.LinkA)
                    })
                )
            ) {
                $links += $link
            }
        }
    }

    $result = "graph g {`n" +
        "  graph [splines=ortho, nodesep=1]`n" + 
        $sortedData.ForEach{
            "  " + $_.SerialNumber + "`n" + 
            "  [`n" + 
            "    label=`"" + $_.SerialNumber + "\n" + $_.IPAddress + "`"`n" + 
            "    shape=box`n" +
#            "    image=`"" + $SwitchIconPath + "`"`n" +
            "    fontsize=" + $DeviceFontSize.ToString() + "`n" +
            "  ]`n"
        } +
        $links.Foreach{
            "  " + $_.DeviceA + ' -- ' + $_.DeviceB + "`n" 
            "  [`n" +
            "    headlabel=<<font color=`"red`" point-size=`"" + $LinkFontSize.ToString() + "`">" + $_.IntB + "</font>>`n" + 
            "    taillabel=<<font color=`"blue`" point-size=`"" + $LinkFontSize.ToString() + "`">" + $_.IntA + "</font>>`n" + 
            "  ]`n"
        } +
        "}`n"

    return $result
}
