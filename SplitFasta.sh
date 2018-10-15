#!/bin/bash -l

#############################
#   	SplitFasta	    #
#############################

# Usage: SplitFasta.sh [cleaned FASTA file]
# Create a sub file for every 2500 sequences
# will output the results in [input fasta File].sub[num].fasta

# Note: please use full file paths for the input files

#SBATCH --job-name=SplitFasta

# we ask for 1 task with 1 cores
#SBATCH --nodes=1
#SBATCH --ntask=1
#SBATCH --cpus-per-task=4

# run for five minutes
#              d-hh:mm:ss
#SBATCH --time=0-00:10:00

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
FASTA="$1"

# run the python split file
/global/work/ylammers/Scripts/SplitFasta.py -f $FASTA -c 2500

# happy end
exit 0
