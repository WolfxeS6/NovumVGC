$file = 'c:\Users\gabes\Documents\Paradox Interactive\Hearts of Iron IV\mod\NovumVGC\NovumVGC\common\national_focus\usa.txt'
$startId = 'USA_status_quo'
$endId = 'USA_political_reform'

$text = Get-Content -Raw -LiteralPath $file
$startIdx = $text.IndexOf("id = $startId")
if ($startIdx -lt 0) { $startIdx = $text.IndexOf("\nid = $startId") }
$endIdx = $text.IndexOf("id = $endId", $startIdx+1)
if ($endIdx -lt 0) { $endIdx = $text.IndexOf("\nid = $endId", $startIdx+1) }

if ($startIdx -lt 0 -or $endIdx -lt 0) { Write-Output "Could not find markers"; exit 1 }

$block = $text.Substring($startIdx, $endIdx - $startIdx)

$lines = $block -split "\r?\n"
foreach ($l in $lines) {
    if ($l -match '^\s*y\s*=') { Write-Output $l }
}
