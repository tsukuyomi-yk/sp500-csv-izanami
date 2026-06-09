$ErrorActionPreference = "Stop"

$allFile = "emaxis_all.csv"
$rawFile = "sp500_raw.csv"
$outFile = "sp500_izanami.csv"

$url = "https://emaxis.am.mufg.jp/fund_file/setteirai/emaxis.csv"

Invoke-WebRequest `
    -Uri $url `
    -OutFile $allFile `
    -Headers @{ "User-Agent" = "Mozilla/5.0" }

$lines = Get-Content $allFile -Encoding Default

# eMAXIS Slim S&P500 starts at column 30
$dateCol = 30
$priceCol = 31

$raw = @()
$raw += "Date,Price"

$out = @()
$out += "Date,Open,High,Low,Close,Volume"

$count = 0

for ($i = 2; $i -lt $lines.Count; $i++) {
    $cols = $lines[$i].Split(",")

    if ($cols.Count -le $priceCol) {
        continue
    }

    $date = $cols[$dateCol].Trim()
    $price = $cols[$priceCol].Trim()

    if ($date -notmatch "^\d{4}/\d{2}/\d{2}$") {
        continue
    }

    if ($price -notmatch "^\d+$") {
        continue
    }

    $raw += ("{0},{1}" -f $date, $price)
    $out += ("{0},{1},{1},{1},{1},0" -f $date, $price)

    $count++
}

$raw | Set-Content $rawFile -Encoding Default
$out | Set-Content $outFile -Encoding Default

Write-Host "Done."
Write-Host ("Count: {0}" -f $count)
Write-Host $rawFile
Write-Host $outFile

