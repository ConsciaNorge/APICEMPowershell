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
        Returns the requested credential

    .PARAMETER HostIP
        The IP address (or resolvable FQDN) of the APIC-EM server

    .PARAMETER ServiceTicket
        The service ticket issued by a call to Get-APICEMServiceTicket

    .PARAMETER CLI
        Specifies that the global CLI credential is being requested

    .PARAMETER SNMPv2Read
        Specifies that the SNMPv2 read credential is being requested

    .PARAMETER SNMPv2Write
        Specifies that the SNMPv2 write credential is being requested

    .PARAMETER SNMPv3
        Specifies that the SNMPv3 credential is being requested

    .EXAMPLE
        Get-APICEMServiceTicket -ApicHost 'apicvip.company.local' -Username 'bob' -Password 'Minions12345'
        Get-APICEMInventoryGlobalCredential -CLI
        Remove-APICEMServiceTicket 
#>
Function Get-APICEMInventoryGlobalCredential {
    Param (
        [Parameter()]
        [string]$ApicHost,

        [Parameter()]
        [string]$ServiceTicket,

        [Parameter()]
        [switch]$CLI,

        [Parameter()]
        [switch]$SNMPv2Read,

        [Parameter()]
        [switch]$SNMPv2Write,

        [Parameter()]
        [switch]$SNMPv3
    )

    $session = Internal-APICEMHostIPAndServiceTicket -ApicHost $ApicHost -ServiceTicket $ServiceTicket        

    $uri  = 'https://' + $session.ApicHost + '/api/v1/global-credential'

    if($CLI) {
        $uri += '?credentialSubType=CLI'
    } elseif ($SNMPv2Read) {
        $uri += '?credentialSubType=SNMPV2_READ_COMMUNITY'        
    } elseif ($SNMPv2Write) {
        $uri += '?credentialSubType=SNMPV2_WRITE_COMMUNITY'        
    } elseif ($SNMPv3) {
        $uri += '?credentialSubType=SNMPV3'        
    } else {
        throw [System.ArgumentException]::new(
            'You must specify at least one switch for what type of credential to return'
        )
    }

    $response = Internal-APICEMGetRequest -ServiceTicket $session.ServiceTicket -Uri $uri

    return $response
}
