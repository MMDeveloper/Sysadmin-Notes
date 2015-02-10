@echo off
REM Pings everything in a given range defined below.
set /a n=0
:repeat
set /a n+=1
echo 10.0.0.%n%
ping -n 1 -w 500 10.1.14.%n% | FIND /i "Reply">>ip-reply.txt
if %n% lss 254 goto repeat
type ip-reply.txt
