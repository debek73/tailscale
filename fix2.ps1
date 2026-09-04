$ErrorActionPreference = 'Continue'
function W($t) { Write-Host $t }

# 1) Enable TLS 1.0 / 1.1 client (Rithmic MD gateways still negotiate old TLS)
foreach ($v in 'TLS 1.0','TLS 1.1') {
  $p = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$v\Client"
  New-Item -Path $p -Force | Out-Null
  Set-ItemProperty -Path $p -Name 'Enabled' -Value 1 -Type DWord
  Set-ItemProperty -Path $p -Name 'DisabledByDefault' -Value 0 -Type DWord
}
W "TLS 1.0 / 1.1 client enabled"

# 2) Enable legacy cipher suites
foreach ($s in 'TLS_RSA_WITH_3DES_EDE_CBC_SHA','TLS_RSA_WITH_RC4_128_SHA','TLS_RSA_WITH_RC4_128_MD5','TLS_RSA_WITH_AES_128_CBC_SHA','TLS_RSA_WITH_AES_256_CBC_SHA','TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA','TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA') {
  try { Enable-TlsCipherSuite -Name $s -ErrorAction Stop } catch { W ("suite skip: " + $s) }
}
W "legacy cipher suites enabled"

# 3) Enable legacy SCHANNEL ciphers / hashes / key exchanges (LSASS-level gates)
$sch = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL'
foreach ($c in 'Triple DES 168','Triple DES 112','RC4 128/128','RC2 128/128','DES 56/56','RC4 64/128','RC4 56/128','RC4 40/128','RC2 56/128','RC4 40/128') {
  $p = "$sch\Ciphers\$c"; New-Item -Path $p -Force | Out-Null
  Set-ItemProperty -Path $p -Name 'Enabled' -Value 0xffffffff -Type DWord
}
foreach ($h in 'SHA1','MD5','SHA 256','SHA 384','SHA 512') {
  $p = "$sch\Hashes\$h"; New-Item -Path $p -Force | Out-Null
  Set-ItemProperty -Path $p -Name 'Enabled' -Value 0xffffffff -Type DWord
}
foreach ($k in 'PKCS','Diffie Hellman','ECDH') {
  $p = "$sch\KeyExchangeAlgorithms\$k"; New-Item -Path $p -Force | Out-Null
  Set-ItemProperty -Path $p -Name 'Enabled' -Value 0xffffffff -Type DWord
}
W "SCHANNEL legacy ciphers/hashes/KEX enabled (registry)"

W "DONE - now close and reopen NinjaTrader, then try the Rithmic connection."
