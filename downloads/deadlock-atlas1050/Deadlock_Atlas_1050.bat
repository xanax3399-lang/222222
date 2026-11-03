@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Deadlock - GTX 1050 2GB - AtlasOS / Windows 10
set "DL_PROFILE_FILE=%~f0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$text=[IO.File]::ReadAllText($env:DL_PROFILE_FILE); $marker='#DEADLOCK_PS_PAYLOAD'; $offset=$text.LastIndexOf($marker,[StringComparison]::Ordinal); if($offset -lt 0){exit 2}; & ([scriptblock]::Create($text.Substring($offset+$marker.Length)))"
set "DL_RESULT=%errorlevel%"
if not "%DL_RESULT%"=="0" pause
exit /b %DL_RESULT%
#DEADLOCK_PS_PAYLOAD
# Windows PowerShell 5.1. No downloads or administrator rights required.
$ErrorActionPreference = 'Stop'
$script:Root = Join-Path $env:LOCALAPPDATA 'Deadlock1050Profile'
$script:Backup = Join-Path $script:Root 'backup.json'
$script:Log = Join-Path $script:Root 'profile.log'
$script:GpuKey = 'Software\Microsoft\DirectX\UserGpuPreferences'
$script:RegistryRoot = $null
$script:CaptureTargets = @(
    @{ SubKey='Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name='AppCaptureEnabled' },
    @{ SubKey='System\GameConfigStore'; Name='GameDVR_Enabled' }
)

function Say([string]$Message) {
    Write-Host $Message
    try {
        Add-Content -LiteralPath $script:Log -Value ('{0} {1}' -f (Get-Date -Format s),$Message) -Encoding UTF8
    } catch { }
}

function Empty-State {
    return @{ Version=1; Entries=@() }
}

function Read-State {
    if (-not (Test-Path -LiteralPath $script:Backup)) { return Empty-State }
    $state = Get-Content -LiteralPath $script:Backup -Raw | ConvertFrom-Json
    if ($state.Version -ne 1) { throw 'Unsupported backup version. Keep backup.json and profile.log.' }
    return @{ Version=1; Entries=@($state.Entries) }
}

function Save-State($State) {
    # Write the original value durably BEFORE changing it. Repeated runs never
    # replace the original snapshot with the already optimized value.
    $temp = Join-Path $script:Root ([guid]::NewGuid().ToString('N') + '.tmp')
    try {
        $json = ConvertTo-Json -InputObject $State -Depth 6
        [IO.File]::WriteAllText($temp,$json,[Text.UTF8Encoding]::new($false))
        if (Test-Path -LiteralPath $script:Backup) {
            [IO.File]::Replace($temp,$script:Backup,[System.Management.Automation.Language.NullString]::Value)
        } else {
            [IO.File]::Move($temp,$script:Backup)
        }
    } finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
    }
}

function Valid-Target([string]$SubKey,[string]$Name) {
    foreach ($target in $script:CaptureTargets) {
        if ($SubKey -eq $target.SubKey -and $Name -eq $target.Name) { return $true }
    }
    return ($SubKey -eq $script:GpuKey -and
        [IO.Path]::IsPathRooted($Name) -and
        [IO.Path]::GetFileName($Name) -in @('deadlock.exe','project8.exe','citadel.exe'))
}

