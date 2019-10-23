#!/bin/bash
#SBATCH --job-name=exp
#SBATCH --time=72:00:00
#SBATCH --nodes=4
#SBATCH --tasks-per-node=32
#SBATCH --ntasks=128
#SBATCH --partition=hype
#SBATCH --exclusive
#SBATCH --output=$LOGS_DIR/$SLURM_JOB_NAME.out
#SBATCH --error=$LOGS_DIR/$SLURM_JOB_NAME.err

echo "Running on $SLURM_JOB_NODELIST"

## Diretório de base
BASE=/scratch/ammaliszewski

PROGRAMA=$BASE/NPB3.4/NPB3.4-MPI/bin
PROGRAMA_CONFIG=$BASE/NPB3.4/NPB3.4-MPI/config
PROGRAMA_COMPILE=$BASE/NPB3.4/NPB3.4-MPI
START=`date +"%d-%m-%Y.%Hh%Mm%Ss"`

LOGS_DIR=$HOME/SMPE_1920/$SLURM_JOB_NAME
OUTPUT=$HOME/SMPE_1920/$SLURM_JOB_NAME/npb.$START.csv
PROJECT=$HOME/SMPE_1920/projeto-experimental.csv

# Ingressar no diretório de base
cd $BASE

#Baixar, configurar e compilar o NPB.
wget https://www.nas.nasa.gov/assets/npb/NPB3.4.tar.gz
tar -zxvf NPB3.4.tar.gz

for f in $PROGRAMA_CONFIG/*.def.template; do
	mv -- "$f" "${f%.def.template}.def"; 
done

sed -i 's,mpif90,mpifort,g' $PROGRAMA_CONFIG/make.def

kernel=(is ep cg mg ft)
classes=(C D)
echo -n "" > $PROGRAMA_CONFIG/suite.def

#Insere o kernel+classe no arquivo suite.def
for (( n = 0; n < 5; n++ )); do
	for (( i = 0; i < 2; i++ )); do
		echo -e ${kernel[n]}"\t"${classes[i]} >> $PROGRAMA_CONFIG/suite.def
	done
done

#Instala as dependencias
nome=(gfortran libopenmpi-dev)
for (( n = 0; n < 2; n++ )); do
	packets=$(dpkg --get-selections | grep ${nome[n]})
	if [ -n "$packets" ];
		then
			echo All necessary packets are installed!
		else
			sudo apt install ${nome[n]} -y
	fi
done

#Compilar
cd $PROGRAMA_COMPILE; make suite; cd $BASE

# Criar um diretório para conter todos os resultados
mkdir -p $LOGS_DIR/$SLURM_JOB_NAME
mkdir -p $LOGS_DIR/$SLURM_JOB_NAME/backup

# Define o Machine File necessário para MPI
MACHINEFILE=$LOGS_DIR/$SLURM_JOB_NAME/nodes
srun $SRUN_PACK /bin/hostname | sort -n | awk "{print $2}" > $MACHINEFILE


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
	runline+="mpirun -np 128 "

	runline+=" -machinefile $MACHINEFILE "
	runline+="$PROGRAMA/$kernels$inputs "
	runline+="2>> $LOGS_DIR/nas.err"
	runline+=" &> >(tee -a $LOGS_DIR/backup/$kernels${inputs:0:1}.log > $LOGS_DIR/nas.out)"
	
	
	# 3.3 Executes the experiments
	echo "Running >> $runline <<"
	eval "$runline < /dev/null"

	TIME=`grep -i "Time in seconds" $LOGS_DIR/nas.out | awk {'print $5'}`
	echo "${kernels:0:2},${inputs:0:1},$TIME" >> $OUTPUT
	echo "Done!"
done
exit