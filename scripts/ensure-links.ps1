# Fallback Windows senza privilegi di symlink: collega i nuovi file dopo un git pull.
$ErrorActionPreference = "Stop"

$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Repo = Split-Path -Parent $Here
$Cfg  = if ($env:OPENCODE_CONFIG_DIR) { $env:OPENCODE_CONFIG_DIR } else { Join-Path $HOME ".config\opencode" }

function Pick($base, $names) {
  foreach ($n in $names) { if (Test-Path (Join-Path $base $n)) { return (Join-Path $base $n) } }
  return (Join-Path $base $names[0])
}

$Ag = Pick $Cfg @("agents","agent")
$Sk = Pick $Cfg @("skills","skill")
$Cm = Pick $Cfg @("commands","command")
foreach ($d in @($Ag,$Sk,$Cm)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }

$n = 0
function LinkOne($src, $dst, $isDir) {
  $script:n++
  if (Test-Path $dst) {
    $item = Get-Item $dst -Force
    if ($item.LinkType) { return }
    if ((Get-Item $src).LastWriteTime -gt $item.LastWriteTime) {
      Remove-Item $dst -Recurse -Force
      if ($isDir) { Copy-Item $src $dst -Recurse -Force } else { Copy-Item $src $dst -Force }
    }
    return
  }
  try {
    if ($isDir) { New-Item -ItemType Junction -Path $dst -Target $src | Out-Null }
    else { New-Item -ItemType SymbolicLink -Path $dst -Target $src | Out-Null }
  } catch {
    if ($isDir) { Copy-Item $src $dst -Recurse -Force } else { Copy-Item $src $dst -Force }
  }
}

Get-ChildItem (Join-Path $Repo "agent\*.md") | ForEach-Object { LinkOne $_.FullName (Join-Path $Ag $_.Name) $false }
Get-ChildItem (Join-Path $Repo "skill") -Directory | ForEach-Object { LinkOne $_.FullName (Join-Path $Sk $_.Name) $true }
Get-ChildItem (Join-Path $Repo "command\*.md") | ForEach-Object { LinkOne $_.FullName (Join-Path $Cm $_.Name) $false }

Write-Output "CHIEF-LINK: OK - agganciati $n"
