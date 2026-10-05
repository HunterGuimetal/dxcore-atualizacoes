# DXCORE by GUIMETAL - servidor local (v8.12)
# Roda escondido enquanto o Windows estiver aberto. Entrega o DXCORE em http://127.0.0.1:47815 e lê/grava a
# pasta de dados escolhida uma vez (fica salva em dados.json). Assim o navegador não pede mais autorização da pasta.
# Só atende o próprio computador (127.0.0.1) e só o próprio DXCORE (confere o endereço e o cabeçalho X-DXCORE).
param([int]$Port = 47815)
$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$cfgF = Join-Path $dir 'dados.json'
$log = Join-Path $dir 'servidor.log'
function Log([string]$m) {
  try {
    if ((Test-Path $log) -and ((Get-Item $log).Length -gt 200KB)) { Remove-Item $log -Force }
    Add-Content -Path $log -Value ((Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '  ' + $m)
  } catch {}
}
Add-Type -AssemblyName System.Web
Add-Type -AssemblyName System.Windows.Forms
function J([string]$s) { return [Web.HttpUtility]::JavaScriptStringEncode($s, $true) }
function Raiz {
  if (Test-Path -LiteralPath $cfgF) { try { $p = (Get-Content -LiteralPath $cfgF -Raw | ConvertFrom-Json).pasta; if ($p) { return [string]$p } } catch {} }
  return $null
}
function SalvarRaiz([string]$p) { Set-Content -LiteralPath $cfgF -Value ('{"pasta":' + (J $p) + '}') -Encoding UTF8 }
function PingJson {
  $r = Raiz; $ok = $false; if ($r) { $ok = Test-Path -LiteralPath $r }
  $nome = ''; if ($r) { $nome = Split-Path $r -Leaf }
  return ('{"ok":true,"versao":2,"pasta":' + $(if ($r) { J $r } else { 'null' }) + ',"nome":' + (J $nome) + ',"acessivel":' + $(if ($ok) { 'true' } else { 'false' }) + '}')
}
# caminho dentro da pasta de dados (nunca sai dela)
function Caminho([string]$rel) {
  $r = Raiz; if (-not $r) { throw 'pasta de dados não escolhida' }
  if ($rel -eq $null) { $rel = '' }
  $rel = $rel.Replace('/', '\').Trim('\')
  if ($rel -match '\.\.' -or $rel -match ':' -or $rel -match '[\*\?"<>\|]') { throw 'caminho inválido' }
  if ($rel -eq '') { return $r }
  return (Join-Path $r $rel)
}
# usa a pasta escolhida: se não for a DXCORE-dados (e não tiver o dxcore.json), cria a DXCORE-dados dentro dela
function UsarPasta([string]$p) {
  if (-not (Test-Path -LiteralPath $p)) { throw 'pasta não encontrada' }
  if ((Split-Path $p -Leaf) -ne 'DXCORE-dados' -and -not (Test-Path -LiteralPath (Join-Path $p 'dxcore.json'))) {
    $p = Join-Path $p 'DXCORE-dados'; if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
  }
  $marca = Join-Path $p 'dxcore.json'
  if (-not (Test-Path -LiteralPath $marca)) { [IO.File]::WriteAllText($marca, '{"app":"DXCORE","aviso":"Pasta de dados do DXCORE by GUIMETAL. Não apague nem edite os arquivos daqui."}', [Text.Encoding]::UTF8) }
  SalvarRaiz $p; Log ('pasta de dados: ' + $p)
}
function Resp($s, [int]$code, [string]$ctype, [byte[]]$body) {
  if ($body -eq $null) { $body = New-Object byte[] 0 }
  $h = "HTTP/1.1 $code OK`r`nContent-Type: $ctype`r`nContent-Length: $($body.Length)`r`nCache-Control: no-store`r`nX-Content-Type-Options: nosniff`r`nConnection: close`r`n`r`n"
  $hb = [Text.Encoding]::ASCII.GetBytes($h); $s.Write($hb, 0, $hb.Length)
  if ($body.Length -gt 0) { $s.Write($body, 0, $body.Length) }
  $s.Flush()
}
function RespJ($s, [int]$code, [string]$json) { Resp $s $code 'application/json; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes($json)) }
function Atender($c) {
  $s = $c.GetStream(); $s.ReadTimeout = 20000
  $buf = New-Object byte[] 65536; $ms = New-Object IO.MemoryStream; $he = -1
  while ($he -lt 0) {
    $n = $s.Read($buf, 0, $buf.Length); if ($n -le 0) { return }
    $ms.Write($buf, 0, $n)
    $txt = [Text.Encoding]::ASCII.GetString($ms.GetBuffer(), 0, [int]$ms.Length); $he = $txt.IndexOf("`r`n`r`n")
    if ($ms.Length -gt 65536 -and $he -lt 0) { return }
  }
  $lines = $txt.Substring(0, $he).Split("`n")
  $req = $lines[0].Trim().Split(' '); $met = $req[0].ToUpper(); $tgt = $req[1]
  $H = @{}; for ($i = 1; $i -lt $lines.Length; $i++) { $k = $lines[$i].IndexOf(':'); if ($k -gt 0) { $H[$lines[$i].Substring(0, $k).Trim().ToLower()] = $lines[$i].Substring($k + 1).Trim() } }
  # corpo
  $len = 0; if ($H.ContainsKey('content-length')) { $len = [int64]$H['content-length'] }
  $all = $ms.ToArray(); $ini = $he + 4; $body = New-Object IO.MemoryStream
  if ($all.Length -gt $ini) { $body.Write($all, $ini, $all.Length - $ini) }
  while ($body.Length -lt $len) { $n = $s.Read($buf, 0, $buf.Length); if ($n -le 0) { break }; $body.Write($buf, 0, $n) }
  # segurança: só o próprio computador e só o DXCORE
  $hosts = @("127.0.0.1:$Port", "localhost:$Port")
  if (-not ($hosts -contains $H['host'])) { RespJ $s 403 '{"erro":"host"}'; return }
  $q = @{}; $path = $tgt; $qi = $tgt.IndexOf('?')
  if ($qi -ge 0) { $path = $tgt.Substring(0, $qi); foreach ($kv in $tgt.Substring($qi + 1).Split('&')) { $e = $kv.IndexOf('='); if ($e -gt 0) { $q[$kv.Substring(0, $e)] = [Uri]::UnescapeDataString($kv.Substring($e + 1)) } } }
  if ($path -eq '/' -or $path -eq '/DXCORE.html') {
    $f = Join-Path $dir 'DXCORE.html'; Resp $s 200 'text/html; charset=utf-8' ([IO.File]::ReadAllBytes($f)); return
  }
  if (-not $path.StartsWith('/api/')) { RespJ $s 404 '{"erro":"nao encontrado"}'; return }
  if ($H['x-dxcore'] -ne '1') { RespJ $s 403 '{"erro":"cabecalho"}'; return }
  if ($H.ContainsKey('origin') -and -not ($H['origin'] -eq "http://127.0.0.1:$Port" -or $H['origin'] -eq "http://localhost:$Port")) { RespJ $s 403 '{"erro":"origem"}'; return }
  $api = $path.Substring(5)
  try {
    switch ($api) {
      'ping' { RespJ $s 200 (PingJson); return }
      'teste' { RespJ $s 200 ('{"eco":' + (J ([Text.Encoding]::UTF8.GetString($body.ToArray()))) + '}'); return }
      'pick' {
        $f = New-Object Windows.Forms.Form; $f.FormBorderStyle = 'None'; $f.Opacity = 0; $f.TopMost = $true; $f.ShowInTaskbar = $false; $f.StartPosition = 'CenterScreen'; $f.Width = 1; $f.Height = 1; $f.Show(); $f.Activate()
        $d = New-Object Windows.Forms.FolderBrowserDialog
        $d.Description = 'Escolha a pasta de dados do DXCORE (a DXCORE-dados da rede). Ela fica como padrão neste computador.'
        $d.ShowNewFolderButton = $true; $r0 = Raiz; if ($r0) { $d.SelectedPath = $r0 }
        $res = $d.ShowDialog($f); $f.Close(); $f.Dispose()
        if ($res -ne [Windows.Forms.DialogResult]::OK) { RespJ $s 200 '{"ok":false}'; return }
        UsarPasta $d.SelectedPath; RespJ $s 200 (PingJson); return
      }
      'setdir' {
        $p = [Text.Encoding]::UTF8.GetString($body.ToArray()).Trim().Trim('"')
        if (-not $p) { RespJ $s 400 '{"erro":"caminho vazio"}'; return }
        UsarPasta $p; RespJ $s 200 (PingJson); return
      }
      'stat' {
        $p = Caminho $q['p']
        if (Test-Path -LiteralPath $p) { $it = Get-Item -LiteralPath $p -Force; RespJ $s 200 ('{"exists":true,"kind":"' + $(if ($it.PSIsContainer) { 'directory' } else { 'file' }) + '"}') }
        else { RespJ $s 200 '{"exists":false}' }
        return
      }
      'ls' {
        $p = Caminho $q['p']; $o = New-Object Collections.Generic.List[string]
        if (Test-Path -LiteralPath $p) { foreach ($it in (Get-ChildItem -LiteralPath $p -Force)) { $o.Add('{"n":' + (J $it.Name) + ',"k":"' + $(if ($it.PSIsContainer) { 'directory' } else { 'file' }) + '"}') } }
        RespJ $s 200 ('[' + ($o -join ',') + ']'); return
      }
      'all' {
        $p = Caminho $q['p']; $o = New-Object Collections.Generic.List[string]
        if (Test-Path -LiteralPath $p) { foreach ($it in (Get-ChildItem -LiteralPath $p -Filter '*.json' -File -Force)) { try { $o.Add((J ([IO.File]::ReadAllText($it.FullName, [Text.Encoding]::UTF8)))) } catch {} } }
        RespJ $s 200 ('[' + ($o -join ',') + ']'); return
      }
      'mkdir' {
        $p = Caminho $q['p']; if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
        RespJ $s 200 '{"ok":true}'; return
      }
      'file' {
        $p = Caminho $q['p']
        if ($met -eq 'GET') {
          if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { RespJ $s 404 '{"erro":"nao encontrado"}'; return }
          Resp $s 200 'application/octet-stream' ([IO.File]::ReadAllBytes($p)); return
        }
        if ($met -eq 'PUT') {
          $pai = Split-Path $p -Parent; if (-not (Test-Path -LiteralPath $pai)) { New-Item -ItemType Directory -Path $pai -Force | Out-Null }
          $tmp = $p + '.gravando'; [IO.File]::WriteAllBytes($tmp, $body.ToArray())
          if (Test-Path -LiteralPath $p) { [IO.File]::Copy($tmp, $p, $true); [IO.File]::Delete($tmp) } else { [IO.File]::Move($tmp, $p) }
          RespJ $s 200 '{"ok":true}'; return
        }
        if ($met -eq 'DELETE') {
          if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Force }
          RespJ $s 200 '{"ok":true}'; return
        }
        RespJ $s 405 '{"erro":"metodo"}'; return
      }
      default { RespJ $s 404 '{"erro":"api"}'; return }
    }
  } catch { Log ('erro em ' + $api + ': ' + $_.Exception.Message); RespJ $s 500 ('{"erro":' + (J $_.Exception.Message) + '}') }
}

$L = New-Object Net.Sockets.TcpListener([Net.IPAddress]::Loopback, $Port)
try { $L.Start() } catch { Log ('porta ' + $Port + ' ocupada (servidor já aberto?): ' + $_.Exception.Message); exit }
Log ('servidor no ar: http://127.0.0.1:' + $Port + '  pasta: ' + (Raiz))
while ($true) {
  $c = $null
  try { $c = $L.AcceptTcpClient(); Atender $c }
  catch { Log ('erro: ' + $_.Exception.Message) }
  finally { if ($c) { try { $c.Close() } catch {} } }
}
