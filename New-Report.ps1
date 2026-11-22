param(
    [switch]$DryRun
)

$path = Join-Path (Get-Location).Path 'report.txt'

if ($DryRun) {
    Write-Output "Would create: $path"
    return
}

if (Test-Path -LiteralPath $path) {
    Write-Output "Already exists: $path"
    return
}

New-Item -Path $path -ItemType File -Value "Report generated.`n" -ErrorAction Stop |
    Out-Null
Write-Output "Created: $path"