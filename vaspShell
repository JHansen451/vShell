#!/bin/bash
ErrFilePath=errfile.out
Tolerance=0.05
I=0
Err=0
nBandErr=0
#record structure number from the POSCAR
structure_number=$( awk '/str #:/ { print $4 }' POSCAR )

    
    
#only try to converge 10 times, if its not converging move on to the next job
while [ $I -lt 10 ]; do 
    #run vasp in background & record wich process vasp is
    ./timer.sh 5 > timer.log & export vasp_pid=$!
    echo "------- Starting Vasp, PID: " $vasp_pid " -------"
    #mpiexec.hydra -n 8 vasp_gpu & export vasp_pid=$!    
    running=1
    echo "Iteration: " $I
    #while the vasp process is running
    while [ $running -gt 0 ]; do
	#update the running flag
	if ! ps -p $vasp_pid > /dev/null
	    then
	    let running=0
	    echo "vasp running status updated:" $running
	    else
	    echo "vasp running"
	fi


	#if its the first run check for nband and LAPAC errors
	if [ $I -eq 0 ]
	then 
            #LAPAC failing (can catch early)
                #some variant of the word fail in the last line or garbage during running
	        #let Err=1
                #kill process
	    #kill $vasp_pid

            #nband errors (can catch early)
                #awk for either of the warnings for nbands
	    let nBandErr=$( awk -v n=$nBandErr 'BEGIN { err = n } /TOO FEW BANDS!/ { err += 1 } /The number of bands is not sufficient to hold all electrons./ { err += 1 } END { print err }' NBAND_TEST )
	    if [ $nBandErr -gt 0 ]
	    #if errors exist then:             
	    then 
		#kill the current vasp run
		echo "nband errors found"
		echo "killing vasp"
		kill $vasp_pid
		let running=0
		echo "vasp running status updated: " $running
		let Err=1
		#solve the error
		    #if the nband parameter isn't in the INCAR add it (with some default value: n=90 -> n=<yourvalue> )
			#set nbands = 90
	            #else:
                        #solution is to edit INCAR by uping the number of nbands (nbands += 30)
		        #set nbands = nbands+30
		awk -v n=90 'BEGIN { nbands = -1 } /NBANDS/ { nbands = $3 + 30; $3 = nbands } END {if (nbands < 0) print "\nNBANDS = ", n}1' INCAR > INCAR.temp
		echo "updating INCAR file, nBandERR: " $nBandErr
		mv INCAR.temp INCAR
	    fi	    
	fi

    done
    
    #if changing nbands isnt helping then end run
    if [ $nBandErr -gt 2 ]
    then
	echo "Insurmountable Nband errors encountered. str # " $structure_number >> $ErrFilePath
	exit 1
    fi
    
    #incriment iterations if no runtime error encountered
    if [ $Err -eq 0 ]
    then
	let I=I+1
    else
	#else reset the error flag without incrimenting iterations
	let Err=0
    fi
    

    #check for common errors in the output files
       
       
    #geometry errors (wait for output)
        #dont incriment I
        #rm unwanted outfiles
        
        #OSZICAR doesnt end with ionic step
        
        #OSZICAR too big of dE with only one ionic step (1 F & de is huge)

        #took way to many ionic steps (This wont be used if we limit the number of ionic steps)

    #check for convergence
    dE=$(awk '/d E/ { printf "%.8f\n", (substr($8,2)^2)^(1/2); }' OSZICAR | tail -n 1)
    if [ $(echo " $dE>$Tolerance" |bc) -eq 1 ]
    then
	#if not converged update input files
	mv CONTCAR POSCAR
    else
	#is converged and no common errors then exit
	echo Vasp converged in $I iteration\(s\) with dE = $dE
	#exit 1
    fi
done
echo "Vasp failed to converge. str # " $structure_number >> $ErrFilePath