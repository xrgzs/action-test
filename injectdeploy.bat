@chcp 936 >nul
@echo off
setlocal enabledelayedexpansion
color a
title ��Ȼϵͳ�����ֶ����߽ӹܳ��� - V2024.5.1.0
cd /d "%~dp0"
set silent=0

@REM ��⾲Ĭ����
if /i "%1"=="/S" (
    set silent=1
    @echo on
)

@REM �����ļ���
for %%a in (
    Windows\Setup\Set\InDeploy
    Windows\Setup\Set\osc
    Windows\Setup\Set\Run
    Windows\Setup\Run\1
    Windows\Setup\Run\2
) do (
    mkdir "%%a" 2>nul
)

@REM �����ļ�
if exist "unattend.xml" move /y "unattend.xml" "Windows\Panther\unattend.xml"
if exist "osc.exe" move /y "osc.exe" "Windows\Setup\Set\osc.exe"

@REM �ж��ļ�������
if not exist "Windows\System32\config\SYSTEM" call :error "�Ҳ���ϵͳע����ļ�"
if not exist "Windows\Panther\unattend.xml" call :error "�Ҳ���unattend.xml�ļ�"
if not exist "Windows\Setup\Set\osc.exe" call :error "�Ҳ���osc.exe�ļ�"
find /i "IMAGE_STATE_COMPLETE" "Windows\Setup\State\State.ini" && call :error "��֧�ֽӹ��Ѿ�����/δ��װ��ӳ��"
goto main

:main
cls
echo.
echo ��ʾ�������ӹ�ϵͳ����ע��ϵͳ����
echo.
echo ע�⣺1. ��֧�ֽӹ�Win8.1x64��Win10x64��Win11x64ϵͳ��
echo ������2. ����ִ�л����������choice.exe�����޷���ɺ������ã�
echo ������3. ������PE������TrustedInstaller�û������д˽ű�
echo.
echo ��Ϣ��
if exist "Windows\Es4.Deploy.exe" echo ��������ӳ��ʹ����IT���ES4��װ
if exist "Sysprep\ES5\EsDeploy.exe" echo ��������ӳ��ʹ����IT���ES5��װ
if exist "Sysprep\ES5S\ES5S.exe" echo ��������ӳ��ʹ����IT���ES5S��װ
if exist "Windows\ScData\ScData.sc" echo ��������ӳ��ʹ����ϵͳ�ܲ�SCPT3.0��װ
echo.
echo ���棺�˲��������棬����˼�����У�
echo.
if %silent% EQU 0 pause
goto inject

:inject
if not exist "Windows\Panther\unattend2.xml" copy /y "Windows\Panther\unattend.xml" "Windows\Panther\unattend2.xml"

echo �޸�ϵͳע���
REG LOAD "HKLM\Mount_SYSTEM" "Windows\System32\config\SYSTEM"
echo �ӹ�ϵͳ����
REG ADD "HKLM\Mount_SYSTEM\Setup" /f /v "CmdLine" /t REG_SZ /d "deploy.exe" 
echo �ɷ�WD����
for %%a in (
MsSecFlt
Sense
WdBoot
WdFilter
WdNisDrv
WdNisSvc
WinDefend
SgrmAgent
SgrmBroker
webthreatdefsvc
webthreatdefsvc
) do REG ADD "HKLM\Mount_SYSTEM\ControlSet001\Services\%%a" /f /v "Start" /t REG_DWORD /d 4
echo ����ϵͳ���ü��
for %%a in (
BypassCPUCheck
BypassRAMCheck
BypassSecureBootCheck
BypassStorageCheck
BypassTPMCheck
) do REG ADD "HKLM\Mount_SYSTEM\\Setup\LabConfig"/f /v "%%a" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SYSTEM\\Setup\MoSetup"/f /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d 1
REG UNLOAD "HKLM\Mount_SYSTEM"

