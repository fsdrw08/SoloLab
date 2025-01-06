function GetKVP {
    param($VMName, $key)

    $VmMgmt = Get-WmiObject -Namespace "Root\Virtualization\V2" -Class Msvm_VirtualSystemManagementService #Get-WmiObject -Namespace root\virtualization\v2 -Class Msvm_VirtualSystemManagementService
    $Vm = Get-WmiObject -Namespace "root\virtualization\v2" -Class Msvm_ComputerSystem| Where-Object {$_.ElementName -eq $VMName }  #Get-WmiObject -Namespace root\virtualization\v2 -Class Msvm_ComputerSystem -Filter {ElementName='TEST-APP38'}     # has to be same as $VMName

    $n = $vm.GetRelated("Msvm_KvpExchangeComponent").GuestIntrinsicExchangeItems
    $n = $vm.GetRelated("Msvm_KvpExchangeComponent").GuestExchangeItems

    $n = $vm.GetRelated("Msvm_KvpExchangeComponent").GetRelated('Msvm_KvpExchangeComponentSettingData').HostExchangeItems

    $n | ForEach-Object {
        $GuestExchangeItemXml = ([XML]$_).SelectSingleNode(`
            "/INSTANCE/PROPERTY[@NAME='Name']/VALUE[child::text()='$key']")

        if ($null -ne $GuestExchangeItemXml)
        {
            $val = $GuestExchangeItemXml.SelectSingleNode( `
                "/INSTANCE/PROPERTY[@NAME='Data']/VALUE/child::text()").Value
                $val
                Return
        }
    }
}

$vmName = "SvcDisc-FCOS"
$vm=Get-WmiObject -Namespace "root\virtualization\v2" -Class Msvm_ComputerSystem| Where-Object {$_.ElementName -eq $vmName }
GetKVP -VMName "SvcDisc-FCOS" -key "ignition.config.0"

# https://github.com/NathanielArnoldR2/KVPTools/blob/022e103c61f78a2e2de5e01849c45d4d11216ea7/KVPTools.psm1#L49
Get-CimInstance -Namespace root\virtualization\v2 -ClassName Msvm_ComputerSystem -Filter "ElementName='$vmName'" `
    | Get-CimAssociatedInstance -ResultClassName Msvm_KvpExchangeDataItem