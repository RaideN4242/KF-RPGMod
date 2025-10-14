@echo off

:: batch title and logs

title= Dead Zone RPG Mod
set "_runStat="
set _servBat=KFserver
set _servLog=.\logs\%_servBat%.bat.log
set _gameLog=.\logs\%_servBat%.log

:: server command line

set _gameCmd=ucc server KF-westlondon.rom?game=IDRPGMod.ID_RPG_Base_GameType?VACSecured=true?MaxPlayers=12?AdminName=Admin?AdminPassword=XXX?Mutator=IDRPGMod.MutLoader -nolog
set _gameCmd=%_gameCmd% -log=%_gameLog%

echo ::
echo :: This batch will autorun %_servBat%.
echo :: -to restart %_servBat%, end the ucc server task.
echo :: -to shut down %_servBat%, ctrl-c or close this window.
echo ::

if exist ucc.exe (echo :: %_servBat% initializing...) else (echo :: ucc server not found! & echo :: This batch is to be run in the KF system directory. & goto:eof) 

:: log server start/create batch log

echo ::
echo :: Output logged to %_servLog%
if exist %_servLog% (echo ::%_servBat% Start:: >>%_servLog%) else (md logs & echo ::%_servBat% Start:: >%_servLog%)
echo %_gameCmd% >>%_servLog%

:: start/restart server

:start

:: backup last server log

echo ::
echo :: Backup %_gameLog:.\logs\=%...
set _logTime=%_servBat%-%DATE:/=-%_%TIME:~0,2%.%TIME:~3,2%.log
set _logTime=%_logTime: =0%
if exist %_gameLog% (ren %_gameLog% %_logTime% & echo :: %_logTime% & echo :: Backup complete.) else (echo :: No log to backup.)
echo ::

:: log batch restart

if defined _runStat (echo :: Restart %_servBat%)
echo :: %date%
echo :: %time: =0%
echo ::
if defined _runStat (echo :Restart %_servBat%: >>%_servLog%)
if exist .\logs\%_logTime% (echo %_logTime% >>%_servLog%) else (echo No log to backup. >>%_servLog%)
echo %date% >>%_servLog%
echo %time: =0% >>%_servLog%
set "_logTime="

:: run the server

call %_gameCmd%
set _runStat=1

:: restart on exit/error

timeout 60

goto start
::