function Set-TrackedValue([string]$SubKey,[string]$Name,$Value,[string]$Kind,[bool]$ExistingOnly) {
    if (-not (Valid-Target $SubKey $Name)) { throw 'Unexpected registry target.' }
    $key = $script:RegistryRoot.OpenSubKey($SubKey,$true)
    $keyExisted = ($null -ne $key)
    try {
        $existed = ($keyExisted -and $Name -in $key.GetValueNames())
        if ($ExistingOnly -and -not $existed) {
            Say ('Already removed / not configured by Windows or Atlas: {0}' -f $Name)
            return
        }
        $oldKind = $null; $oldValue = $null
        if ($existed) {
            $oldKind = $key.GetValueKind($Name).ToString()
            if ($oldKind -notin @('DWord','String','ExpandString')) {
                Say ('Skipped unusual registry value type: {0}' -f $Name)
                return
            }
            $oldValue = $key.GetValue($Name,$null,[Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
            if ($oldKind -eq $Kind -and $oldValue -ceq $Value) {
                Say ('Already set: {0}' -f $Name)
                return
            }
        }
        $state = Read-State
        $saved = @($state.Entries | Where-Object { $_.SubKey -eq $SubKey -and $_.Name -eq $Name })
        if ($saved.Count -eq 0) {
            $entry = @{ SubKey=$SubKey; Name=$Name; KeyExisted=$keyExisted;
                Existed=$existed; Kind=$oldKind; Data=$oldValue }
            $state.Entries = @($state.Entries) + @($entry)
            Save-State $state
        }
        if ($null -eq $key) { $key = $script:RegistryRoot.CreateSubKey($SubKey) }
        $key.SetValue($Name,$Value,[Microsoft.Win32.RegistryValueKind]$Kind)
        Say ('Applied: {0}' -f $Name)
    } finally {
        if ($null -ne $key) { $key.Dispose() }
    }
}

function Restore-Profile {
    $state = Read-State
    if ($state.Entries.Count -eq 0) { Say 'No settings to restore.'; return }
    $left = @()
    foreach ($entry in $state.Entries) {
        $key = $null
        try {
            if (-not (Valid-Target $entry.SubKey $entry.Name)) { throw 'Invalid target in backup.' }
            if ($entry.Existed) {
                if ($entry.Kind -notin @('DWord','String','ExpandString')) { throw 'Invalid value type in backup.' }
                $key = $script:RegistryRoot.CreateSubKey([string]$entry.SubKey)
                $data = $entry.Data
                if ($entry.Kind -eq 'DWord') { $data = [int]$data }
                $key.SetValue([string]$entry.Name,$data,[Microsoft.Win32.RegistryValueKind]([string]$entry.Kind))
            } else {
                $key = $script:RegistryRoot.OpenSubKey([string]$entry.SubKey,$true)
                if ($null -ne $key) { $key.DeleteValue([string]$entry.Name,$false) }
            }
            Say ('Restored: {0}' -f $entry.Name)
            $removeEmpty = (-not $entry.KeyExisted -and $null -ne $key -and
                $key.ValueCount -eq 0 -and $key.SubKeyCount -eq 0)
            if ($null -ne $key) { $key.Dispose(); $key = $null }
            if ($removeEmpty) {
                $script:RegistryRoot.DeleteSubKey([string]$entry.SubKey,$false)
            }
        } catch {
            Say ('Restore failed: {0}: {1}' -f $entry.Name,$_.Exception.Message)
            $left += $entry
        } finally {
            if ($null -ne $key) { $key.Dispose() }
        }
    }
    $state.Entries = $left
    Save-State $state
    if ($left.Count -eq 0) {
        Remove-Item -LiteralPath $script:Backup
        Say 'Original registry settings restored. No reboot is required for the launcher.'
    } else {
        Say 'Some settings remain in backup.json. Retry Restore from the same Windows account.'
    }
}

function Find-Steam {
    $paths = @()
    foreach ($item in @(
        @{ Path='HKCU:\Software\Valve\Steam'; Name='SteamPath' },
        @{ Path='HKLM:\SOFTWARE\WOW6432Node\Valve\Steam'; Name='InstallPath' },
        @{ Path='HKLM:\SOFTWARE\Valve\Steam'; Name='InstallPath' }
    )) {
        try {
            $value = (Get-ItemProperty -LiteralPath $item.Path -Name $item.Name -ErrorAction Stop).($item.Name)
            if ($value) { $paths += [string]$value }
        } catch { }
    }
    if (${env:ProgramFiles(x86)}) { $paths += (Join-Path ${env:ProgramFiles(x86)} 'Steam') }
    foreach ($path in $paths) {
        $exe = Join-Path $path 'steam.exe'
        if (Test-Path -LiteralPath $exe -PathType Leaf) { return [IO.Path]::GetFullPath($exe) }
    }
    throw 'Steam was not found. Install/start Steam for this Windows account and retry.'
}

function Find-Game([string]$SteamExe) {
    $steamRoot = [IO.Path]::GetDirectoryName($SteamExe)
    $libraries = @($steamRoot)
    foreach ($vdf in @((Join-Path $steamRoot 'steamapps\libraryfolders.vdf'),(Join-Path $steamRoot 'config\libraryfolders.vdf'))) {
        if (-not (Test-Path -LiteralPath $vdf)) { continue }
        $raw = Get-Content -LiteralPath $vdf -Raw
        foreach ($match in [regex]::Matches($raw,'"(?:path|[0-9]+)"\s*"((?:\\.|[^"\\])*)"')) {
            $path = $match.Groups[1].Value.Replace('\\','\')
            if ([IO.Path]::IsPathRooted($path)) { $libraries += $path }
        }
    }
    foreach ($library in ($libraries | Select-Object -Unique)) {
        $manifest = Join-Path $library 'steamapps\appmanifest_1422450.acf'
        if (-not (Test-Path -LiteralPath $manifest)) { continue }
        $raw = Get-Content -LiteralPath $manifest -Raw
        $match = [regex]::Match($raw,'"installdir"\s*"([^"\r\n]+)"')
        if (-not $match.Success) { continue }
        $install = Join-Path (Join-Path $library 'steamapps\common') $match.Groups[1].Value
        foreach ($relative in @('game\bin\win64\deadlock.exe','game\bin\win64\project8.exe','game\bin\win64\citadel.exe')) {
            $exe = Join-Path $install $relative
            if (Test-Path -LiteralPath $exe -PathType Leaf) { return [IO.Path]::GetFullPath($exe) }
        }
    }
    return $null
}

function Merge-GpuPreference([string]$Current) {
    $tokens = @(); $found = $false
    foreach ($token in ($Current -split ';')) {
        if ($token -match '^\s*GpuPreference\s*=') {
            if (-not $found) { $tokens += 'GpuPreference=2'; $found = $true }
        } elseif ($token.Trim().Length) { $tokens += $token }
    }
    if (-not $found) { $tokens += 'GpuPreference=2' }
    return (($tokens -join ';') + ';')
}

function Apply-Profile([string]$GameExe) {
    Say 'Atlas power plan, services, security, pagefile and Discord settings are preserved.'
    foreach ($target in $script:CaptureTargets) {
        try { Set-TrackedValue $target.SubKey $target.Name ([int]0) 'DWord' $true }
        catch { Say ('Capture setting skipped: {0}' -f $_.Exception.Message) }
    }
    if ($GameExe) {
        try {
            $existing = ''; $key = $script:RegistryRoot.OpenSubKey($script:GpuKey,$false)
            try {
                if ($null -ne $key -and $GameExe -in $key.GetValueNames() -and
                    $key.GetValueKind($GameExe) -eq [Microsoft.Win32.RegistryValueKind]::String) {
                    $existing = [string]$key.GetValue($GameExe,$null,[Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                }
            } finally { if ($null -ne $key) { $key.Dispose() } }
            Set-TrackedValue $script:GpuKey $GameExe (Merge-GpuPreference $existing) 'String' $false
        }
        catch { Say ('GPU preference skipped: {0}' -f $_.Exception.Message) }
    } else {
        Say 'Game EXE not found in Steam libraries: per-app GPU selection skipped.'
        Say 'Steam can still launch the game if it is installed. Check the library manually if needed.'
    }
}

function Show-Info {
    Say 'Target: AtlasOS / Windows 10, i5-4590, GTX 1050 2GB, 16GB, 1440x1080, Discord open.'
    try {
        Get-CimInstance Win32_Processor | ForEach-Object { Say ('CPU: {0}' -f $_.Name) }
        Get-CimInstance Win32_VideoController | ForEach-Object { Say ('GPU: {0}; driver: {1}' -f $_.Name,$_.DriverVersion) }
        $os = Get-CimInstance Win32_OperatingSystem
        Say ('OS: {0}; build: {1}; RAM: {2:N1} GB' -f $os.Caption,$os.BuildNumber,($os.TotalVisibleMemorySize/1MB))
        & powercfg.exe /getactivescheme
    } catch { Say ('System details unavailable: {0}' -f $_.Exception.Message) }
    Say ('Backup and log: {0}' -f $script:Root)
    Say 'Recommended: textures LOW, effects/shadows LOW, VSync OFF, render scale 65-75%.'
    Say 'Disable Discord game overlay. Keep voice; avoid streams/video while playing.'
    Say 'Read README_RU.txt for NVIDIA, Discord and stretched resolution settings.'
}

function Launch-Game([int]$Cap) {
    $steam = Find-Steam
    $game = Find-Game $steam
    if ($game) {
        $live = @(Get-Process -Name ([IO.Path]::GetFileNameWithoutExtension($game)) -ErrorAction SilentlyContinue |
            Where-Object { try { $_.Path -eq $game } catch { $false } })
        if ($live.Count) {
            Say 'Deadlock is already running. Close it normally, then use this launcher again.'
            return
        }
    }
    Apply-Profile $game
    $options = @('-applaunch','1422450','-dx11','-fullscreen','-w','1440','-h','1080','+fps_max',([string]$Cap))
    Say ('Steam launch: 1440x1080 / DX11 / fps_max {0}' -f $Cap)
    Say 'Discord stays open. Process priorities and CPU affinity are unchanged.'
    Say 'Select 1440x1080 / 4:3 in game if this game build ignores a launch size.'
    Start-Process -FilePath $steam -ArgumentList $options
    Say 'Launch request sent to Steam. This is not confirmation that the game started.'
}

function Main {
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) { throw 'Windows only.' }
    $script:RegistryRoot = [Microsoft.Win32.Registry]::CurrentUser
    New-Item -ItemType Directory -Path $script:Root -Force | Out-Null
    $sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $mutex = [Threading.Mutex]::new($false,('Local\Deadlock1050Profile-' + $sid))
    $locked = $false
    try {
        try { $locked = $mutex.WaitOne(0) }
        catch [Threading.AbandonedMutexException] { $locked = $true }
        if (-not $locked) { throw 'Another copy of this launcher is open. Close that window first.' }
        Say 'Deadlock GTX 1050 2GB / i5-4590 / AtlasOS - reversible per-user profile'
        while ($true) {
            Write-Host ''
            Write-Host '1 - Apply profile + launch 1440x1080 MAX FPS (no cap)'
            Write-Host '2 - Apply profile + launch 1440x1080 with a 60 FPS cap'
            Write-Host '3 - Restore original Windows per-user settings'
            Write-Host '4 - System information / recommendations'
            Write-Host '0 - Exit'
            $choice = Read-Host 'Choose 1, 2, 3, 4 or 0'
            try {
                switch ($choice) {
                    '1' { Launch-Game 0 }
                    '2' { Launch-Game 60 }
                    '3' { Restore-Profile }
                    '4' { Show-Info }
                    '0' { return }
                    default { Say 'Unknown choice.' }
                }
            } catch { Say ('ERROR: {0}' -f $_.Exception.Message) }
        }
    } finally {
        if ($locked) { $mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
}

try { Main }
catch { Write-Host ('ERROR: {0}' -f $_.Exception.Message); exit 1 }
