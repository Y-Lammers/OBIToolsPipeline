#!/bin/bash -l

#############################
#   	OBItab		    #
#############################

# Usage: OBItab.sh [Identified fasta file]
# will output the results in [input fasta file].ann.sort.tsv

# Note: please use full file paths for the input files

#SBATCH --job-name=OBItab

# we ask for 1 task with 1 cores
#SBATCH --nodes=1
#SBATCH --ntask=1
#SBATCH --cpus-per-task=4

# run for five minutes
#              d-hh:mm:ss
#SBATCH --time=0-04:00:00

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

# start the OBItab and related scripts
/global/work/ylammers/OBI/bin/obiannotate --delete-tag=scientific_name_by_db --delete-tag=obiclean_samplecount --delete-tag=obiclean_count --delete-tag=obiclean_singletoncount --delete-tag=obiclean_cluster --delete-tag=obiclean_internalcount --delete-tag=obiclean_head --delete-tag=taxid_by_db --delete-tag=obiclean_headcount --delete-tag=id_status --delete-tag=rank_by_db --delete-tag=order_name --delete-tag=order $FASTA > ${FASTA/.fasta/.ann.fasta}
/global/work/ylammers/OBI/bin/obisort -k count -r ${FASTA/.fasta/.ann.fasta} > ${FASTA/.fasta/.ann.sort.fasta}
/global/work/ylammers/OBI/bin/obitab -o ${FASTA/.fasta/.ann.sort.fasta} > ${FASTA/.fasta/.ann.sort.tsv}

# happy end
exit 0
