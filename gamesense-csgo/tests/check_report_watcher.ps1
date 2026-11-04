param([Parameter(Mandatory=$true)][string]$Runtime,[Parameter(Mandatory=$true)][string]$Fixture)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$false
$Runtime=(Resolve-Path -LiteralPath $Runtime).Path
$Fixture=(Resolve-Path -LiteralPath $Fixture).Path
$loader=Join-Path $Runtime 'injector.exe'
$probe=Join-Path $Runtime 'launcher_reports_probe.exe'
$dll=Join-Path $Runtime 'skeet.dll'
$ini=Join-Path $Runtime 'skeet_nl_points.ini'
$log=Join-Path $Runtime 'module_diagnostics.log'
$original=[IO.File]::ReadAllBytes($ini)
$active=$null;$watcher=$null
$blockedTemp=$null
try {
    # Use the real menu, checking that each toggle persists and does not touch
    # unrelated scales / the v2 braking setting. The outer 0 exits without a game.
    foreach($key in @('head_crown','late_eye_guard','unsafe_dt_recharge','automatic_reports')) {
        $choice=1+@('head_crown','late_eye_guard','unsafe_dt_recharge','automatic_reports').IndexOf($key)
        "7`n$choice`n0`n0" | & $loader
        if($LASTEXITCODE -ne 0 -or [IO.File]::ReadAllText($ini) -notmatch "(?m)^$key=0\s*$") {throw "Menu toggle did not save $key=0"}
        "7`n$choice`n0`n0" | & $loader
        if($LASTEXITCODE -ne 0 -or [IO.File]::ReadAllText($ini) -notmatch "(?m)^$key=1\s*$") {throw "Menu toggle did not restore $key=1"}
    }
    $config=[IO.File]::ReadAllText($ini)
    if($config -notmatch '(?m)^nl_brake=1\s*$' -or $config -notmatch '(?m)^head_scale_percent=80\s*$') {throw 'Unrelated settings changed'}
    $config=$config -replace '(?m)^report_interval_seconds=\d+','report_interval_seconds=2'
    [IO.File]::WriteAllText($ini,$config,[Text.UTF8Encoding]::new($false))
    Remove-Item -LiteralPath $log -ErrorAction SilentlyContinue
    $ready=Join-Path $Runtime 'fixture-ready.txt'
    Remove-Item -LiteralPath $ready -ErrorAction SilentlyContinue
    $fixtureArguments=@(('"{0}"' -f $dll),('"{0}"' -f $ready))
    $active=Start-Process -FilePath $Fixture -ArgumentList $fixtureArguments -PassThru
    $deadline=[DateTime]::UtcNow.AddSeconds(15)
    while(!(Test-Path -LiteralPath $ready)) {
        if($active.HasExited -or [DateTime]::UtcNow -gt $deadline){throw 'Fixture did not become ready'}
        Start-Sleep -Milliseconds 50
    }
    $parts=([IO.File]::ReadAllText($ready).Trim() -split ' ')
    $priority=$active.PriorityClass
    # Wrong birth time must be rejected BEFORE any report is written.
    & $loader --watch $parts[0] 0 0
    if($LASTEXITCODE -ne 1 -or (Test-Path -LiteralPath $log)){throw 'Wrong process identity was accepted'}
    $started=Join-Path $Runtime 'watcher-started.txt'
    [IO.File]::WriteAllText($ini,($config -replace '(?m)^automatic_reports=1','automatic_reports=0'),[Text.UTF8Encoding]::new($false))
    & $probe --probe-start $parts[0] $started
    if($LASTEXITCODE -ne 0 -or [IO.File]::ReadAllText($started).Trim() -ne '0' -or (Test-Path -LiteralPath $log)) {throw 'Disabled automatic reports still started'}
    [IO.File]::WriteAllText($ini,$config,[Text.UTF8Encoding]::new($false))
    & $probe --probe-start $parts[0] $started
    if($LASTEXITCODE -ne 0){throw 'Production start routine failed'}
    $watcherId=[int]([IO.File]::ReadAllText($started).Trim())
    if($watcherId -eq 0){throw 'No hidden monitor was spawned'}
    $watcher=[Diagnostics.Process]::GetProcessById($watcherId)
    [void]$watcher.Handle # Keep a real handle so ExitCode remains available after exit.
    $parentLog=[IO.File]::ReadAllText((Join-Path $Runtime 'report-probe.log'))
    if($parentLog -notmatch 'Parent log restored' -or $parentLog -match 'Automatic snapshot:') {throw 'Initial snapshot damaged the parent startup log'}
    $deadline=[DateTime]::UtcNow.AddSeconds(15)
    while(!(Test-Path -LiteralPath $log)) {
        if($watcher.HasExited -or [DateTime]::UtcNow -gt $deadline){throw 'Automatic report did not appear'}
        Start-Sleep -Milliseconds 50
    }
    while([IO.File]::ReadAllText($log) -notmatch 'Automatic snapshot: [1-9]') {
        if($watcher.HasExited -or [DateTime]::UtcNow -gt $deadline){throw 'Hidden watcher did not produce its first snapshot'}
        Start-Sleep -Milliseconds 50
    }
    if($watcher.PriorityClass -ne [Diagnostics.ProcessPriorityClass]::BelowNormal -or $active.PriorityClass -ne $priority) {throw 'Monitor priority is not below normal'}
    # A duplicate watcher exits without replacing the owner of the named mutex.
    & $loader --watch $parts[0] $parts[1] $parts[2]
    if($LASTEXITCODE -ne 0){throw 'Duplicate watcher was not handled'}
    # A directory at the exact temporary filename simulates an unwritable
    # primary destination. The real monitor must choose its LocalAppData fallback.
    $blockedTemp="$log.$watcherId.tmp"
    New-Item -ItemType Directory -Path $blockedTemp -Force | Out-Null
    if(!$active.WaitForExit(15000) -or !$watcher.WaitForExit(15000)){throw 'Watcher did not end with its target'}
    if($active.ExitCode -ne 0 -or $watcher.ExitCode -ne 0){throw 'Fixture or watcher failed'}
    $fallback=[IO.Path]::GetFullPath((Join-Path $env:LOCALAPPDATA 'GameSenseLegacy8802/Reports/module_diagnostics.log'))
    if(!(Test-Path -LiteralPath $fallback)){throw 'Fallback report was not written'}
    $report=[IO.File]::ReadAllText($fallback)
    if($report -notmatch 'Automatic snapshot: ([2-9]|\d{2,})' -or
       $report -notmatch '(?m)^Calls: 123\s*$' -or $report -notmatch 'Session ended') {throw 'No final live counters/session footer'}
    & $probe --probe-latest $fallback
    if($LASTEXITCODE -ne 0){throw 'Open-report selection did not choose the fresh fallback'}
    $before=(Get-FileHash -LiteralPath $fallback -Algorithm SHA256).Hash
    & $loader --watch $parts[0] $parts[1] $parts[2]
    if($LASTEXITCODE -ne 1 -or (Get-FileHash -LiteralPath $fallback -Algorithm SHA256).Hash -ne $before) {throw 'Dead target overwrote a valid report'}
    Remove-Item -LiteralPath $blockedTemp;$blockedTemp=$null
    if(@(Get-ChildItem -LiteralPath $Runtime -Filter 'module_diagnostics.log.*.tmp').Count) {throw 'Temporary report was not cleaned up'}
    foreach($bad in @('0','-1','4294967296','abc')) {
        & $loader --watch $bad 0 0
        if($LASTEXITCODE -ne 1){throw 'Invalid watcher arguments accepted'}
    }
    Write-Host 'PASS: menu persistence, actual DLL reads, periodic counters, identity, duplicate watcher, process exit and retained last report.'
    Write-Host 'The fixture is not CS:GO; gameplay was not executed.'
} catch {
    Write-Host ('REPORT TEST FAILURE: ' + $_.Exception.Message)
    Write-Host $_.ScriptStackTrace
    foreach($candidate in @($log,(Join-Path $env:LOCALAPPDATA 'GameSenseLegacy8802/Reports/module_diagnostics.log'))) {
        if(Test-Path -LiteralPath $candidate){Write-Host ('REPORT CONTENT: ' + $candidate);Get-Content -LiteralPath $candidate -Tail 45}
    }
    throw
} finally {
    if($watcher -and !$watcher.HasExited){Stop-Process -Id $watcher.Id -ErrorAction SilentlyContinue}
    if($active -and !$active.HasExited){Stop-Process -Id $active.Id -ErrorAction SilentlyContinue}
    if($blockedTemp -and (Test-Path -LiteralPath $blockedTemp)){Remove-Item -LiteralPath $blockedTemp -Force}
    [IO.File]::WriteAllBytes($ini,$original)
}
