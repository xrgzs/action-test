$ErrorActionPreference = 'Stop'

Remove-Item -Path ".\temp\" -Recurse -ErrorAction Ignore
New-Item -Path ".\bin\" -ItemType "directory" -ErrorAction Ignore
New-Item -Path ".\temp\" -ItemType "directory" -ErrorAction Ignore

# Installing dependencies
if (-not (Test-Path -Path ".\bin\rclone.conf")) {
    Write-Error "rclone conf not found"
}

if (-not (Test-Path -Path ".\bin\aria2c.exe")) {
    Write-Host "aria2c not found, downloading..."
    Invoke-WebRequest -Uri 'https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip' -outfile .\temp\aria2.zip
    Expand-Archive -Path .\temp\aria2.zip -DestinationPath .\temp -Force
    Move-Item -Path .\temp\aria2-1.37.0-win-64bit-build1\aria2c.exe -Destination .\bin\aria2c.exe -Force
}


if (-not (Test-Path -Path ".\bin\wimlib\wimlib-imagex.exe")) {
    Write-Host "wimlib-imagex not found, downloading..."
    Invoke-WebRequest -Uri 'https://wimlib.net/downloads/wimlib-1.14.4-windows-x86_64-bin.zip' -outfile .\temp\wimlib.zip
    Expand-Archive -Path .\temp\wimlib.zip -DestinationPath .\bin\wimlib -Force
}

if (-not (Test-Path -Path ".\bin\wimlib\rclone.exe")) {
    Write-Host "rclone not found, downloading..."
    Invoke-WebRequest -Uri 'https://downloads.rclone.org/rclone-current-windows-amd64.zip' -outfile .\temp\rclone.zip
    Expand-Archive -Path .\temp\rclone.zip -DestinationPath .\temp\ -Force
    Copy-Item -Path .\temp\rclone-*-windows-amd64\rclone.exe -Destination .\bin\rclone.exe
}

# set server info
$server = "https://alist.xrgzs.top"
$path = "/潇然工作室/System/Win10"

# invoke alist api
$obj1 = Invoke-WebRequest -Uri "$server/api/fs/list" `
-Method "POST" `
-ContentType "application/json;charset=UTF-8" `
-Body (@{
    path = $path
    page = 1
    password = ""
    per_page = 0
    refresh = $false
} | Convertto-Json) | ConvertFrom-Json

# get original system
$obj2 = Invoke-WebRequest -UseBasicParsing -Uri "$server/api/fs/get" `
-Method "POST" `
-ContentType "application/json;charset=UTF-8" `
-Body (@{
    path = $path+'/'+($obj1.data.content | Where-Object -Property Name -Like 'msupdate*.wim').name
    password = ""
} | Convertto-Json) | ConvertFrom-Json

$osurl = $obj2.data.raw_url
$osfile = $obj2.data.name

Remove-Item -Path $osfile -Force -ErrorAction Ignore
.\bin\aria2c.exe --check-certificate=false -s16 -x16 -o "$osfile" "$osurl"
if ($?) {Write-Host "System Image Download Success!"} else {Write-Error "System Image Download Failed!"}

# $osfileext = [System.IO.Path]::GetExtension("$osfile")
$osfilename = [System.IO.Path]::GetFileNameWithoutExtension("$osfile")

# .\bin\wimlib\wimlib-imagex.exe export "$osfile" 9 "$osfilename.esd" --solid
# if ($?) { Write-Host "Convert Success!"} else {Write-Error "Convert Failed!"}

# make xrsys image
# mount image
New-Item -Path ".\mount\" -ItemType "directory" -ErrorAction Ignore
Write-Host "Mounting $osfilename.wim, please wait..."
Mount-WindowsImage -ImagePath "$osfilename.wim" -Index 4 -Path "mount"
# inject deploy
Expand-Archive -Path ".\injectdeploy.zip" -DestinationPath ".\mount" -Force
.\bin\aria2c.exe --check-certificate=false -s4 -x4 -d .\mount -o osc.exe "$server/d/pxy/Xiaoran%20Studio/Onekey/Config/osc.exe"
if ($?) {Write-Host "XRSYS-OSC Download Success!"} else {Write-Error "XRSYS-OSC Download Failed!"}
Copy-Item -Path ".\injectdeploy.bat" -Destination ".\mount" -Force
.\mount\injectdeploy.bat /S
if ($?) {Write-Host "Inject Deploy Success!"} else {Write-Error "Inject Deploy Failed!"}
Remove-Item -Path ".\mount\injectdeploy.bat" -ErrorAction Ignore

# add drivers
.\bin\aria2c.exe --check-certificate=false -s16 -x16 -d .\temp -o drivers.iso "$server/d/pxy/System/Driver/DrvCeo_Mod/Drvceo_Win10_Win11_x64_Lite.iso"
if ($?) {Write-Host "Driver Download Success!"} else {Write-Error "Driver Download Failed!"}
$isomount = (Mount-DiskImage -ImagePath ".\temp\drivers.iso" -PassThru | Get-Volume).DriveLetter
Copy-Item -Path "${isomount}:\" -Destination ".\mount\Windows\WinDrive" -Recurse -Force -ErrorAction Ignore
Dismount-DiskImage -ImagePath ".\temp\drivers.iso"
Remove-Item -Path ".\temp\drivers.iso" -ErrorAction Ignore

