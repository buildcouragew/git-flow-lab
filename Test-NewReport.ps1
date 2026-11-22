$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $PSScriptRoot 'New-Report.ps1'
$tempDir = New-Item -ItemType Directory -Path (
    Join-Path ([IO.Path]::GetTempPath()) "git-flow-lab-$([guid]::NewGuid())"
)
$reportPath = Join-Path $tempDir.FullName 'report.txt'

Push-Location $tempDir.FullName
try {
    # 预览空目录，显示目标路径且不创建文件
    $preview = & $scriptPath -DryRun
    if ($preview -cne "Would create: $reportPath") {
        throw "Unexpected preview output: $preview"
    }
    if (Test-Path -LiteralPath $reportPath) {
        throw 'Dry run created a file.'
    }

    # 正常执行，创建文件
    & $scriptPath | Out-Null
    if (-not (Test-Path -LiteralPath $reportPath -PathType Leaf)) {
        throw 'Normal execution did not create the report.'
    }

    # 预览已有文件，保留原内容
    Set-Content -LiteralPath $reportPath -Value 'Keep this content' -NoNewline
    $preview = & $scriptPath -DryRun
    if ($preview -cne "Would keep existing file: $reportPath") {
        throw "Unexpected preview for an existing report: $preview"
    }

    
    # 正常执行遇到已有文件，给出提示并保留原内容
    $result = & $scriptPath
    if ($result -cne "Already exists: $reportPath" -or
        (Get-Content -LiteralPath $reportPath -Raw) -cne 'Keep this content') {
        throw 'Normal execution did not preserve the existing report as expected.'
    }

    Write-Output 'All report tests passed.'
}
finally {
    Pop-Location
    Remove-Item -LiteralPath $reportPath -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $tempDir.FullName
}