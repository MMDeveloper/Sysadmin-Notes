@echo off
REM Call the bat-file with the group-name as parameter, the result will be saved as *groupname*.txt

set group=%1

dsquery group domainroot -name %1 | dsget group -members | dsget user -samid > %1.txt
