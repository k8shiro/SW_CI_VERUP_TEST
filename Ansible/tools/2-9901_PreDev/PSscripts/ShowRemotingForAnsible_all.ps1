# =============================================================================
# �֐���         : ShowRemotingForAnsible.ps1
# �@�\��         : Ansible�p�̃����[�g�ݒ���ڍׂɏo�͂���
# �����T�v       : ConfigureRemotingForAnsible.ps1 �ŕύX�����p�����[�^���ڍׂɏo�͂���B
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

Write-Output "��WinRM�T�[�r�X�ݒ聄" | Out-File $log_filepath -Append
If (!(Get-Service "WinRM")){
    Write-Output "WinRM�T�[�r�X��������܂���ł���" | Out-File $log_filepath -Append
}Else{
    $ret=(Get-WmiObject Win32_Service -filter "Name='WinRM'").StartMode
    Write-Output "�����N���ݒ�F$ret" | Out-File $log_filepath -Append
    $ret=(Get-WmiObject Win32_Service -filter "Name='WinRM'").StartMode
    Write-Output "�X�e�[�^�X�F$ret" | Out-File $log_filepath -Append
}

Write-Output "��PSSession�ݒ聄" | Out-File $log_filepath -Append
Get-PSSessionConfiguration | Out-File $log_filepath -Append

Write-Output "�����X�i�[�ݒ聄" | Out-File $log_filepath -Append
Get-ChildItem WSMan:\localhost\Listener | Out-File $log_filepath -Append

Write-Output "��WinRM�ݒ聄" | Out-File $log_filepath -Append
winrm get winrm/config  | Out-File $log_filepath -Append

Write-Output "��FireWall�ݒ聄" | Out-File $log_filepath -Append
If (@(Get-NetFirewallRule | Where-Object {$_.DisplayName -eq "Allow WinRM HTTPS"}).Length -eq 0){
    Write-Output "FW���[���uAllow WinRM HTTPS�v��������܂���ł����B" | Out-File $log_filepath -Append
}Else{
    Get-NetFirewallRule -DisplayName "Allow WinRM HTTPS" | Out-File $log_filepath -Append
}

Write-Output "ansible�ݒ�̏o�͂��������܂����B"

exit 0