# add software pack
.\bin\aria2c.exe --check-certificate=false -s16 -x16 -d .\temp -o pack.7z "$server/d/pxy/Xiaoran%20Studio/Onekey/Config/pack64.7z"
."C:\Program Files\7-Zip\7z.exe" x -r -y -p123 ".\temp\pack.7z" -o".\mount\Windows\Setup\Set\osc"
if ($?) {Write-Host "software pack Download Success!"} else {Write-Error "software pack Download Failed!"}
Remove-Item -Path ".\temp\pack.7z" -ErrorAction Ignore

# add software pack
.\bin\aria2c.exe --check-certificate=false -s16 -x16 -d .\temp -o pack.7z "$server/d/pxy/Xiaoran%20Studio/Onekey/Config/pack64.7z"
."C:\Program Files\7-Zip\7z.exe" x -r -y -p123 ".\temp\pack.7z" -o".\mount\Windows\Setup\Set\osc"
if ($?) {Write-Host "software pack Download Success!"} else {Write-Error "software pack Download Failed!"}
Remove-Item -Path ".\temp\pack.7z" -ErrorAction Ignore
Remove-Item -Path ".\mount\Windows\Setup\Set\osc\搜狗拼音输入法.exe" -ErrorAction Ignore


# remove preinstalled appx
$preinstalled = Get-AppxProvisionedPackage -Path ".\mount"
foreach ($appName in @(
    'clipchamp.clipchamp',
    'Microsoft.549981C3F5F10',
    'microsoft.microsoftteams',
    'microsoft.skypeapp',
    'microsoft.todos',
    'microsoft.bingnews',
    'microsoft.gethelp',
    'microsoft.getstarted',
    'microsoft.microsoft3dviewer',
    'microsoft.microsoftofficehub',
    'microsoft.microsoftsolitairecollection',
    'microsoft.microsoftstickynotes',
    'microsoft.mixedreality.portal',
    'microsoft.mspaint',
    'microsoft.office.onenote',
    'microsoft.people',
    'microsoft.powerautomatedesktop',
    'microsoft.windowsfeedbackhub',
    'microsoft.windowsmaps',
    'microsoft.yourphone',
    'microsoft.zunemusic',
    'microsoft.zunevideo',
    'MicrosoftCorporationII.MicrosoftFamily',
    'MicrosoftTeams'
)) {
    $preinstalled | Where-Object {$_.packagename -like "*$appName*"} | Remove-AppxProvisionedPackage -Path ".\mount"
}

# Generate version
Set-TimeZone -Id "China Standard Time" -PassThru
$sysdate = Get-Date -Format "yyyy.MM.dd.Hm"
$sysver = "XRSYS_Win10_22H2_Pro_x64_CN_Full"
$sysvercn = "潇然系统_Win10_22H2_专业_x64_完整"
$sysfile = "${sysver}_${sysdate}"

# capture system image
Write-Host "Packing $sysfile.wim, please wait..."
New-WindowsImage -ImagePath ".\$sysfile.wim" -CapturePath ".\mount" -Name "$sysver"

# clean up mount dir
# Dismount-DiskImage -Path ".\mount" -Discard

# Get file information
$sysfilesize = [Math]::Round((Get-ItemProperty ".\$sysfile.wim").Length / 1024 /1024 /1024, 2)
$sysfilemd5 = Get-FileHash ".\$sysfile.wim" -Algorithm MD5 | Select-Object -ExpandProperty Hash
$sysfilesha256 = Get-FileHash ".\$sysfile.wim" -Algorithm SHA256 | Select-Object -ExpandProperty Hash

"[${sysvercn}_每夜版]
describe=${sysver}
Time=${sysdate}
OSUrl=${server}/d/pxy/Xiaoran%20Studio/System/Nightly/${sysfile}.wim
OSFile=${sysfile}.wim
UEFI=1
Bit=${sysfilesize}
md5=${sysfilemd5}
" | Out-File -FilePath ".\${sysfile}.OsList.ini" -Encoding gbk

"文件名称：${sysfile}.wim
文件大小：${sysfilesize}
MD5     ：${sysfilemd5}
SHA256  ：${sysfilesha256}
" | Out-File -FilePath ".\${sysfile}.txt" -Encoding utf8

# Publish image
.\bin\rclone.exe copy "$sysfile.wim" "odb:/Share/Xiaoran Studio/System/Nightly" --progress
.\bin\rclone.exe copy "$sysfile.ini" "odb:/Share/Xiaoran Studio/System/Nightly" --progress
.\bin\rclone.exe copy "$sysfile.txt" "odb:/Share/Xiaoran Studio/System/Nightly" --progress
# .\bin\rclone.exe copy "$osfile" "r2:testaction" --progress
