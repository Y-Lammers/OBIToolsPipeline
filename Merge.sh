#!/bin/bash -l

################
#   SeqPrep    #
################

# Usage: Merge.sh [file 1] [file 2] [output directory + file]
# will output the results [output directory]

#SBATCH --job-name=SeqPrep

# we ask for 1 task with 1 cores
#SBATCH --nodes=1
#SBATCH --ntask=1
#SBATCH --cpus-per-task=4

# run for five minutes
#              d-hh:mm:ss
#SBATCH --time=0-04:00:00

#SBATCH --partition normal

# this is a hard limit 
#SBATCH --mem=2000MB

# turn on all mail notification
## SBATCH --mail-type=ALL

# you may not place bash commands before the last SBATCH directive

# load modules
module load StdEnv
module load Python/2.7.13-foss-2017a
source /global/work/ylammers/OBI/bin/activate

# define and create a unique scratch directory
#SCRATCH_DIRECTORY=/global/work/ylammers/temp1

Forward=$1
Reverse=$2
Output=$3

/global/work/ylammers/Tools/SeqPrep/SeqPrep -f $Forward -r $Reverse -1 /global/work/ylammers/1_R1.fastq.gz -2 /global/work/ylammers/1_R2.fastq.gz -s ${Output}.fastq.gz

rm /global/work/ylammers/1_R1.fastq.gz
rm /global/work/ylammers/1_R2.fastq.gz

gunzip ${Output}.fastq.gz

# happy end
exit 0
