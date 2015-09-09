#!/bin/bash

### This will check all processes you wish to monitor
### In the event one of them is 'down', it will trigger
### a failover to the next-in-line HAProxy server

killall -0 haproxy 2> /dev/null
if [ $? -eq 1 ]
then
    exit 1
fi



### Copy/Paste the above block of code for each
### process you want to monitor
### This script should always exit with a code of 0 or 1
### An exit code of 0 means all is good
### An exit code of 1 will trigger a failover


exit 0
