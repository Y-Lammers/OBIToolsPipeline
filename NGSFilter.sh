#!/bin/bash -l

#############################
#   NGSFilter		    #
#############################

# Usage: NGSFilter.sh [Tag file] [Merged Fastq File]
# will output the results in [Merged Fastq File].ali.fastq

# Note: please use full file paths for the input files

#SBATCH --job-name=NGSFilter

# we ask for 1 task with 1 cores
#SBATCH --nodes=1
#SBATCH --ntask=1
#SBATCH --cpus-per-task=4

# run for five minutes
#              d-hh:mm:ss
#SBATCH --time=0-12:00:00

#SBATCH --partition normal

# this is a hard limit 
#SBATCH --mem=2000MB

# turn on all mail notification
## SBATCH --mail-type=ALL

# load modules
module load StdEnv
module load Python/2.7.13-foss-2017a
source /global/work/ylammers/OBI/bin/activate

# define and create a unique scratch directory
#SCRATCH_DIRECTORY=/global/work/ylammers/temp1

# Get input files
TagFile="$1"
FASTQ="$2"

# start the NGSfilter tool
/global/work/ylammers/OBI/bin/ngsfilter -e 1 -t $TagFile $FASTQ > ${FASTQ/.fastq/.ali.fastq}

# remove missmatched forward and reverse tags
obigrep -p 'forward_tag==reverse_tag' ${FASTQ/.fastq/.ali.fastq} > ${FASTQ/.fastq/.ali.frm.fastq}

# happy end
exit 0
