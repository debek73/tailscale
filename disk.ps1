$ErrorActionPreference = 'Continue'
function W($t) { Write-Host $t }
function DirSize($p) {
  if (-not (Test-Path $p)) { return $null }
  $lines = robocopy $p "$env:TEMP\__null_dest__" /L /S /BYTES /NFL /NDL /NJH /XJ 2>$null
  $line = $lines | Where-Object { $_ -match '^\s*Bytes\s*:' } | Select-Object -First 1
  if ($line) {
    $bytes = [long]($line -replace '^\s*Bytes\s*:\s*','' -replace '\s.*$','')
    return [math]::Round($bytes/1MB,0)
  }
  return 0
}

$free = [math]::Round((Get-PSDrive C).Free/1GB,1)
W ("FREE DISK ON C: {0} GB" -f $free)

W "=== sizes (MB) ==="
$targets = [ordered]@{
  'profile TOTAL'              = 'C:\Users\runneradmin'
  'AppData\Local'              = 'C:\Users\runneradmin\AppData\Local'
  'Documents\NinjaTrader 8'    = 'C:\Users\runneradmin\Documents\NinjaTrader 8'
  '  NT8 db folder'            = 'C:\Users\runneradmin\Documents\NinjaTrader 8\db'
  'Downloads'                  = 'C:\Users\runneradmin\Downloads'
  'Desktop'                    = 'C:\Users\runneradmin\Desktop'
  'AppData\Roaming'            = 'C:\Users\runneradmin\AppData\Roaming'
  'C:\Apps'                    = 'C:\Apps'
  'C:\persist (old staging)'   = 'C:\persist'
  'C:\persist-store'           = 'C:\persist-store'
  'runner _diag logs'          = 'C:\actions-runner\cached\2.337.0\_diag'
}
foreach ($k in $targets.Keys) {
  $mb = DirSize $targets[$k]
  if ($null -ne $mb) { W ("{0,-28} {1,8} MB" -f $k, $mb) } else { W ("{0,-28}    n/a" -f $k) }
}

W "=== biggest subfolders of AppData\Local ==="
Get-ChildItem 'C:\Users\runneradmin\AppData\Local' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
  $mb = DirSize $_.FullName
  if ($mb -gt 200) { W ("{0,-45} {1,8} MB" -f $_.Name, $mb) }
}
W "=== DONE ==="
