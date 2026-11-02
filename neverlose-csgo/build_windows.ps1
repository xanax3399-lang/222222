param([string]$PlatformToolset = "v143")
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
$expected = "682ce73b371349f87da6fd9365f8550e240dcdb97951e80445e70286275ad96e"
if ((Get-FileHash neverlose/bins/nl.bin -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected) { throw "Wrong CS:GO core image" }
foreach ($tool in @("cargo", "rustup", "msbuild")) { if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { throw "Missing $tool. Run from a Visual Studio Developer PowerShell with Rust installed." } }
& rustup target add x86_64-pc-windows-msvc
if ($LASTEXITCODE -ne 0) { throw "Rust Windows target installation failed" }
Push-Location server/rust-server
try {
    & cargo build --release --locked --target x86_64-pc-windows-msvc -j 3
    if ($LASTEXITCODE -ne 0) { throw "Embedded server build failed" }
} finally { Pop-Location }
New-Item -ItemType Directory -Force Release | Out-Null
Copy-Item server/rust-server/target/x86_64-pc-windows-msvc/release/neverlose-server.exe Release/neverlose-server.exe -Force
& msbuild neverlose.sln /m:3 /p:Configuration=Release /p:Platform=x86 "/p:PlatformToolset=$PlatformToolset"
if ($LASTEXITCODE -ne 0) { throw "DLL/injector build failed" }
foreach ($name in @("neverlose.dll", "injector.exe")) { if (-not (Test-Path "Release/$name")) { throw "Build did not produce $name" } }
Write-Host "Ready: Release/neverlose.dll + Release/injector.exe. Server is embedded in injector.exe."
