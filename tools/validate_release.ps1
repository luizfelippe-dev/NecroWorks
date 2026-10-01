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

# setup-godot can expose an extensionless symlink to the Windows GUI binary.
# Resolve it, wait for each process and use Godot's own log file instead of stdout.
$godotCommand = Get-Command $GodotPath -ErrorAction Stop
$godotFile = Get-Item -LiteralPath $godotCommand.Source
if ($godotFile.LinkType) { $godotFile = $godotFile.ResolveLinkTarget($true) }
$GodotPath = $godotFile.FullName

function Invoke-GodotLogged {
    param([string[]]$EngineArguments, [string]$LogPath)
    $arguments = @('--log-file', $LogPath) + $EngineArguments
    $quoted = $arguments | ForEach-Object { '"' + $_.Replace('"', '\"') + '"' }
    $process = Start-Process -FilePath $GodotPath -ArgumentList ($quoted -join ' ') `
        -WindowStyle Hidden -PassThru
    if (-not $process.WaitForExit(600000)) {
        $process.Kill($true)
        throw "Godot exceeded ten minutes. See $LogPath"
    }
    $process.WaitForExit()
    if (-not (Test-Path -LiteralPath $LogPath) -or (Get-Item $LogPath).Length -eq 0) {
        throw "Godot produced no log (exit $($process.ExitCode)). Executable: $GodotPath"
    }
    return $process.ExitCode
}

$importLog = Join-Path $logRoot 'project_import.log'
$importExit = Invoke-GodotLogged -EngineArguments @('--headless', '--path', $projectRoot, '--editor', '--import', '--quit') -LogPath $importLog
$importText = Get-Content -Raw -LiteralPath $importLog
if ($importExit -ne 0 -or $importText -match 'SCRIPT ERROR|Parse Error|ERROR:') {
    throw "Project import failed. See $importLog"
}

$runners = Get-ChildItem -Path (Join-Path $projectRoot "tests") `
    -Recurse -Filter "*_runner.gd" | Sort-Object FullName
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$failed = [System.Collections.Generic.List[string]]::new()

foreach ($runner in $runners) {
    $relative = $runner.FullName.Substring($projectRoot.Length + 1).Replace("\", "/")
    $logName = $relative.Replace("/", "__").Replace(".gd", ".log")
    $logPath = Join-Path $logRoot $logName
    $runnerExit = Invoke-GodotLogged -EngineArguments @('--headless', '--fixed-fps', '60', '--quit-after', "$RunnerFrameLimit", '--path', $projectRoot, '--script', "res://$relative") -LogPath $logPath
    $logText = Get-Content -Raw -LiteralPath $logPath
    $hasScriptFailure = $logText -match "SCRIPT ERROR|Parse Error"
    $hasPassMarker = $logText -match "PASS"
    if ($runnerExit -ne 0 -or $hasScriptFailure -or -not $hasPassMarker) {
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
    godot_version = ($importText -split "`n" | Where-Object { $_ -match 'Godot Engine v' } | Select-Object -First 1).Trim()
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
    $exportExit = Invoke-GodotLogged -EngineArguments @('--headless', '--path', $projectRoot, '--export-release', 'Windows Desktop', $buildPath) -LogPath $exportLog
    if ($exportExit -ne 0 -or (Get-Content -Raw $exportLog) -match 'SCRIPT ERROR|Parse Error|ERROR:') {
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