echo �޸����ע���
REG LOAD "HKLM\Mount_SOFTWARE" "Windows\System32\config\SOFTWARE"
echo �ɷ�WD�����
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender" /f /v "DisableAntiSpyware" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender" /f /v "DisableAntiVirus" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender" /f /v "AllowFastServiceStartup" /t REG_DWORD /d 0
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v "DisableIOAVProtection" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v "DisableOnAccessProtection" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1
echo �ɷ�WD����
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows Defender" /f /v "DisableAntiSpyware" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows Defender" /f /v "DisableAntiVirus" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows Defender\Features" /f /v "TamperProtection" /t REG_DWORD /d 4
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows Defender\Features" /f /v "TamperProtectionSource" /t REG_DWORD /d 2
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows Defender\Spynet" /f /v "SpyNetReporting" /t REG_DWORD /d 0
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows Defender\Spynet" /f /v "SubmitSamplesConsent" /t REG_DWORD /d 0
echo ���ñ����洢�Ŀռ�ռ��
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "MiscPolicyInfo" /t REG_DWORD /d "2" /f
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "PassedPolicy" /t REG_DWORD /d "0" /f
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t REG_DWORD /d "0" /f
echo ����OOBE
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t REG_DWORD /d "1" /f
REG UNLOAD "HKLM\Mount_SOFTWARE"



echo �޸�Ĭ���û�ע���
REG LOAD "HKLM\Mount_Default" "Users\Default\NTUSER.DAT"
echo ����ϵͳ���ü��
for %%a in (SV1,SV2) do REG ADD "HKLM\Mount_Default\Control Panel\UnsupportedHardwareNotificationCache" /f /v "%%a" /t REG_DWORD /d 0


echo ���Ρ�ͬ��������ݿ羳���䡱
REG ADD "HKLM\Mount_Default\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\PersonalDataExport" /f /v "PDEShown" /t REG_DWORD /d 2
echo ���� Windows ȫ�°�װ�����԰�װ���� App
for %%a in (
ContentDeliveryAllowed
DesktopSpotlightOemEnabled
FeatureManagementEnabled
OemPreInstalledAppsEnabled
PreInstalledAppsEnabled
PreInstalledAppsEverEnabled
RemediationRequired
SilentInstalledAppsEnabled
SlideshowEnabled
SoftLandingEnabled
SystemPaneSuggestionsEnabled
SubscribedContentEnabled
) do REG ADD "HKLM\Mount_Default\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "%%a" /t REG_DWORD /d "0" /f
echo ���� Windows �ڸ������õĽ�����ʾ
for %%a in (
310093Enabled
338388Enabled
338389Enabled
338393Enabled
353694Enabled
353696Enabled
) do REG ADD "HKLM\Mount_Default\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-%%a" /t REG_DWORD /d "0" /f
echo ������Ϸ�� Game Bar
REG ADD "HKLM\Mount_Default\SOFTWARE\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f

REG UNLOAD "HKLM\Mount_Default"
>"Windows\Setup\xrsys.txt" echo isxrsys
if %silent% EQU 0 (
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
echo # �Ƿ�����Ϊ����ģʽ��
choice
if %errorlevel% equ 1 (
    del /f /q "Windows\Setup\zjsoftforce.txt" >nul 2>nul
    >"Windows\Setup\zjsoftonlinexrsys.txt" echo 1
)

echo.
echo # �Ƿ�����ΪAdministrator�˻���¼�������Ƽ���
choice
if %errorlevel% equ 1 (
    >"Windows\Setup\xrsysadmin.txt" echo 1
) else (   
    del /f /q "Windows\Setup\xrsysadmin.txt" >nul 2>nul
    echo.
    echo ## �Ƿ������½��˻����û�������Ĭ�ϻ��Զ���⣩
    choice
    if !errorlevel! equ 1 (
        echo.
        set /p username=### �������û�����
        >"Windows\Setup\xrsysnewuser.txt" echo !username!
    )
)
goto :success

:success
cls
echo.
echo ��ϲ����ϵͳ�ӹܳɹ���
echo ��������������������Ȼ��װ������ɣ�
echo.
if %silent% EQU 0 (
    pause
    del %0
)
exit 0

:error
echo.
echo ����%~1
echo.
echo �ӹܴ���, �����ļ��Ƿ��ͷ���ȷ������
echo.
if %silent% EQU 0 pause
exit 1