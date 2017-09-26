:: System Information Batch File (Incident Response Version)
:: Use this to get a system state snapshot baseline, or to enumerate a potentially compromised system

:: Set FOLDER variable to contain output files
FOR /F "TOKENS=1* EOL=/ DELIMS= " %%A IN ('DATE.EXE/t') DO SET STARTDATE=%%A
FOR /F "TOKENS=1,2 EOL=/ DELIMS=/" %%A IN ('DATE.EXE/t') DO SET MM=%%B
FOR /F "TOKENS=1,2 EOL=/ DELIMS=/" %%A IN ('echo %STARTDATE%') DO SET DD=%%B
FOR /F "TOKENS=2,3 EOL=/ DELIMS=/" %%A IN ('echo %STARTDATE%') DO SET YYYY=%%B
FOR /F "TOKENS=1,2 EOL=/ DELIMS=:" %%A IN ('TIME.EXE/t') DO SET HH=%%A
FOR /F "TOKENS=1,2 EOL=/ DELIMS=:" %%A IN ('TIME.EXE/t') DO SET MIN=%%B

SET FOLDER=%COMPUTERNAME%-%YYYY%-%MM%-%DD%-%HH%-%MIN%

:: Create folder in current working directory
mkdir %FOLDER%
cd %FOLDER%

:: Create README file
ECHO SYSTEM SNAPSHOT>README.TXT
ECHO Computer: %COMPUTERNAME%>>README.TXT
ECHO Date: %DATE%>>README.TXT
ECHO Batchfile: %CD%\%0>>README.TXT  
ECHO Username: %USERNAME%@%USERDOMAIN%>>README.TXT

:: Dump ARP cache
arp.exe -a > arp.txt

:: Dump DNS cache
ipconfig.exe /displaydns > dns.txt

:: Copy event logs
:: Application, Security, Sysmon, System, UAC, Task Scheduler
copy "%SystemRoot%\System32\Winevt\Logs\Security.evtx" .
copy "%SystemRoot%\System32\Winevt\Logs\Application.evtx" .
copy "%SystemRoot%\System32\Winevt\Logs\System.evtx" .
copy "%SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-Sysmon%4Operational.evtx" .
copy "%SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-TaskScheduler%4Operational.evtx" .
copy "%SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-UAC%4Operational.evtx" .

:: Copy Windows Firewall logs
copy %systemroot%\system32\LogFiles\Firewall\pfirewall.log .

:: Computer System
wmic.exe computersystem list full>Computer-Info.txt

:: List Installed Roles & Features
dism /online /get-features /format:table > Installed-Features.txt

:: List Installed Packages
dism /online /get-packages /format:table > Installed-Packages.txt

:: BIOS
wmic.exe bios list full>BIOS.txt

:: Environment Variables
set>Environment-Variables.txt

:: Users
wmic.exe useraccount list full>Users.txt

:: Groups
wmic.exe path win32_group get /value>Groups.txt

:: Group Members
wmic.exe path win32_groupuser get /value>Group-Members.txt

:: Password and Lockout Policies
net.exe accounts>Password-And-Lockout-Policies.txt

:: Local Audit Policy
auditpol.exe /get /category:*>Audit-Policy.txt

:: SECEDIT Security Policy Export
secedit.exe /export /cfg SecEdit-Security-Policy.txt 1>nul 2>nul

:: Shared Folders
wmic.exe share list full>Shared-Folders.txt

:: Networking Configuration
ipconfig.exe /all > Network-Config.txt
netstat.exe -anob > Network-Netstat.txt
route.exe print > Network-Route.txt
nbtstat.exe -n > Network-NbtStat.txt
netsh.exe winsock show catalog>Network-Winsock.txt
wmic.exe path win32_networkadapterconfiguration get /value>Network-NIC.txt

:: Windows Firewall and IPSec Connection Rules
netsh.exe firewall show config verbose=enable>Network-Firewall.txt
netsh.exe advfirewall show allprofiles>Network-Firewall-Profiles.txt
netsh.exe advfirewall show global>Network-Firewall-Global-Settings.txt
netsh.exe advfirewall firewall show rule name=all>Firewall-Network-Rules.txt
netsh.exe advfirewall export "Network-Firewall-Export.wfw" 1>nul 2>nul
netsh.exe advfirewall consec show rule name=all>Network_Firewall-IPSec-Rules.txt

:: Processes
wmic.exe process list full>Processes.txt
tasklist.exe > tasklist.txt
tasklist.exe /M > tasklist-modules.txt
tasklist.exe /SVC > tasklist-services.txt

:: Drivers
wmic.exe sysdriver list full>Drivers.txt

:: Services
wmic.exe service list full>Services.txt

:: Autoruns (requires Sysinternals autorunsc.exe)
..\autorunsc.exe -accepteula > autoruns_lite.txt
..\autorunsc.exe -accepteula /a * * > autoruns_full.exe

:: MSINFO32.EXE Report
start /wait msinfo32.exe /report MSINFO32-Report.txt


