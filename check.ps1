$ErrorActionPreference = 'Continue'
function W($t) { Write-Host $t }

W "=== 1) Are the Rithmic TLS fixes actually applied on this machine? ==="
try {
  $t10 = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -ErrorAction Stop).Enabled
  W ("TLS 1.0 client Enabled = {0} (must be 1)" -f $t10)
} catch { W "TLS 1.0 registry key MISSING (fix not applied!)" }
$t12 = Get-TlsCipherSuite | Where-Object { $_.Name -eq 'TLS_RSA_WITH_AES_128_CBC_SHA' }
if ($t12) { W "CBC suite TLS_RSA_WITH_AES_128_CBC_SHA: ENABLED" } else { W "CBC suite TLS_RSA_WITH_AES_128_CBC_SHA: MISSING!" }
$tdes = Get-TlsCipherSuite | Where-Object { $_.Name -eq 'TLS_RSA_WITH_3DES_EDE_CBC_SHA' }
if ($tdes) { W "3DES suite: ENABLED" } else { W "3DES suite: MISSING" }
try {
  $f = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -ErrorAction Stop).Functions
  W ("Order policy first 3: {0}" -f ($f[0..2] -join ' | '))
} catch { W "Cipher order policy MISSING" }

W "=== 2) NinjaTrader version & process ==="
foreach ($pth in 'C:\Program Files\NinjaTrader 8\bin\NinjaTrader.exe','C:\Program Files (x86)\NinjaTrader 8\bin\NinjaTrader.exe') {
  if (Test-Path $pth) { W ("{0} v{1}" -f $pth, (Get-Item $pth).VersionInfo.ProductVersion) }
}
foreach ($p in (Get-Process -Name '*Ninja*' -ErrorAction SilentlyContinue)) { W ("running: " + $p.ProcessName + " PID=" + $p.Id) }

W "=== 3) Newest Rithmic trace, last 30 lines ==="
$t = Get-ChildItem 'C:\Users\runneradmin\Documents\NinjaTrader 8\trace' -Filter 'Rithmic*' -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($t) {
  W ("TRACE FILE: " + $t.FullName)
  Get-Content $t.FullName -Tail 30 | ForEach-Object { W $_ }
} else { W "(no trace file found)" }

W "=== DONE ==="
