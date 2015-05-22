#Introduction#
I used to work in a Progress Database environment where a single Linux server would host several Progress databases. The vendor-provided shutdown script would dynamically determine what databases were running and cleanly shut them down, unfortunately one at a time. This took a very long time on some servers that would easily handle concurrent shutdowns.

I no longer work in a Progress environment so I cannot test this script, so its current state is THEORETICAL.

#How It Works#
The script would determine the running databases, building an array, and throw itself into a loop queueing X number of shutdowns at a time. The number of concurrent shutdowns would be configurable.

1. At runtime, the running databases are inventoried
2. The loop executes every 5 seconds
3. The number of running shutdowns are counted
4. If the number of running shutdowns is less than the max allowed then a database from the end of the array is chosen to shutdown and removed from the pending list
5. If the number of pending shutdowns is zero and the number of running shutdowns is zero, the script exits

#Current Known Issues#
* Unknown_0: I do not recall the code used to determine the running databases and convert that to a list of database paths. Essentially you need an array of /path/to/running/database/DBNAMEs
* Unknown_1: I do not recall the underlying process that runs when a database is being shut down. You'd need to watch a "ps aux | grep DBNAME" when one is shutting down so you'll know what to run to count the number of running shutdowns
* Unknown_2: I do not recall the full SHUTDOWN command.

#The Code#
```
#!/bin/bash

#how many concurrent shutdowns
concurrentShutdowns=3

#array of databases to shut down
######Unknown_0
toShutDown=()

#number of currently running shutdowns
runningShutdowns=0

#just a switch to indicate completion
scriptDone=false


while [ $scriptDone -eq false ]; do

    #number of running shutdowns
    ######Unknown_1
    runningShutdowns=$(ps aux | grep '/path/to/progress/bin/proshut' | wc -l)

    if [ ${#toShutDown[@]} -gt 0 ]; then
        if [ $runningShutdowns -lt $concurrentShutdowns ]; then
            #get db from end of array
            tmp=${#toShutDown[@]}
            tmp=$(($tmp - 1))

            #initiate a shutdown task and send it to the background
            ######Unknown_2
            /path/to/progress/bin/proshut -db ${toShutDown[$tmp]} &

            #remove this db from the list
            unset toShutDown[$tmp]
        else
            #we've hit the max concurrent shutdowns
        fi
    else
        if [ $runningShutdowns -lt 1 ]; then
            #no more dbs to shut down, no more shutdown processes running
            scriptDone=true
            exit 0
        else
            #no more databases to shut down, but there are still $runningShutdowns dbs shutting down
        fi
    fi

    #slow the looping down
    sleep 5
done
```
