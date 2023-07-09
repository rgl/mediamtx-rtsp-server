# set keyboard layout.
# NB you can get the name from the list:
#      [Globalization.CultureInfo]::GetCultures('InstalledWin32Cultures') | Out-GridView
Set-WinUserLanguageList pt-PT -Force

# set the date format, number format, etc.
Set-Culture pt-PT

# set the welcome screen culture and keyboard layout.
# NB the .DEFAULT key is for the local SYSTEM account (S-1-5-18).
New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
'Control Panel\International','Keyboard Layout' | ForEach-Object {
    Remove-Item -Path "HKU:.DEFAULT\$_" -Recurse -Force
    Copy-Item -Path "HKCU:$_" -Destination "HKU:.DEFAULT\$_" -Recurse -Force
}
Remove-PSDrive HKU

# set the timezone.
# use Get-TimeZone -ListAvailable to list the available timezone ids.
Set-TimeZone -Id 'GMT Standard Time'

# show window content while dragging.
Set-ItemProperty -Path 'HKCU:Control Panel\Desktop' -Name DragFullWindows -Value 1

# show hidden files.
Set-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Value 1

# show protected operating system files.
Set-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSuperHidden -Value 1

# show file extensions.
Set-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Value 0

# set the desktop wallpaper.
Add-Type -AssemblyName System.Drawing
$backgroundColor = [System.Drawing.Color]::FromArgb(0x27, 0x27, 0x27)
$backgroundPath = 'C:\Windows\Web\Wallpaper\Windows\mediamtx.png'
$logo = [System.Drawing.Image]::FromFile((Resolve-Path 'mediamtx.png'))
$b = New-Object System.Drawing.Bitmap($logo.Width, $logo.Height)
$g = [System.Drawing.Graphics]::FromImage($b)
$g.Clear($backgroundColor)
$g.DrawImage($logo, 0, 0, $logo.Width, $logo.Height)
$b.Save($backgroundPath)
Set-ItemProperty -Path 'HKCU:Control Panel\Desktop' -Name Wallpaper -Value $backgroundPath
Set-ItemProperty -Path 'HKCU:Control Panel\Desktop' -Name WallpaperStyle -Value 0
Set-ItemProperty -Path 'HKCU:Control Panel\Desktop' -Name TileWallpaper -Value 0
Set-ItemProperty -Path 'HKCU:Control Panel\Colors' -Name Background -Value ($backgroundColor.R,$backgroundColor.G,$backgroundColor.B -join ' ')
Add-Type @'
using System;
using System.Drawing;
using System.Runtime.InteropServices;

public static class WindowsWallpaper
{
    private const int COLOR_DESKTOP = 0x01;

    [DllImport("user32", SetLastError=true)]
    private static extern bool SetSysColors(int cElements, int[] lpaElements, int[] lpaRgbValues);

    private const uint SPI_SETDESKWALLPAPER = 0x14;
    private const uint SPIF_UPDATEINIFILE = 0x01;
    private const uint SPIF_SENDWININICHANGE = 0x02;

    [DllImport("user32", SetLastError=true)]
    private static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);

    public static void Set(Color color, string path)
    {
        var elements = new int[] { COLOR_DESKTOP };
        var colors = new int[] { ColorTranslator.ToWin32(color) };
        SetSysColors(elements.Length, elements, colors);
        SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF_SENDWININICHANGE);
    }
}
'@ -ReferencedAssemblies System.Drawing
[WindowsWallpaper]::Set($backgroundColor, $backgroundPath)

