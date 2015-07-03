#Introduction#
Ever SSH'd into another server to run a really long-running command, but now you can't exit that console session or that command would die? Ever found a need or desire to run a command, start a new terminal to run another command, with the ability to go back to the first command to check on things? While background jobs can somewhat achieve this, unattached terminals are far superior at this job.

##TMUX##
Tmux is fast becoming my go-to utility for disconnected screens and jobs. It is a superior replacement to the `screen` command. Below are some common commands that I use for tmux, a real world scenario.

###Installation###
Tmux isn't installed by default for any distro I've used before. Installation is quick and painless
```
#debian flavors
sudo apt-get install tmux

#redhad flavors
yum install tmux
```

###Basic Usage###
I have a tiny VM that I use to run an IRC bot which consists of an always-running socket program and REDIS memory caching. Since the bot is new, I like to monitor both systems. With tmux, I can have a split-screen terminal in which I can monitor both.

So first I'll make an SSH connection to this VM
```
ssh 10.0.0.7
```

Now I'll make a new tmux session called 'ircbot'
```
tmux new -s ircbot
```

I personally like to have a vertically split screen, left side for the bot, right side for REDIS. For the purposes of the next commands, it is to be understood that `^` is a control character, so `^b` means to hit CTRL+b.
```
^b %
```

Now we have two side-by-side screens. You can resize the width of them by holding down `^b` and hitting your left/right arrow keys. So now we want to go to the screen on the left side to start the bot
```
^b <left-arrow-key>
/path/to/command/to/start/bot
```

Now I want to move to the right side of the split panel and run the redis-cli command
```
^b <right-arrow-key>
redis-cli
```

I can jump back and forth between the screens using the same `^b <arrow-keys>` sequence. You can split screens both horizontally and vertically and jump through them like this. Now, you can disconnect from the tmux session via a `^b d` command.

When you disconnect from the tmux session, you're back at a command prompt for the remote server as if you'd just logged in. Everything in the tmux sessions are still running, just in the background. You can even log out of this remote server and they'll still be running. If you reboot the remote machine however, they will not be running when it comes back up.

Now let's say I want to SSH back into the server at a later date to check up on things.
```
ssh 10.0.0.7
tmux list-sessions

#my session is called ircbot
tmux a -t ircbot
#now you're back
```