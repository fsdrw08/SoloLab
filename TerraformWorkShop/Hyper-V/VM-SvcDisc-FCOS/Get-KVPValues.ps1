# https://github.com/NathanielArnoldR2/KVPTools/blob/022e103c61f78a2e2de5e01849c45d4d11216ea7/KVPTools.psm1#L326
function Get-KvpValue {
    [CmdletBinding(
      PositionalBinding = $false
    )]
    param(
      [Parameter(
        Mandatory = $true
      )]
      [guid]
      $VMId,
  
      [Parameter(
        Mandatory = $true
      )]
      [ValidateSet("Guest", "GuestIntrinsic", "Host")]
      [String]
      $Origin,
  
      [Parameter(
        Mandatory = $true
      )]
      [String]
      $Name
    )
  
    $kvpObject = Get-CimInstance -Namespace root\virtualization\v2 `
                                 -ClassName Msvm_ComputerSystem `
                                 -Filter "Name='$VMId'" |
                   Get-CimAssociatedInstance -ResultClassName Msvm_KvpExchangeComponent
  
    if ($null -eq $kvpObject) {
      throw "The KVP store for this VM could not be queried." # Let the calling code determine severity of failure.
    }
  
    if ($Origin -eq "Guest") {
      $items = $kvpObject.GuestExchangeItems
    }
    elseif ($Origin -eq "GuestIntrinsic") {
      $items = $kvpObject.GuestIntrinsicExchangeItems
    }
    elseif ($Origin -eq "Host") {
      $kvpObject = $kvpObject |
                     Get-CimAssociatedInstance -ResultClassName Msvm_KvpExchangeComponentSettingData
  
      if ($null -eq $kvpObject) {
        throw "The Host KVP store for this VM could not be queried." # Let the calling code determine severity of failure.
      }
  
      $items = $kvpObject.HostExchangeItems
    }
  
    $item = $items |
              ForEach-Object {[xml]$_} |
              ForEach-Object INSTANCE |
              Where-Object {
                $_ |
                  ForEach-Object PROPERTY |
                  Where-Object Name -eq $Name |
                  ForEach-Object Value |
                  ForEach-Object Equals $Name
              }
  
    if ($null -eq $item) {
      return
    }
  
    $item |
      ForEach-Object PROPERTY |
      Where-Object Name -eq Data |
      ForEach-Object Value
  }

$VMId = Get-VM -Name "SvcDisc-FCOS" | Select-Object -ExpandProperty Id
Get-KvpValue -VMId $VMId -Origin "Host" -Name "Name"

Get-CimInstance -Namespace root\virtualization\v2 `
        -ClassName Msvm_ComputerSystem `
        -Filter "Name='$VMId'" | `
        Get-CimAssociatedInstance -ResultClassName Msvm_KvpExchangeComponent | `
        Get-CimAssociatedInstance -ResultClassName Msvm_KvpExchangeComponentSettingData | `
    Select-Object -ExpandProperty HostExchangeItems |
    ForEach-Object {[xml]$_} |
    ForEach-Object INSTANCE | Select-Object -ExpandProperty PROPERTY