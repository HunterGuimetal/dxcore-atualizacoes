# DXCORE by GUIMETAL - lancador com atualizacao automatica
# Ao abrir: confere se tem versao nova publicada, baixa, confere o SHA-256 e a assinatura digital,
# guarda a versao anterior (DXCORE.anterior.html) e abre o programa. Sem internet, abre a versao instalada.
$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$html = Join-Path $dir 'DXCORE.html'
$log = Join-Path $dir 'atualizacao.log'
$PUB = '<RSAKeyValue><Modulus>k0tsld0x1hu5QGum+kDaiVKBW9lTapGPCDmliYDpOkv9LFTmDIoqv+XCYOoUZD9u7JoOzh/OMmgV9DKPR4Xz+1Pc+Z7B3+pwO7im4UBjpPjZstqr9t4Ggrq/OM06tIciFZbOJgZKAv7ZWSNStfkOBOQroqhsknn6Xp9XLcba03quK1xaoFG6Z3wcBqgQR6AnH0zWZBmObCbOBFjWz7QIhUhshrJ9Fpdou0iFPPWwZSZlmATgca2tcW1bCQpIC26/SDCAUJGKymK3QkJVpMTYD3vFEGmyLOAc9WJjg2eF1xR2TGyZLfq7XEWqS1W1STH1GGs/+ook5H52L5UasECi8w==</Modulus><Exponent>AQAB</Exponent></RSAKeyValue>'

