#!/bin/bash

# Usage: ./Map.sh [Reference file] [Fastq file] [output directory]

Reference="$1"
FASTQ="$2"
output_dir="$3"
base=$(basename "${FASTQ%.*}")
output_base=${output_dir}${base}

# align the fasta file
/global/work/ylammers/Tools/bwa/bwa aln -t 16 $Reference $FASTQ > ${output_base}.sai

# convert to a bam file
/global/work/ylammers/Tools/bwa/bwa samse $Reference ${output_base}.sai $FASTQ | /global/work/ylammers/Tools/samtools/samtools view -Sb -@ 16 -q 30 -T $Reference -F 4 - > ${output_base}.bam
