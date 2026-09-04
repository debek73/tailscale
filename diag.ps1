$ErrorActionPreference = 'Continue'
$out = @()
function W($t) { $out += $t; Write-Host $t }

W "=== 1) System TLS handshake to Rithmic gateways ==="
foreach ($h in 'rithmic.com','myrithmic.com','atsg.rrims.com','pasg.rrims.com') {
  try {
    $tcp = New-Object Net.Sockets.TcpClient($h, 443)
    $ssl = New-Object Net.Security.SslStream($tcp.GetStream())
    $ssl.AuthenticateAsClient($h)
    W ("OK   {0} :: {1} / {2}" -f $h, $ssl.SslProtocol, $ssl.CipherAlgorithm)
    $ssl.Dispose(); $tcp.Dispose()
  } catch { W ("FAIL {0} :: {1}" -f $h, $_.Exception.InnerException.Message) }
}

W "=== 2) NT Rithmic connection settings ==="
$doc = 'C:\Users\runneradmin\Documents\NinjaTrader 8\templates\Rithmic\Rithmic.xml'
if (Test-Path $doc) { Get-Content $doc | ForEach-Object { W $_ } } else {
  W "(no Rithmic.xml at expected path; searching...)"
  Get-ChildItem 'C:\Users\runneradmin\Documents\NinjaTrader 8' -Recurse -Filter '*.xml' -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match 'Rithmic' } | ForEach-Object { W $_.FullName }
}

W "=== 3) NinjaTrader processes & bitness ==="
foreach ($p in (Get-Process -Name '*Ninja*' -ErrorAction SilentlyContinue)) {
  W ("{0} PID={1} path={2}" -f $p.ProcessName, $p.Id, $p.Path)
}
if (-not (Get-Process -Name '*Ninja*' -ErrorAction SilentlyContinue)) { W "(NT process NOT running)" }

W "=== 4) Live TCP connections of NT process ==="
foreach ($p in (Get-Process -Name '*Ninja*' -ErrorAction SilentlyContinue)) {
  Get-NetTCPConnection -OwningProcess $p.Id -ErrorAction SilentlyContinue |
    Where-Object { $_.State -ne 'Listen' } | ForEach-Object {
      W ("{0}:{1} -> {2}:{3} [{4}]" -f $_.LocalAddress, $_.LocalPort, $_.RemoteAddress, $_.RemotePort, $_.State)
    }
}

W "=== 5) NT platform log, last 40 lines ==="
$log = Get-ChildItem 'C:\Users\runneradmin\Documents\NinjaTrader 8\log' -Filter '*.txt' -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($log) {
  W ("LOG FILE: " + $log.FullName)
  Get-Content $log.FullName -Tail 40 | ForEach-Object { W $_ }
} else { W "(no log found)" }

W "=== DONE ==="
$out | Out-File "$env:USERPROFILE\Desktop\RITHMIC-DIAG.txt" -Encoding Unicode
Start-Process notepad "$env:USERPROFILE\Desktop\RITHMIC-DIAG.txt"
