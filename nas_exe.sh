#!/bin/bash

NPB=$HOME/CMP223_P4/NPB3.4-MPI/bin
START=`date +"%d-%m-%Y.%Hh%Mm%Ss"`
LOGS=$HOME/CMP223_P4/logs
OUTPUT=$LOGS/npb.$START.csv

echo output file: $OUTPUT

echo "env,app,class,metric,value" > $OUTPUT

cd $NPB

for step in `seq 1 30`; do
	echo "step: $step"	
	for app in *.x; do
		printf "\t app: $app \n"
			mpirun \
				-np 4 \
				-machinefile nas_nodes 
				$app 2> $LOGS/nas.err 1> $LOGS/nas.time
			TIME=`grep -i "Time in seconds" $LOGS/nas.time | awk {'print $5'}`
			echo "native,${app:0:2},${app:3:1},time,$TIME" >> $OUTPUT
		done
	done
echo "done"
