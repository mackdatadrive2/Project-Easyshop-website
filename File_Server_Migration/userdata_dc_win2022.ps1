<powershell>
# ---------- Configure variables ----------
$DomainName  = "corp.local"
$NetBIOSName = "CORP"

# Local admin password for DSRM (Directory Services Restore Mode)
$DSRMPasswordPlain = "P@ssw0rd-ChangeMe!"
$DSRMPassword = ConvertTo-SecureString $DSRMPasswordPlain -AsPlainText -Force

# ---------- Install AD DS + DNS ----------
Install-WindowsFeature AD-Domain-Services,DNS -IncludeManagementTools

# ---------- Promote to Domain Controller (new forest) ----------
Install-ADDSForest `
  -DomainName $DomainName `
  -DomainNetbiosName $NetBIOSName `
  -SafeModeAdministratorPassword $DSRMPassword `
  -InstallDNS `
  -Force

</powershell>