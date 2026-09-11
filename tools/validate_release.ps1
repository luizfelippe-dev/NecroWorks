param(
    [string]$GodotPath = "godot",
    [switch]$SkipExport,
    [int]$RunnerFrameLimit = 18000
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$validationRoot = Join-Path $projectRoot "artifacts\validation"
$logRoot = Join-Path $validationRoot "logs"
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null

$runners = Get-ChildItem -Path (Join-Path $projectRoot "tests") `
    -Recurse -Filter "*_runner.gd" | Sort-Object FullName
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$failed = [System.Collections.Generic.List[string]]::new()

foreach ($runner in $runners) {
    $relative = $runner.FullName.Substring($projectRoot.Length + 1).Replace("\", "/")
    $logName = $relative.Replace("/", "__").Replace(".gd", ".log")
    $logPath = Join-Path $logRoot $logName
    & $GodotPath --headless --fixed-fps 60 --quit-after $RunnerFrameLimit --path $projectRoot `
        --script "res://$relative" *> $logPath
    $logText = Get-Content -Raw -LiteralPath $logPath
    $hasScriptFailure = $logText -match "SCRIPT ERROR|Parse Error"
    $hasPassMarker = $logText -match "PASS"
    if ($LASTEXITCODE -ne 0 -or $hasScriptFailure -or -not $hasPassMarker) {
        $failed.Add($relative)
        Write-Host "FAIL $relative" -ForegroundColor Red
    }
    else {
        Write-Host "PASS $relative"
    }
}

$watch.Stop()
if ($failed.Count -gt 0) {
    throw "$($failed.Count) runner(s) failed: $($failed -join ', ')"
}

$summary = [ordered]@{
    godot_version = (& $GodotPath --version).Trim()
    runner_count = $runners.Count
    regression_seconds = [math]::Round($watch.Elapsed.TotalSeconds, 2)
    export_validated = $false
    build_size = 0
    build_sha256 = ""
}

if (-not $SkipExport) {
    $buildPath = Join-Path $projectRoot "builds\windows\NecroWorks.exe"
    New-Item -ItemType Directory -Force -Path (Split-Path $buildPath) | Out-Null
    $exportLog = Join-Path $logRoot "windows_export.log"
    & $GodotPath --headless --path $projectRoot --export-release `
        "Windows Desktop" $buildPath *> $exportLog
    if ($LASTEXITCODE -ne 0) {
        throw "Windows release export failed. See $exportLog"
    }
    $smokeLog = Join-Path $logRoot "windows_smoke.log"
    $smokeErrorLog = Join-Path $logRoot "windows_smoke_errors.log"
    $smokeProcess = Start-Process -FilePath $buildPath -ArgumentList "--headless", "--quit-after", "3" `
        -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput $smokeLog `
        -RedirectStandardError $smokeErrorLog
    $smokeText = (Get-Content -Raw -LiteralPath $smokeLog) + (Get-Content -Raw -LiteralPath $smokeErrorLog)
    if ($smokeProcess.ExitCode -ne 0 -or $smokeText -match "SCRIPT ERROR|Parse Error|ERROR:") {
        throw "Windows release smoke test failed. See $smokeLog and $smokeErrorLog"
    }
    $build = Get-Item -LiteralPath $buildPath
    $summary.export_validated = $true
    $summary.build_size = $build.Length
    $summary.build_sha256 = (Get-FileHash -Algorithm SHA256 $buildPath).Hash
}

$summaryPath = Join-Path $validationRoot "summary.json"
$summary | ConvertTo-Json | Set-Content -Encoding UTF8 $summaryPath
Write-Host "Release gate passed: $($runners.Count) runners."
Write-Host "Summary: $summaryPath"
