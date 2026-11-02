# Neverlose CS:GO Windows build

CS:GO Legacy x86 client and injector, with a local x64 server embedded in the injector.
Build from a Visual Studio Developer PowerShell: `./build_windows.ps1 -PlatformToolset v143`.
The GitHub workflow builds on Windows and publishes `neverlose-csgo-windows.zip` as a Release asset.

The first UI is an independent Dear ImGui/D3D9 overlay for windowed/borderless CS:GO.
Existing game settings are still available through the native editor.
Gameplay and full DLL startup require validation in CS:GO; the CI tests do not launch the game.

No legacy website token is compiled in. The local server uses the protocol assets from the supplied source.
An optional website token can be supplied at runtime with `NL_WEBSITE_TOKEN`; do not commit its value.
