<powershell>
$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path "C:\setup-logs" | Out-Null
Start-Transcript -Path "C:\setup-logs\userdata-sql-express.log" -Append

# Ensure TLS 1.2 for downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy Bypass -Scope Process -Force

# Install Chocolatey
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install SQL Server Express
choco install sql-server-express -y

# Enable TCP/IP and set port 1433 (common post-install step for remote access)
$assemblyList = 'Microsoft.SqlServer.Management.Common','Microsoft.SqlServer.Smo','Microsoft.SqlServer.SqlWmiManagement','Microsoft.SqlServer.SmoExtended'
foreach ($assembly in $assemblyList) { [void][System.Reflection.Assembly]::LoadWithPartialName($assembly) }

$wmi = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer
$instance = $wmi.ServerInstances | Where-Object { $_.Name -eq 'SQLEXPRESS' }

if ($instance) {
  $tcp = $instance.ServerProtocols | Where-Object { $_.Name -eq 'Tcp' }
  $tcp.IsEnabled = $true
  $tcp.Alter()

  $ipAll = $tcp.IpAddresses | Where-Object { $_.Name -eq 'IpAll' }
  ($ipAll.IpAddressProperties | Where-Object { $_.Name -eq 'TcpDynamicPorts' }).Value = ""
  ($ipAll.IpAddressProperties | Where-Object { $_.Name -eq 'TcpPort' }).Value = "1433"
  $tcp.Alter()

  Restart-Service -Force 'MSSQL$SQLEXPRESS'
}

# Open Windows Firewall port 1433 (only needed if you want remote SQL connections)
netsh advfirewall firewall add rule name="SQL Server 1433" dir=in action=allow protocol=TCP localport=1433

Stop-Transcript
</powershell>