$o = @()
$o += "host=$(hostname)"
$o += "time_local=$(Get-Date -Format o)"
$o += "time_utc=$([DateTime]::UtcNow.ToString('o'))"
$o += "freeGB=$([math]::Round((Get-PSDrive C).Free/1GB,1))"
if (Test-Path 'C:\persist-store') { $o += "persist-store=" + ((Get-ChildItem 'C:\persist-store' -Force | ForEach-Object { $_.Name + ':' + [math]::Round($_.Length/1MB,1) + 'MB' }) -join '; ') } else { $o += "persist-store=none" }
$o += "nt8_installed=$(Test-Path 'C:\Program Files\NinjaTrader 8')"
$o += "profileMB=$([math]::Round((Get-ChildItem $env:USERPROFILE -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum/1MB,0))"
$rp = Get-Process -Name 'Worker','HostedComputeAgent' -ErrorAction SilentlyContinue
$o += "runner_procs=" + (($rp | ForEach-Object { $_.ProcessName }) -join ',')
$o += "rdp_user=$([string]::Join(',', (quser 2>$null | Select-Object -Skip 1 | ForEach-Object { ($_ -split '\s+')[0] })))"
try { curl.exe -s -m 20 -X POST --data-binary ($o -join "`n") http://100.81.129.36:8765/ | Out-Null } catch {}