function Log([string]$m) {
  try {
    if ((Test-Path $log) -and ((Get-Item $log).Length -gt 200KB)) { Remove-Item $log -Force }
    Add-Content -Path $log -Value ((Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '  ' + $m)
  } catch {}
}
function Navegador {
  # v7.8: também procura pelo registro do Windows (Edge/Chrome instalados em outro lugar)
  foreach ($k in @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe', 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe')) {
    try { $v = (Get-ItemProperty -Path $k -ErrorAction Stop).'(default)'; if ($v -and (Test-Path $v)) { return $v } } catch {}
  }
  $c = @(
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
  )
  return ($c | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1)
}
# v7.8: confere o atalho da Área de Trabalho e do menu Iniciar (ícone do DXCORE, abre pelo lançador)
function Atalho {
  try {
    $ws = New-Object -ComObject WScript.Shell
    $vbs = Join-Path $dir 'abrir.vbs'; $ico = (Join-Path $dir 'DXCORE.ico') + ',0'; $wscript = Join-Path $env:WINDIR 'System32\wscript.exe'
    foreach ($p in @([Environment]::GetFolderPath('Desktop'), (Join-Path ([Environment]::GetFolderPath('StartMenu')) 'Programs'))) {
      $f = Join-Path $p 'DXCORE by GUIMETAL.lnk'
      if (-not (Test-Path $f)) { continue }
      $s = $ws.CreateShortcut($f)
      if ($s.IconLocation -ne $ico -or $s.TargetPath -ne $wscript) {
        $s.TargetPath = $wscript; $s.Arguments = "`"$vbs`""; $s.IconLocation = $ico; $s.WorkingDirectory = $dir; $s.Save()
        Log ('atalho consertado: ' + $f)
      }
    }
  } catch { Log ('atalho: ' + $_.Exception.Message) }
}
# v8.10: abre pelo endereço da internet (GitHub Pages). Assim o Edge/Chrome guarda a autorização da pasta de dados
# e o DXCORE pode ser instalado como aplicativo. Sem internet (ou se o endereço não responder), abre a cópia do computador.
function Web {
  try {
    $c = Get-Content (Join-Path $dir 'atualizacao.json') -Raw | ConvertFrom-Json
    if ($c.web) { return $c.web }
    if ($c.repo -eq 'HunterGuimetal/dxcore-atualizacoes' -and -not $c.token) { return 'https://dxcore.guimetal.com.br/DXCORE.html' }
    if ($c.repo -and -not $c.token) { $p = $c.repo.Split('/'); return ('https://' + $p[0].ToLower() + '.github.io/' + $p[1] + '/DXCORE.html') }
  } catch {}
  return $null
}
# v8.12: servidor local (servidor.ps1). Com ele o DXCORE abre em http://127.0.0.1:47815 e a pasta de dados fica
# definida de uma vez neste computador: o navegador não pede mais autorização. Se não subir, segue como antes.
function PingLocal([string]$u) {
  try { $rq = [Net.HttpWebRequest]::Create($u + 'api/ping'); $rq.Timeout = 1500; $rq.Proxy = $null; $rq.Headers.Add('X-DXCORE', '1'); $rs = $rq.GetResponse(); $ok = ([int]$rs.StatusCode -eq 200); $rs.Close(); return $ok } catch { return $false }
}
function TesteLocal([string]$u) { # confere se o servidor lê e responde direito (corpo, acentos) antes de usar
  try {
    $rq = [Net.HttpWebRequest]::Create($u + 'api/teste'); $rq.Method = 'POST'; $rq.Timeout = 3000; $rq.Proxy = $null; $rq.Headers.Add('X-DXCORE', '1')
    $b = [Text.Encoding]::UTF8.GetBytes('DXCORE ação 123'); $rq.ContentLength = $b.Length; $st = $rq.GetRequestStream(); $st.Write($b, 0, $b.Length); $st.Close()
    $rs = $rq.GetResponse(); $sr = New-Object IO.StreamReader($rs.GetResponseStream(), [Text.Encoding]::UTF8); $t = $sr.ReadToEnd(); $rs.Close()
    return ((($t | ConvertFrom-Json).eco) -eq 'DXCORE ação 123')
  } catch { Log ('teste do servidor: ' + $_.Exception.Message); return $false }
}
function Servidor {
  $u = 'http://127.0.0.1:47815/'; $sv = Join-Path $dir 'servidor.ps1'
  if (-not (Test-Path $sv)) { return $null }
  if (-not (PingLocal $u)) {
    try { Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-STA', '-WindowStyle', 'Hidden', '-File', "`"$sv`"") } catch { Log ('servidor: ' + $_.Exception.Message); return $null }
    for ($i = 0; $i -lt 24; $i++) { Start-Sleep -Milliseconds 250; if (PingLocal $u) { break } }
  }
  if ((PingLocal $u) -and (TesteLocal $u)) { Log 'abrindo pelo servidor local'; return ($u + 'DXCORE.html') }
  Log 'servidor local não respondeu: abrindo do jeito anterior'; return $null
}
function Abrir {
  $uri = ([Uri]$html).AbsoluteUri
  $loc = Servidor
  $w = $null; if (-not $loc) { $w = Web }
  if ($loc) { $uri = $loc }
  if ($w) {
    try {
      $rq = [Net.HttpWebRequest]::Create($w); $rq.Method = 'HEAD'; $rq.Timeout = 4000; $rq.UserAgent = 'DXCORE-lancador'
      $rs = $rq.GetResponse(); $okw = ([int]$rs.StatusCode -eq 200); $rs.Close()
      if ($okw) { $uri = $w; Log ('abrindo pela internet: ' + $w) }
    } catch { Log ('endereço da internet não respondeu, abrindo a cópia do computador: ' + $_.Exception.Message) }
  }
  $n = Navegador
  if ($n) { Start-Process $n "--app=`"$uri`"" } elseif ($uri -ne ([Uri]$html).AbsoluteUri) { Start-Process $uri } else { Start-Process $html }
}

try {
  $cfg = Get-Content (Join-Path $dir 'atualizacao.json') -Raw | ConvertFrom-Json
  $cur = '0.0'
  if (Test-Path (Join-Path $dir 'versao.txt')) { $cur = (Get-Content (Join-Path $dir 'versao.txt') -Raw).Trim() }
  if (-not $cfg.repo -and -not $cfg.base) { throw 'canal de atualizacao nao configurado' }
  try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch {}

  function Url([string]$f) {
    if ($cfg.base) { return ($cfg.base.TrimEnd('/') + '/' + $f) }
    $br = 'main'; if ($cfg.branch) { $br = $cfg.branch }
    if ($cfg.token) { return ('https://api.github.com/repos/' + $cfg.repo + '/contents/' + $f + '?ref=' + $br) }
    return ('https://raw.githubusercontent.com/' + $cfg.repo + '/' + $br + '/' + $f)
  }
  function Baixar([string]$u, [int]$ms) {
    $rq = [Net.HttpWebRequest]::Create($u)
    $rq.Timeout = $ms; $rq.ReadWriteTimeout = $ms; $rq.UserAgent = 'DXCORE-atualizador'
    $rq.CachePolicy = New-Object Net.Cache.RequestCachePolicy([Net.Cache.RequestCacheLevel]::NoCacheNoStore)
    if ($cfg.token) { $rq.Headers.Add('Authorization', 'token ' + $cfg.token); $rq.Accept = 'application/vnd.github.raw' }
    $rs = $rq.GetResponse()
    try { $st = $rs.GetResponseStream(); $mem = New-Object IO.MemoryStream; $st.CopyTo($mem); return ,$mem.ToArray() }
    finally { $rs.Close() }
  }

  $j = [Text.Encoding]::UTF8.GetString((Baixar (Url 'versao.json') 6000)) | ConvertFrom-Json
  if ([version]$j.versao -gt [version]$cur) {
    Log ('versao nova ' + $j.versao + ' (instalada ' + $cur + '): baixando')
    $b = Baixar (Url $j.arquivo) 90000
    $sha = ([BitConverter]::ToString(([Security.Cryptography.SHA256]::Create()).ComputeHash($b))).Replace('-', '').ToLower()
    if ($sha -ne $j.sha256) { throw ('arquivo baixado nao confere (sha256 ' + $sha + ')') }
    $msg = [Text.Encoding]::ASCII.GetBytes('DXCORE|' + $j.versao + '|' + $sha)
    $sig = [Convert]::FromBase64String($j.assinatura)
    $ok = $false
    try {
      $rsa = [Security.Cryptography.RSA]::Create(); $rsa.FromXmlString($PUB)
      $ok = $rsa.VerifyData($msg, $sig, [Security.Cryptography.HashAlgorithmName]::SHA256, [Security.Cryptography.RSASignaturePadding]::Pkcs1)
    } catch {
      $rsa = New-Object Security.Cryptography.RSACryptoServiceProvider; $rsa.FromXmlString($PUB)
      $ok = $rsa.VerifyData($msg, 'SHA256', $sig)
    }
    if (-not $ok) { throw 'assinatura digital invalida: atualizacao recusada' }
    $tmp = Join-Path $dir 'DXCORE.novo.html'
    [IO.File]::WriteAllBytes($tmp, $b)
    if (Test-Path $html) { Copy-Item $html (Join-Path $dir 'DXCORE.anterior.html') -Force }
    Move-Item $tmp $html -Force
    # v7.8: arquivos do próprio lançador (abrir.ps1, ícone...) também se atualizam, com assinatura própria
    if ($j.extras -and $j.assinatura_extras) {
      try {
        $lista = ($j.extras | ForEach-Object { $_.arquivo + ':' + $_.sha256 }) -join ';'
        $m2 = [Text.Encoding]::ASCII.GetBytes('DXCORE-EXTRAS|' + $j.versao + '|' + $lista)
        $s2 = [Convert]::FromBase64String($j.assinatura_extras)
        $ok2 = $false
        try { $r2 = [Security.Cryptography.RSA]::Create(); $r2.FromXmlString($PUB); $ok2 = $r2.VerifyData($m2, $s2, [Security.Cryptography.HashAlgorithmName]::SHA256, [Security.Cryptography.RSASignaturePadding]::Pkcs1) }
        catch { $r2 = New-Object Security.Cryptography.RSACryptoServiceProvider; $r2.FromXmlString($PUB); $ok2 = $r2.VerifyData($m2, 'SHA256', $s2) }
        if (-not $ok2) { throw 'assinatura dos arquivos extras invalida' }
        foreach ($e in $j.extras) {
          if ($e.arquivo -notmatch '^[A-Za-z0-9_.-]+$') { continue }
          $eb = Baixar (Url $e.arquivo) 60000
          $es = ([BitConverter]::ToString(([Security.Cryptography.SHA256]::Create()).ComputeHash($eb))).Replace('-', '').ToLower()
          if ($es -ne $e.sha256) { throw ('extra nao confere: ' + $e.arquivo) }
          [IO.File]::WriteAllBytes((Join-Path $dir ($e.arquivo + '.novo')), $eb)
          Move-Item (Join-Path $dir ($e.arquivo + '.novo')) (Join-Path $dir $e.arquivo) -Force
          Log ('extra atualizado: ' + $e.arquivo)
        }
      } catch { Log ('extras: ' + $_.Exception.Message) }
    }
    Set-Content -Path (Join-Path $dir 'versao.txt') -Value $j.versao -Encoding ASCII
    Log ('atualizado para ' + $j.versao)
  }
} catch {
  Log ('sem atualizacao: ' + $_.Exception.Message)
}
Atalho
Abrir
