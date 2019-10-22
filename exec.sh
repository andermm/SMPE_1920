#!/bin/bash

NPB=$SCRATCH/NPB/NPB3.4-MPI/bin
START=`date +"%d-%m-%Y.%Hh%Mm%Ss"`
OUTPUT=$SCRATCH/npb.$START.csv

echo output file: $OUTPUT

echo "env,app,class,interface,metric,value" > $OUTPUT

cd $NPB

ints=(eth)
IPs=(192.168.30.0)

for step in `seq 1 30`; do
	echo "step: $step"	
	for app in *.x; do
		printf "\t app: $app \n"
		for i in ${!ints[*]}; do
			int=${ints[$i]}
			IP=${IPs[$i]}
			printf "\t\t interface: - $int ($IP) \n"
			mpirun \
				--mca btl tcp,self \
				--mca oob_tcp_if_include $IP/24 \
				--mca btl_tcp_if_include $IP/24 \
				--mca btl_base_warn_component_unused 0 \
				-np 64 \
				-machinefile $SCRATCH/nodes \
				$app 2> /tmp/nas.err 1> /tmp/nas.time
			TIME=`grep -i "Time in seconds" /tmp/nas.time | awk {'print $5'}`
			echo "native,${app:0:2},${app:3:1},$int,time,$TIME" >> $OUTPUT
		done
	done
done

echo "done"

