$ErrorActionPreference = "Continue"
$log = "C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\_bg_tree.txt"
$failed = "C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\_bg_errors.txt"

function Get-OSF($url) {
  $hdr = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ReproAI-audit"; "Accept" = "application/json" }
  for ($i=0; $i -lt 80; $i++) {
    try {
      $r = Invoke-RestMethod -Uri $url -Method Get -Headers $hdr -TimeoutSec 30
      return $r
    } catch {
      Start-Sleep -Seconds 7
    }
  }
  return $null
}

function WalkNode($node, $folderId, $prefix) {
  $url = "https://api.osf.io/v2/nodes/$node/files/osfstorage"
  if ($folderId) { $url += "/$folderId" }
  $url += "?page[size]=100"
  $resp = Get-OSF $url
  if ($null -eq $resp) {
    Add-Content -Path $failed -Value "ERR $url"
    return
  }
  foreach ($item in $resp.data) {
    $kind = $item.attributes.kind
    $name = $item.attributes.name
    $path = if ($prefix) { "$prefix/$name" } else { $name }
    $dl = ""
    if ($item.links.download) { $dl = $item.links.download }
    Add-Content -Path $log -Value "$kind`t$path`t$($item.id)`t$dl"
    if ($kind -eq 'folder') { WalkNode $node $item.id $path }
  }
  $nxt = $resp.links.next
  while ($nxt) {
    $nd = Get-OSF $nxt
    if ($null -eq $nd) { Add-Content -Path $failed -Value "ERR $nxt"; break }
    foreach ($item in $nd.data) {
      $kind = $item.attributes.kind
      $name = $item.attributes.name
      $path = if ($prefix) { "$prefix/$name" } else { $name }
      $dl = ""
      if ($item.links.download) { $dl = $item.links.download }
      Add-Content -Path $log -Value "$kind`t$path`t$($item.id)`t$dl"
      if ($kind -eq 'folder') { WalkNode $node $item.id $path }
    }
    $nxt = $nd.links.next
  }
}

WalkNode "bfhdw" $null ""
Add-Content -Path $log -Value "ALLDONE"
