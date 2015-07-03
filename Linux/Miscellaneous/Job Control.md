#Background processes and interacting with them again#

It's common knowledge you can background a process by adding a ' &' to the end of a command, such as:
```
dd if=/dev/zero of=/dev/sdb bs=1M &
```

However most people don't know that you can actually bring that process back to your shell. You can do this with a combination of the following commands: jobs, fg, bg.

Let's take for example, the following commands
```
/usr/bin/some_long_running_command &
>[1] 5285
```
That says that your long running command is JobID of 1 and PID of 5285. Now we run the jobs command to see all background processes.
```
jobs
> [1]+ RUNNING /usr/bin/some_long_running_command
```

Now let's say you want to un-background that command and interact with it again.
```
fg %1
#where %1 is the job number from above, the second job would be %2
```

Viola, now it's as if you never backgrounded the process, but now what? What if I want to background it again? That's easy, just hit CTRL+Z. That will background the process, but PAUSE the job.
```
^Z
> [1]+  Stopped
```

Now we want to unpause the job so it continues running in the background
```
bg %1
> [1]+ /usr/bin/some_long_running_command
```

We can check that it is now running again
```
jobs
> [1]+ RUNNING /usr/bin/some_long_running_command
```

#Alternative way to background processes#
Please refer to the "Unattached Screens and Jobs" file in this same directory