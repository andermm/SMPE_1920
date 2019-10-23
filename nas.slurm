#!/bin/bash
#SBATCH --job-name=exp
#SBATCH --time=72:00:00
#SBATCH --nodes=4
#SBATCH --tasks-per-node=32
#SBATCH --ntasks=128
#SBATCH --partition=hype
#SBATCH --exclusive
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.er

echo "Running on $SLURM_JOB_NODELIST"

## Diretório de base
export BASE=/scratch/ammaliszewski

# Ingressar no diretório de base
cd $BASE


PROGRAMA=$BASE/NPB/NPB3.4-MPI/bin
PROGRAMA_CONFIG=$BASE/NPB/NPB3.3-MPI/config
PROGRAMA_COMPILE=$BASE/NPB/NPB3.3-MPI
START=`date +"%d-%m-%Y.%Hh%Mm%Ss"`
LOGS=$BASE/$SLURM_JOB_NAME
OUTPUT=$LOGS/npb.$START.csv
GIT=$BASE/SMPE_1920
PROJECT=$GIT/experimental_project.csv

#Clone Git
cd $BASE; git clone https://github.com/andermm/SMPE_1920.git;

#Baixar, configurar e compilar o NPB.
wget https://www.nas.nasa.gov/assets/npb/NPB3.4.tar.gz
tar -zxvf NPB3.4.tar.gz
rename "s/\.def.template$/.def/" $PROGRAMA_CONFIG/*.template
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
mkdir -p $SLURM_JOB_NAME
mkdir -p $SLURM_JOB_NAME/backup

# Define o Machine File necessário para MPI
MACHINEFILE=$LOGS/$SLURM_JOB_NAME/nodes
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