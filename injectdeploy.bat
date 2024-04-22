chcp 65001
@echo off
setlocal enabledelayedexpansion
color a
title 潇然系统部署手动接管程序 - V2024.4.21
cd /d "%~dp0"
set silent=0
if /i "%1"=="/S" set silent=1
if exist "osc.exe" move /y "osc.exe" "Windows\Setup\Set\osc.exe"
if not exist "Windows\System32\config\SYSTEM" call :error "找不到系统注册表文件"
if not exist "Windows\Panther\unattend.xml" call :error "找不到unattend.xml文件"
@rem if not exist "Windows\Setup\Set\api.exe" call :error "找不到api.exe文件"
if not exist "Windows\Setup\Set\osc.exe" call :error "找不到osc.exe文件"
find /i "IMAGE_STATE_COMPLETE" "Windows\Setup\State\State.ini" && call :error "不支持接管已经部署/未封装的映像"
goto main

:main
cls
echo.
echo 提示：即将接管系统部署，注入系统部署
echo.
echo 注意：1. 仅支持接管Win8.1x64、Win10x64、Win11x64系统；
echo 　　　2. 您的执行环境如果不带choice.exe，将无法完成后续配置
echo.
echo 信息：
set specialmode=0
if exist "Windows\Es4.Deploy.exe" set specialmode=1&echo 　　　该映像使用了IT天空ES4封装
if exist "Sysprep\ES5\EsDeploy.exe" set specialmode=1&echo 　　　该映像使用了IT天空ES5封装
if exist "Sysprep\ES5S\ES5S.exe" set specialmode=1&echo 　　　该映像使用了IT天空ES5S封装
if exist "Windows\ScData\ScData.sc" set specialmode=1&echo 　　　该映像使用了系统总裁SCPT3.0封装
echo.
echo 警告：此操作不可逆，请三思而后行！
echo.
if %silent% NEQ 0 pause
goto inject

:inject
if not exist "Windows\Panther\unattend2.xml" copy /y "Windows\Panther\unattend.xml" "Windows\Panther\unattend2.xml"
REG LOAD "HKLM\Mount_SYSTEM" "Windows\System32\config\SYSTEM"
REG ADD "HKLM\Mount_SYSTEM\Setup" /f /v "CmdLine" /t REG_SZ /d "deploy.exe" 
REG UNLOAD "HKLM\Mount_SYSTEM"
if %specialmode% equ 1 (
    >"Windows\Setup\xrsys.txt" echo isxrsys
)
if %silent% NEQ 0 (
    if /i "%systemdrive%"=="x:" if not exist "%windir%\System32\choice.exe" (
    copy /y "Windows\System32\choice.exe" "%windir%\System32\choice.exe"
    copy /y "Windows\System32\zh-CN\choice.exe.mui" "%windir%\System32\zh-CN\choice.exe.mui"
    )
    choice /? || goto :success
)
goto :success

:ask
cls
echo.
echo # 是否设置为纯净模式？
choice
if %errorlevel% equ 1 (
    del /f /q "Windows\Setup\zjsoftforce.txt" >nul 2>nul
    >"Windows\Setup\zjsoftonlinexrsys.txt" echo 1
)

echo.
echo # 是否设置为Administrator账户登录？（不推荐）
choice
if %errorlevel% equ 1 (
    >"Windows\Setup\xrsysadmin.txt" echo 1
) else (   
    del /f /q "Windows\Setup\xrsysadmin.txt" >nul 2>nul
    echo.
    echo ## 是否设置新建账户的用户名？（默认会自动检测）
    choice
    if !errorlevel! equ 1 (
        echo.
        set /p username=### 请输入用户名：
        >"Windows\Setup\xrsysnewuser.txt" echo !username!
    )
)
goto success

:success
cls
echo.
echo 恭喜您，系统接管成功，
echo 　　尽情享受潇洒、自然的装机体验吧！
echo.
if %silent% NEQ 0 (
    pause
    del %0
)
exit 0

:error
echo.
echo 错误：%~1
echo.
echo 接管错误, 请检查文件是否释放正确！！！
echo.
if %silent% NEQ 0 pause
exit 1