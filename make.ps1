$ErrorActionPreference = 'Stop'

Remove-Item -Path ".\temp\" -Recurse -ErrorAction Ignore
New-Item -Path ".\bin\" -ItemType "directory" -ErrorAction Ignore
New-Item -Path ".\temp\" -ItemType "directory" -ErrorAction Ignore

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

$server = "https://alist.xrgzs.top"
$path = "/潇然工作室/System/Win10"

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
if ($?) {Write-Host "Download Success!"} else {Write-Error "Download Failed!"}

# $osfileext = [System.IO.Path]::GetExtension("$osfile")
$osfilename = [System.IO.Path]::GetFileNameWithoutExtension("$osfile")

# .\bin\wimlib\wimlib-imagex.exe export "$osfile" 9 "$osfilename.esd" --solid
# if ($?) { Write-Host "Convert Success!"} else {Write-Error "Convert Failed!"}

.\bin\rclone.exe copy "$osfile" "odb:/Share/Xiaoran Studio/System/Nightly" --progress -–buffer-size=200M
