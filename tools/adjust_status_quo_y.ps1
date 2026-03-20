$file = 'c:\Users\gabes\Documents\Paradox Interactive\Hearts of Iron IV\mod\NovumVGC\NovumVGC\common\national_focus\usa.txt'
$startId = 'USA_status_quo'
$endId = 'USA_political_reform'

$text = Get-Content -Raw -LiteralPath $file
$startIdx = $text.IndexOf("`n id = $startId")
if ($startIdx -lt 0) { $startIdx = $text.IndexOf("id = $startId") }
if ($startIdx -lt 0) { Write-Output "start id not found"; exit 1 }
$endIdx = $text.IndexOf("`n id = $endId", $startIdx+1)
if ($endIdx -lt 0) { $endIdx = $text.IndexOf("id = $endId", $startIdx+1) }
if ($endIdx -lt 0) { Write-Output "end id not found"; exit 1 }

$prefix = $text.Substring(0, $startIdx)
$block = $text.Substring($startIdx, $endIdx - $startIdx)
$suffix = $text.Substring($endIdx)

$pattern = '(?m)^(\s*)y\s*=\s*(-?\d+)(\s*)$'
$count = 0
$evaluator = {
    param($m)
    $indent = $m.Groups[1].Value
    $num = [int]$m.Groups[2].Value
    $tail = $m.Groups[3].Value
    $new = "${indent}y = $($num + 1)$tail"
    $script:count++
    return $new
}

$newBlock = [regex]::Replace($block, $pattern, $evaluator)

if ($count -eq 0) { Write-Output "No y= lines found in block; no changes made"; exit 0 }

# backup
$bak = $file + '.bak'
Copy-Item -LiteralPath $file -Destination $bak -Force

$newText = $prefix + $newBlock + $suffix
Set-Content -LiteralPath $file -Value $newText -Encoding UTF8
Write-Output "Updated $count y values between $startId and $endId. Backup at $bak"