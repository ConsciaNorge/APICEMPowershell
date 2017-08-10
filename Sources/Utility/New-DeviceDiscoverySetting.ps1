Function New-DeviceDiscoverySetting {
    Param (
        [Parameter()]
        [string]$Name,

        [Parameter()]
        [int]$CDPLevel,

        [Parameter()]
        [string[]]$IPFilterList,

        [Parameter()]
        [string[]]$PasswordList,

        [Parameter()]
        [string]$ProtocolOrder,

        [Parameter()]
        [switch]$Rediscovery,

        [Parameter()]
        [int]$RetryCount,

        [Parameter()]
        [string]$SnmpAuthPassphrase,

        [Parameter()]
        [string]$SnmpPrivacyProtocol,

        [Parameter()]
        [string]$SnmpROCommunity,

        [Parameter()]
        [string]$SnmpRWCommunity,

        [Parameter()]
        [string[]]$UsernameList,

        [Parameter()]
        [string[]]$GlobalCredentialIDList,

        [Parameter()]
        [string]$ParentDiscoveryID,

        [Parameter()]
        [string]$SnmpVersion,

        [Parameter()]
        [int]$TimeoutSeconds,

        [Parameter()]
        [string]$IPAddressList,

        [Parameter()]
        [string]$DiscoveryType,

        [Parameter()]
        [string]$SnmpMode,

        [Parameter()]
        [string]$SnmpUsername
    )

    $deviceSettings = New-Object -TypeName 'PSCustomObject'

    if(-not [string]::IsNullOrEmpty($DiscoveryID)) { Add-Member -InputObject $deviceSettings -Name 'id' -Value $DiscoveryID -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($DiscoveryStatus)) { Add-Member -InputObject $deviceSettings -Name 'discoveryStatus' -Value $DiscoveryStatus -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($Name)) { Add-Member -InputObject $deviceSettings -Name 'name' -Value $Name -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('CDPLevel')) { Add-Member -InputObject $deviceSettings -Name 'cdpLevel' -Value ([Convert]::ToString($CDPLevel)) -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('IPFilterList')) { Add-Member -InputObject $deviceSettings -Name 'ipFilterList' -Value $IPFilterList -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('PasswordList')) { Add-Member -InputObject $deviceSettings -Name 'passwordList' -Value $PasswordList -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($ProtocolOrder)) { Add-Member -InputObject $deviceSettings -Name 'protocolOrder' -Value $ProtocolOrder -MemberType NoteProperty }
    if($Rediscovery) { Add-Member -InputObject $deviceSettings -Name 'reDiscovery' -Value $true -MemberType NoteProperty }
    if($RetryCount -gt 0) { Add-Member -InputObject $deviceSettings -Name 'retry' -Value ([Convert]::ToString($RetryCount)) -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpAuthPassphrase)) { Add-Member -InputObject $deviceSettings -Name 'snmpAuthPassphrase' -Value $SnmpAuthPassphrase -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpPrivacyProtocol)) { Add-Member -InputObject $deviceSettings -Name 'snmpPrivacyProtocol' -Value $SnmpPrivacyProtocol -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpROCommunity)) { Add-Member -InputObject $deviceSettings -Name 'snmpROCommunity' -Value $SnmpROCommunity -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpRWCommunity)) { Add-Member -InputObject $deviceSettings -Name 'snmpRWCommunity' -Value $SnmpRWCommunity -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('UsernameList')) { Add-Member -InputObject $deviceSettings -Name 'usernameList' -Value $UsernameList -MemberType NoteProperty }
    if($PSBoundParameters.ContainsKey('GlobalCredentialIDList')) { Add-Member -InputObject $deviceSettings -Name 'globalCredentialIdList' -Value $GlobalCredentialIDList -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($ParentDiscoveryID)) { Add-Member -InputObject $deviceSettings -Name 'parentDiscoveryID' -Value $ParentDiscoveryID -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpVersion)) { Add-Member -InputObject $deviceSettings -Name 'snmpVersion' -Value $SnmpVersion -MemberType NoteProperty }
    if($TimeoutSeconds -gt 0) { Add-Member -InputObject $deviceSettings -Name 'timeout' -Value ([Convert]::ToString($TimeoutSeconds)) -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($IPAddressList)) { Add-Member -InputObject $deviceSettings -Name 'ipAddressList' -Value $IPAddressList -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($DiscoveryType)) { Add-Member -InputObject $deviceSettings -Name 'discoveryType' -Value $DiscoveryType -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpMode)) { Add-Member -InputObject $deviceSettings -Name 'snmpMode' -Value $SnmpMode -MemberType NoteProperty }
    if(-not [string]::IsNullOrEmpty($SnmpUsername)) { Add-Member -InputObject $deviceSettings -Name 'snmpUsername' -Value $SnmpUsername -MemberType NoteProperty }

    return $deviceSettings
}
