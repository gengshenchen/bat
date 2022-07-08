echo off

set sPath=.\src
set dPath=.\include

xcopy %sPath%\*.h %dPath%\  /s /e /c /y /h /r

pause