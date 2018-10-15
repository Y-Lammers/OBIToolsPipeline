#!/bin/bash -l

#############################
#   	OBIuniq		    #
#############################

# Usage: OBIuniq.sh [Demultiplexed Fastq File]
# will output the results in [input fastq File].uniq.fasta

# Note: please use full file paths for the input files

#SBATCH --job-name=OBIuniq

# we ask for 1 task with 1 cores
#SBATCH --nodes=1
#SBATCH --ntask=1
#SBATCH --cpus-per-task=4

# run for five minutes
#              d-hh:mm:ss
#SBATCH --time=0-12:00:00

#SBATCH --partition normal

# this is a hard limit 
#SBATCH --mem=4000MB

# turn on all mail notification
## SBATCH --mail-type=ALL

# load modules
module load StdEnv
module load Python/2.7.13-foss-2017a
source /global/work/ylammers/OBI/bin/activate

# define and create a unique scratch directory
#SCRATCH_DIRECTORY=/global/work/ylammers/temp1

# Get input files
FASTQ="$1"

# start the NGSfilter tool
/global/work/ylammers/OBI/bin/obiuniq -m sample $FASTQ > ${FASTQ/.fastq/.temp.fasta}

/global/work/ylammers/OBI/bin/obiannotate -k count -k merged_sample ${FASTQ/.fastq/.temp.fasta} > ${FASTQ/.fastq/.uniq.fasta}
rm ${FASTQ/.fastq/.temp.fasta}

# happy end
exit 0
