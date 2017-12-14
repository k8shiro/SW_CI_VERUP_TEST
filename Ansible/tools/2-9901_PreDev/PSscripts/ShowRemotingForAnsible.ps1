# =============================================================================
# �֐���         : ShowRemotingForAnsible.ps1
# �@�\��         : Ansible�p�̃����[�g�ݒ��conf�`���ŏo�͂���
# �����T�v       : ConfigureRemotingForAnsible.ps1 �ŕύX�����p�����[�^���Akey=value�`���ŏo�͂���
# �o�[�W�����@�@ �FPowershell ver4.0�ō쐬�B
# ����1          : �Ȃ�
# �߂�l[0]      : ����I��
# �߂�l[1]      : �ُ�I��
#
# ���l           : �Ȃ�
#
# �ύX����[ver1] : 2015/11/26 TIS� �V�K�쐬
#
# ==============================================================================

# ���O�t�@�C���o�͐�ݒ�
Param (
    [string]$log_filepath = "C:\temp\ansible_winrm_setting_"+$([DateTime]::Now.ToString('yyyy-MM-dd@hh-mm-ss~'))+".conf"
)

# -----------------------------------------------------------

$ErrorActionPreference = "Stop"


# ���O�t�@�C���o�͐�t�H���_�m�F
$log_dirpath = Split-Path $log_filepath -Parent
if ( ! ( Test-Path $log_dirpath ) ) {
    Write-Output "���O�o�͐�t�H���_�����݂��܂���ł����B"
    Write-Output "Path: $log_dirpath"
    exit 1
}

Write-Output "ansible�ݒ�̏o�͂��J�n���܂����B"

Write-Output "`#`#`# WinRM�T�[�r�X�ݒ� `#`#`#" | Out-File $log_filepath -Append
If (!(Get-Service "WinRM")){
    Write-Output "ServiceExists=`$false" | Out-File $log_filepath -Append
} Else {
    Write-Output "ServiceExists=`$true" | Out-File $log_filepath -Append
    $ret=(Get-WmiObject Win32_Service -filter "Name='WinRM'").StartMode
    Write-Output "StartMode=`"$ret`"" | Out-File $log_filepath -Append
    $ret=(Get-WmiObject Win32_Service -filter "Name='WinRM'").State
    Write-Output "State=`"$ret`"" | Out-File $log_filepath -Append
}

Write-Output "`r`n`#`#`# PSRemoting�ݒ� `#`#`#" | Out-File $log_filepath -Append
If (!(Get-PSSessionConfiguration -Verbose:$false) -or (!(Get-ChildItem WSMan:\localhost\Listener))){
    Write-Output "PSRemoting=`$false" | Out-File $log_filepath -Append
} Else {
    Write-Output "PSRemoting=`$true" | Out-File $log_filepath -Append
}

Write-Output "`r`n`#`#`# SSL ���X�i�[�ݒ� `#`#`#" | Out-File $log_filepath -Append
$listeners = Get-ChildItem WSMan:\localhost\Listener
If ($listeners | Where {$_.Keys -like "TRANSPORT=HTTPS"}) {
    Write-Output "SSLListener=`$true" | Out-File $log_filepath -Append
} Else {
    Write-Output "SSLListener=`$false" | Out-File $log_filepath -Append
}

Write-Output "`r`n`#`#`# WinRM�ݒ� `#`#`#" | Out-File $log_filepath -Append

$ret = (Get-ChildItem WSMan:\localhost\Service\Auth | Where {$_.Name -eq "Basic"}).Value
Write-Output "Basic=`$$ret" | Out-File $log_filepath -Append

$ret = (Get-ChildItem WSMan:\localhost\Service | Where {$_.Name -eq "AllowUnencrypted"}).Value
Write-Output "AllowUnencrypted=`$$ret" | Out-File $log_filepath -Append


Write-Output "`r`n`#`#`# FireWall�ݒ� `#`#`#" | Out-File $log_filepath -Append
If (@(Get-NetFirewallRule | Where-Object {$_.DisplayName -eq "Allow WinRM HTTPS"}).Length -eq 0){
    Write-Output "AllowWinRMHTTPSExists=`$false" | Out-File $log_filepath -Append
}Else{
    Write-Output "AllowWinRMHTTPSExists=`$true" | Out-File $log_filepath -Append
}

Write-Output "ansible�ݒ�̏o�͂��������܂����B"

exit 0