#!/bin/bash

NPB=/scratch/ammaliszewski/NPB/NPB3.4-MPI/bin
START=`date +"%d-%m-%Y.%Hh%Mm%Ss"`
LOGS=/scratch/ammaliszewski
OUTPUT=$LOGS/npb.$START.csv
PROJECT=$LOGS/experimental_project.csv
MACHINEFILE=/scratch/ammaliszewski/nodes


#Read the experimental project
echo $PROJECT
tail -n +2 $PROJECT |
	while IFS=, read -r name runnoinstdorder runno runnostdrp \
		kernels inputs Blocks
do
	#Clean the values
	export name=$(echo $name | sed "s/\"//g")
	export kernels=$(echo $kernels | sed "s/\"//g")
	export inputs=$(echo $inputs | sed "s/\"//g")

	# Define a single key
	KEY="$name-$kernels-$inputs"
	
	echo $KEY

	# Prepare the command for execution
	runline=""
	runline+="mpirun -np 64 "

	runline+=" -machinefile $MACHINEFILE "
	runline+="$NPB/$kernels$inputs "
	runline+="2>> $LOGS/nas.err"
	runline+=" &> >(tee -a $LOGS/backup/$kernels${inputs:0:1}.log > $LOGS/nas.out)"
	
	
	# 3.3 Executes the experiments
	echo "Running >> $runline <<"
	eval "$runline < /dev/null"
	
	#cp $LOGS/nas.time $LOGS/nas.backup

	TIME=`grep -i "Time in seconds" $LOGS/nas.out | awk {'print $5'}`
	echo "${kernels:0:2},${inputs:0:1},$TIME" >> $OUTPUT
	echo "Done!"
done
exit
