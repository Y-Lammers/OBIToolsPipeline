#!/bin/bash -l

#######################
#   OBITools pipeline #
#######################

# Usage: Pipeline.sh [ read and tag file list ] [ output file directory ]
# will output the results in the output directory

# Note: please use full file paths for the input files

###########################
# Set the input variables #
###########################

# rename the intput file variable
filelist=$1
outfolder=$2/

# create the output folder
mkdir -p $2



########################
# Create the tag files #
########################

# for each tag file, create the 8 and 9 bp variants
while read line
do
	# run the script that generates the two tag files
	/global/work/ylammers/Scripts/CreateNGSFilterFiles.py $(echo $line | cut -f3 -d " ") GGGCAATCCTGAGCCAA CCATTGAGTCTCTGCACCTATC

done < $filelist



###################
# Merge the reads #
###################

# copy the temp script in preperation for the seqprep commands
cp /global/work/ylammers/Scripts/temp.sh mergecommands.sh

# Add the sbatch commands for each file that needs to be merged
# to the mergecommands.sh script
while read line
do
	# set the output name, based on the tag file name
	outputname=$(echo $line | cut -f3 -d " " | sed 's/.*\///' | sed 's/.tsv//')

	# add the sbatch command to the script
	echo sbatch -W /global/work/ylammers/Scripts/Merge.sh $(echo $line | cut -f1,2 -d " ") $outfolder$outputname \& >> mergecommands.sh

done < $filelist

# run the mergecommands.sh script
#./mergecommands.sh



################################
# Demultiplex the merged reads #
################################

# copy the temp script in preperation for the demuliplexing commands
cp /global/work/ylammers/Scripts/temp.sh demulticommands.sh

# Add the sbatch commands for each file that needs to be
# demultiplexed to the demulticommands.sh script
while read line
do
	# set the input file name (i.e. the merged reads)
	inputname=$(echo $line | cut -f3 -d " " | sed 's/.*\///' | sed 's/.tsv//').fastq

	# copy the merged file twice, once for the 8bp tag demultiplexing run
	# and once for the 9bp tag demultiplexing run
	#cp $inputname ${inputname/.fastq/_8.fastq}
	#cp $inputname ${inputname/.fastq/_9.fastq}

	# add the 8 and 9bp demultiplexing commands to the demultiplexing.sh script
	echo sbatch -W /global/work/ylammers/Scripts/NGSFilter.sh $(echo $line | cut -f3 -d " " | sed 's/.tsv/_8.tsv/') $outfolder${inputname/.fastq/_8.fastq} \& >> demulticommands.sh
	echo sbatch -W /global/work/ylammers/Scripts/NGSFilter.sh $(echo $line | cut -f3 -d " " | sed 's/.tsv/_9.tsv/') $outfolder${inputname/.fastq/_9.fastq} \& >> demulticommands.sh

done < $filelist

# run the demulticommands.sh script
#./demulticommands.sh

# merge the 8 and 9bp results together in one file
while read line
do
	# set the input file name (i.e. the merged reads)
	inputname=$(echo $line | cut -f3 -d " " | sed 's/.*\///' | sed 's/.tsv//').fastq

	# concatenate the 8 and 9bp results in one new file
	#cat ${inputname/.fastq/_8.ali.frm.fastq} ${inputname/.fastq/_9.ali.frm.fastq} > ${inputname/.fastq/.ali.frm.fastq}

	# remove the 8 and 9bp fastq file to free up space
	#rm ${inputname/.fastq/_8}*fastq
	#rm ${inputname/.fastq/_9}*fastq

done < $filelist



############################
# Collapse identical reads #
############################

# copy the temp script in preperation for the OBIuniq commands
cp /global/work/ylammers/Scripts/temp.sh uniqcommands.sh

