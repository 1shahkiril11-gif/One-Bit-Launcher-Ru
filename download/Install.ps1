param(
    [string]$Target = "$env:ProgramFiles\OneBitLauncher",
    [switch]$NoShortcut
)

$ErrorActionPreference = 'Stop'
$source = $PSScriptRoot
$log = Join-Path $PSScriptRoot 'install.log'

function Say($msg) {
    Write-Host $msg
    Add-Content -Path $log -Value ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $msg) -Encoding UTF8
}

Say "Установка One Bit Launcher в $Target"

$gameSrc = Join-Path $source 'HunterAscent.exe'
if (-not (Test-Path $gameSrc)) {
    Say "ОШИБКА (402): рядом с установщиком нет HunterAscent.exe"
    exit 1
}

New-Item -ItemType Directory -Force -Path $Target | Out-Null

Say 'копирую файлы игры…'
robocopy $source $Target /E /XF install.log setup.bat Install.ps1 /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) {
    Say "ОШИБКА (802): не удалось скопировать файлы, код robocopy $LASTEXITCODE"
    exit 1
}

$settings = Join-Path $Target 'settings.json'
$json = '{"gameDir":"' + ($Target -replace '\\', '\\') + '"}'
[System.IO.File]::WriteAllText($settings, $json, (New-Object System.Text.UTF8Encoding($false)))
Say "settings.json записан: $json"

if (-not $NoShortcut) {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $lnk = Join-Path $desktop 'One Bit Launcher.lnk'
    $ws = New-Object -ComObject WScript.Shell
    $sc = $ws.CreateShortcut($lnk)
    $sc.TargetPath = Join-Path $Target 'HunterLauncher.exe'
    $sc.WorkingDirectory = $Target
    $sc.IconLocation = Join-Path $Target 'HunterLauncher.exe'
    $sc.Description = 'One Bit Launcher'
    $sc.Save()
    Say "ярлык на рабочем столе: $lnk"
}

Say 'готово. Запуск: HunterLauncher.exe'
Say "папка игры: $Target"
