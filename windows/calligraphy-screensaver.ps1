# Calligraphy Systems — Windows PowerShell launcher
$Root = Split-Path -Parent $PSScriptRoot
$Playlist = Join-Path $Root "videos\playlist.m3u"
$Html = Join-Path $Root "index.html"
$mpv = Get-Command mpv -ErrorAction SilentlyContinue
if ($mpv -and (Test-Path $Playlist)) {
    & mpv --fullscreen --loop-playlist=inf --really-quiet --no-audio --osd-level=0 $Playlist
    exit $LASTEXITCODE
}
$fileUrl = ("file:///" + ($Html -replace "\\", "/")) + "?wake=1"
$candidates = @(
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "$env:LocalAppData\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe",
    "$env:LocalAppData\BraveSoftware\Brave-Browser\Application\brave.exe"
)
foreach ($bin in $candidates) {
    if (Test-Path $bin) {
        Start-Process $bin -ArgumentList @("--start-fullscreen", "--app=$fileUrl")
        Write-Host "Launched fullscreen --app screensaver (?wake=1). Esc/Q/mouse exits."
        exit 0
    }
}
Start-Process $Html
Write-Host "Press F in the browser for fullscreen. T/I/V toggle layers; [ ] change speed."