# cleanup the taskbar by removing the existing buttons and unpinning all applications; once the user logs on.
# NB the shell executes these RunOnce commands about ~10s after the user logs on.
[IO.File]::WriteAllText(
    "$env:USERPROFILE\ConfigureDesktop.ps1",
@'
# unpin all applications from the taskbar.
# NB this can only be done in a logged on session.
$pinnedTaskbarPath = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
(New-Object -Com Shell.Application).NameSpace($pinnedTaskbarPath).Items() `
    | ForEach-Object {
        $unpinVerb = $_.Verbs() | Where-Object { $_.Name -eq 'Unpin from tas&kbar' }
        if ($unpinVerb) {
            $unpinVerb.DoIt()
        } else {
            $shortcut = (New-Object -Com WScript.Shell).CreateShortcut($_.Path)
            if (!$shortcut.TargetPath -and ($shortcut.IconLocation -eq '%windir%\explorer.exe,0')) {
                Remove-Item -Force $_.Path
            }
        }
    }
Get-Item HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband `
    | Set-ItemProperty -Name Favorites -Value 0xff `
    | Set-ItemProperty -Name FavoritesResolve -Value 0xff `
    | Set-ItemProperty -Name FavoritesVersion -Value 3 `
    | Set-ItemProperty -Name FavoritesChanges -Value 1 `
    | Set-ItemProperty -Name FavoritesRemovedChanges -Value 1

# hide the search button.
Set-ItemProperty -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchboxTaskbarMode -Value 0

# hide the task view button.
Set-ItemProperty -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTaskViewButton -Value 0

# never combine the taskbar buttons.
# possibe values:
#   0: always combine and hide labels (default)
#   1: combine when taskbar is full
#   2: never combine
Set-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name TaskbarGlomLevel -Value 2

# remove default or uneeded files.
@(
    "$env:USERPROFILE\Desktop\desktop.ini"
    "$env:USERPROFILE\Desktop\*.lnk"
    "$env:USERPROFILE\Desktop\*.url"
    "$env:PUBLIC\Desktop\desktop.ini"
    "$env:PUBLIC\Desktop\*.lnk"
    "$env:PUBLIC\Desktop\*.url"
) | Remove-Item -Force -ErrorAction SilentlyContinue

# add desktop shortcuts.
Import-Module C:\ProgramData\chocolatey\helpers\chocolateyInstaller.psm1
@(
    ,('Firefox', 'C:\Program Files\Mozilla Firefox\firefox.exe')
    ,('Google Chrome', 'C:\Program Files\Google\Chrome\Application\chrome.exe')
    ,('smptebars VLC RTSP (Real Time Streaming Protocol)', 'C:\Program Files\VideoLAN\VLC\vlc.exe', '-vvv rtsp://localhost:8554/smptebars')
    ,('smptebars MPV RTSP (Real Time Streaming Protocol)', 'C:\ProgramData\chocolatey\lib\mpvio.install\tools\mpv.exe', 'rtsp://localhost:8554/smptebars')
    ,('smptebars WHEP (WebRTC-HTTP Egress Protocol)', 'http://localhost:8889/smptebars')
    ,('smptebars HLS (HTTP Live Streaming)', 'http://localhost:8888/smptebars')
) | ForEach-Object {
    if ($_[1] -like 'http*') {
        [IO.File]::WriteAllText("$env:USERPROFILE\Desktop\$($_[0]).url", @"
[InternetShortcut]
URL=$($_[1])
"@)
    } elseif (!(Test-Path $_[1])) {
        return
    } elseif ($_[1] -like '*.lnk') {
        Copy-Item $_[1] "$env:USERPROFILE\Desktop\$($_[0]).lnk"
    } else {
        $extraArguments = @{
            IconLocation = $_[1]
        }
        if ($_.Length -gt 2) {
            $extraArguments.Arguments = $_[2]
            $extraArguments.IconLocation = $_[3]
            $extraArguments.WorkingDirectory = $_[4]
        }
        # add into the Desktop.
        Install-ChocolateyShortcut `
            -ShortcutFilePath "$env:USERPROFILE\Desktop\$($_[0]).lnk" `
            -TargetPath $_[1] `
            @extraArguments
        # # add into the Start Menu.
        # Copy-Item `
        #     "$env:USERPROFILE\Desktop\$($_[0]).lnk" `
        #     "C:\Users\All Users\Microsoft\Windows\Start Menu\Programs"
    }
}

# execute hooks.
Import-Module C:\ProgramData\chocolatey\helpers\chocolateyInstaller.psm1
Get-ChildItem "$PSScriptRoot\ConfigureDesktop-*.ps1" `
    | Sort-Object -Property Name `
    | ForEach-Object { &$_ }

# restart explorer to apply the changed settings.
(Get-Process explorer).Kill()
'@)
New-Item -Path HKCU:Software\Microsoft\Windows\CurrentVersion\RunOnce -Force `
    | New-ItemProperty -Name ConfigureDesktop -Value 'PowerShell -WindowStyle Hidden -File "%USERPROFILE%\ConfigureDesktop.ps1"' -PropertyType ExpandString `
    | Out-Null

# set default Explorer location to This PC.
Set-ItemProperty -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1

# display full path in the title bar.
New-Item -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState -Force `
    | New-ItemProperty -Name FullPath -Value 1 -PropertyType DWORD `
    | Out-Null

# install chocolatey.
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# install useful applications.
choco install -y 7zip
choco install -y notepad3

# install Firefox.
choco install -y firefox

# install Google Chrome.
choco install -y --ignore-checksums googlechrome

# set the default browser.
choco install -y SetDefaultBrowser
SetDefaultBrowser HKLM "Google Chrome"