# Add the sbatch commands for each file that needs
# to be run through OBIuniq
while read line
do
	# set the input file name (i.e. the demultiplexed reads)
	inputname=$(echo $line | cut -f3 -d " " | sed 's/.*\///' | sed 's/.tsv//').ali.frm.fastq

	# add the OBIuniq sbatch command to the uniqcommands script
	echo sbatch -W /global/work/ylammers/Scripts/OBIuniq $outfolder$inputname \& >> uniqcommands.sh

done < $filelist

# run the uniqcommands.sh script
#./uniqcommands.sh



################################
# Correct for library swapping #
################################

# Create the link file required for the library swap correct script
while read line
do
	# set the input file name (i.e. the uniq reads)
	inputname=$(echo $line | cut -f3 -d " " | sed 's/.*\///' | sed 's/.tsv//').ali.frm.uniq.fasta

	# get the number of raw reads for the file
	reads=$(expr $(gunzip -c $(echo $line | cut -f1 -d " ") | wc -l) / 4)

	# add the OBIuniq sbatch command to the uniqcommands script
	echo -e $inputname"\t"$(echo $line | cut -f3 -d " ")"\t"$reads >> TagSwapLink.tsv

done < $filelist

# run the libary swap correct script
#sbatch -W /global/work/ylammers/Scripts/LibrarySwap.sh TagSwapLink.tsv



##########################
# Correct for PCR errors #
##########################

# copy the temp script in preperation for the OBIclean commands
cp /global/work/ylammers/Scripts/temp.sh cleancommands.sh

# Add the sbatch commands for each file that needs
# to be correct for PCR errors with OBIclean
while read line
do
	# set the input file name (i.e. the demultiplexed reads)
	inputname=$(echo $line | cut -f3 -d " " | sed 's/.*\///' | sed 's/.tsv//').ali.frm.uniq.tagswap.fasta

	# add the OBIuniq sbatch command to the uniqcommands script
	echo sbatch -W /global/work/ylammers/Scripts/OBIClean.sh $outfolder$inputname \& >> cleancommands.sh

done < $filelist

# run the uniqcommands.sh script
#./cleancommands.sh



#####################
# Identify the data #
#####################

# copy the temp script in preperation for the identification commands
cp /global/work/ylammers/Scripts/temp.sh idencommands.sh

# Add the sbatch commands for each file that needs
# to be identified with both the arctborbryo and 
# ncbi reference datasets
while read line
do
	# set the input file name (i.e. the demultiplexed reads)
	inputname=$(echo $line | cut -f3 -d " " | sed 's/.*\///' | sed 's/.tsv//').ali.frm.uniq.tagswap.c2.cl.fasta

	# add the OBIuniq sbatch command to the uniqcommands script
	echo sbatch -W /global/work/ylammers/Scripts/EcoTagArctBorBryo.sh $outfolder$inputname \& >> idencommands.sh
	echo sbatch -W /global/work/ylammers/Scripts/EcoTagNCBI-GH.sh $outfolder$inputname \& >> idencommands.sh

done < $filelist

# run the uniqcommands.sh script
#./idencommands.sh



###########################
# Generate the TSV tables #
###########################

# copy the temp script in preperation for the output commands
cp /global/work/ylammers/Scripts/temp.sh outputcommands.sh

# Add the sbatch commands that generate the TSV
# tables for each identified dataset
while read line
do
	# set the input file name (i.e. the demultiplexed reads)
	inputname=$(echo $line | cut -f3 -d " " | sed 's/.*\///' | sed 's/.tsv//').ali.frm.uniq.tagswap.c2.cl.

	# add the OBItab commands for both the ArctBorBryo and NCBI datasets
	echo sbatch -W /global/work/ylammers/Scripts/OBItab.sh $outfolder${inputname}.arctborbryo-iden.fasta \& >> outputcommands.sh
	echo sbatch -W /global/work/ylammers/Scripts/OBItab.sh $outfolder${inputname}.NCBI-iden.fasta \& >> outputcommands.sh

done < $filelist

# run the uniqcommands.sh script
#./outputcommands.sh

#done
exit
