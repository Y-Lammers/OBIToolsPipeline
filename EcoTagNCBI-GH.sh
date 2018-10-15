#!/bin/bash -l

#############################
#   	EcoTag		    #
#############################

# Usage: EcoTag.sh [Fasta File]
# will output the results in [input fasta File].iden.fasta

# Note: please use full file paths for the input files

#SBATCH --job-name=EcoTag

# we ask for 1 task with 1 cores
#SBATCH --nodes=1
#SBATCH --ntask=1
#SBATCH --cpus-per-task=4

# run for five minutes
#              d-hh:mm:ss
#SBATCH --time=0-08:00:00

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

# start the EcoTag script
/global/work/ylammers/OBI/bin/ecotag --skip-on-error -t /global/work/ylammers/Reference/TAXO -d /global/work/ylammers/Reference/EMBL/embl_last --fasta -R /global/work/ylammers/Reference/GH/GH.final2.fasta $FASTA > ${FASTA/.fasta/.NCBI-iden.fasta}

# happy end
exit 0
