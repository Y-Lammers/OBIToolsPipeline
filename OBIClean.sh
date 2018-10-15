#!/bin/bash -l

#############################
#   	OBIclean	    #
#############################

# Usage: OBIuniq.sh [Demultiplexed Fastq File]
# will output the results in [input fastq File].uniq.fasta

# Note: please use full file paths for the input files

#SBATCH --job-name=OBIClean

# we ask for 1 task with 1 cores
#SBATCH --nodes=1
#SBATCH --ntask=1
#SBATCH --cpus-per-task=4

# run for five minutes
#              d-hh:mm:ss
#SBATCH --time=0-24:00:00

#SBATCH --partition normal

# this is a hard limit 
#SBATCH --mem=8000MB

# turn on all mail notification
## SBATCH --mail-type=ALL

# load modules
module load StdEnv
module load Python/2.7.13-foss-2017a
source /global/work/ylammers/OBI/bin/activate

# define and create a unique scratch directory
#SCRATCH_DIRECTORY=/global/work/ylammers/temp1

# Get input files
FASTA="$1"

# remove clusters with less then 2 reads
# or reads shorter than 10bp
/global/work/ylammers/OBI/bin/obigrep -l 10 -p 'count>=2' $FASTA > ${FASTA/.fasta/.c2.fasta}

# run obiclean and only keep the head sequences
# use a head - internal ratio of 0.05
/global/work/ylammers/OBI/bin/obiclean -s merged_sample -r 0.05 -H ${FASTA/.fasta/.c2.fasta} > ${FASTA/.fasta/.c2.cl.fasta}

# happy end
exit 0
