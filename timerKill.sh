#!/bin/bash
 
 ./timer.sh 10 > timer.log & export Pid=$!
 running=1
 echo $Pid
 #while that process is running
 while [ $running -eq 1 ]; do
     if ps -p $Pid > /dev/null
     then
	 echo -ne '\rrunning'
     else
	 echo -ne '\rfinnished\n'
	 let running=0
     fi
 done
