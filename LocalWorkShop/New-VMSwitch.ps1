if (-not [bool](Get-VMSwitch -Name "Internal Switch") ) {
    New-VMSwitch -Name "Internal Switch" -SwitchType Internal
} else {
    "Hyper-V switch `"Internal Switch`" already exist"
}