# =============================================================================
# �֐���         : RecoverRemotingForAnsible.ps1
# �@�\��         : Ansible�p�̃����[�g�ݒ�𕜋�����
# �����T�v       : ShowRemotingForAnsible.ps1 �ŏo�͂��ꂽconf�t�@�C���̏������ƂɁA
#                  ConfigureRemotingForAnsible.ps1 �ŕύX���ꂽ�����[�g�ݒ�𕜋�����B
# �o�[�W�����@�@ �FPowershell ver4.0�ō쐬�B
# ����1          : �����pconf�t�@�C��
# �߂�l[0]      : ����I��
# �߂�l[1]      : �ُ�I��
#
# ���l           : �Ȃ�
#
# �ύX����[ver1] : 2015/11/26 TIS� �V�K�쐬
#
# ==============================================================================

if ( $args.Length -eq 0 ) {
    Write-Output "�����p�̐ݒ�t�@�C���������Ɏw�肵�Ă��������B"
    exit 1
}

$setting_path = $args[0]

# �t�@�C���ǂݍ���
$flag = 0
$lines = Get-Content -Path $setting_path

foreach($line in $lines){
    if($flag -eq 0){
    
        # ���ʏ�ǂݍ��݁�

        # �R�����g�Ƌ�s�����O����
        if($line -match "^$"){ continue }
        if($line -match "^\s*$"){ continue }
        if($line -match "^\s*#"){ continue }

        # �u=�v�̗L���m�F
        $ret = $line.IndexOf("=")
        if ($ret -eq -1){
            Write-Output "���ݒ�t�@�C���ǂݍ��݃G���[��"
            $mes = "�ݒ�t�@�C����ǂݎ��ɃG���[���������܂����B`r`n�p�X: "+$param1+"`r`n�s: "+$line
            Write-Output $mes
            continue
        }
        # �ϐ��̊i�[
        $var_name1 = $line.split("=",2)[0]
        $var_value1 = $line.split("=",2)[1]
        $var_value1 = $var_value1.Trim('"')
        if ( $var_value1 -eq '$true' ) {
            $var_value1 = $true
        } elseif ( $var_value1 -eq '$false' ) {
            $var_value1 = $false
        }
        Set-Variable -Name $var_name1 -Value $var_value1
        continue
    }
}


# -----------------------------------------------------------

$ErrorActionPreference = "Stop"

Write-Output "ansible�ݒ�̕������J�n���܂����B"

### �ݒ�l�m�F ###

If (!(Get-Service "WinRM")){
    $ServiceExists_now=$false
} Else {
    $ServiceExists_now=$true
    $StartMode_now=(Get-WmiObject Win32_Service -filter "Name='WinRM'").StartMode
    $State_now=(Get-WmiObject Win32_Service -filter "Name='WinRM'").State
}

If (!(Get-PSSessionConfiguration -Verbose:$false) -or (!(Get-ChildItem WSMan:\localhost\Listener))){
    $PSRemoting_now=$false
} Else {
    $PSRemoting_now=$true
}

$listeners = Get-ChildItem WSMan:\localhost\Listener
If ($listeners | Where {$_.Keys -like "TRANSPORT=HTTPS"}) {
    $SSLListener_now=$true
} Else {
    $SSLListener_now=$false
}

$Basic_now=(Get-ChildItem WSMan:\localhost\Service\Auth | Where {$_.Name -eq "Basic"}).Value
$AllowUnencrypted_now=(Get-ChildItem WSMan:\localhost\Service | Where {$_.Name -eq "AllowUnencrypted"}).Value

If (@(Get-NetFirewallRule | Where-Object {$_.DisplayName -eq "Allow WinRM HTTPS"}).Length -eq 0){
    $AllowWinRMHTTPSExists_now=$false
}Else{
    $AllowWinRMHTTPSExists_now=$true
}



### WinRM�T�[�r�X�ݒ� ###
if ( ! $ServiceExists ) {
    Write-Output "WinRM �T�[�r�X�����݂��Ȃ���Ԃւ̕ύX�͏o���܂���"
} Else {
    if ( ( $StartMode -ne $StartMode_now ) -or ( $State -ne $State_now ) ) {
        Set-Service -Name "WinRM" -StartupType $StartMode -Status $State
    }
}

### PSRemoting�ݒ� ###
if ( ( ! $PSRemoting ) -and $PSRemoting_now ) {
    Disable-PSRemoting -Confirm:$False
}

### SSL ���X�i�[�ݒ� ###
if ( ( ! $SSLListener ) -and $SSLListener_now ) {
    $selectorset = @{}
    $selectorset.Add('Transport', 'HTTPS')
    $selectorset.Add('Address', '*')
    Remove-WSManInstance -ResourceURI 'winrm/config/Listener'-SelectorSet $selectorset
}

### WinRM�ݒ� ###
if ( ( ! $Basic ) -and $Basic_now ) {
    Set-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value $Basic
}
if ( ( ! $AllowUnencrypted ) -and $AllowUnencrypted_now ) {
    Set-Item -Path "WSMan:\localhost\Service\AllowUnencrypted" -Value $AllowUnencrypted
}

### FireWall�ݒ� ###
if ( ( ! $AllowWinRMHTTPSExists ) -and $AllowWinRMHTTPSExists_now ) {
    Remove-NetFirewallRule -DisplayName "Allow WinRM HTTPS"
}

Write-Output "ansible�ݒ�̕������I�����܂����B"

exit 0