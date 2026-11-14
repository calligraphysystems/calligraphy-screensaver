@echo off
REM Calligraphy Systems — Windows fullscreen cinematic PCB screensaver
cd /d "%~dp0\.."
if exist "videos\playlist.m3u" (
  where mpv >nul 2>nul
  if not errorlevel 1 (
    mpv --fullscreen --loop-playlist=inf --really-quiet --no-audio --osd-level=0 "videos\playlist.m3u"
    goto :eof
  )
)
set "HTML=%~dp0..\index.html"
set "URL=file:///%HTML:\=/%?wake=1"
if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" (
  start "" "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" --start-fullscreen --app="%URL%"
  goto :eof
)
if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" (
  start "" "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" --start-fullscreen --app="%URL%"
  goto :eof
)
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
  start "" "%ProgramFiles%\Google\Chrome\Application\chrome.exe" --start-fullscreen --app="%URL%"
  goto :eof
)
if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe" (
  start "" "%LocalAppData%\Google\Chrome\Application\chrome.exe" --start-fullscreen --app="%URL%"
  goto :eof
)
start "" "%~dp0\..\index.html"
echo Press F in the browser for fullscreen. Space pauses. Arrow keys change boards. T/I/V toggle layers. [ ] change speed.
