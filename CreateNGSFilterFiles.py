#!/usr/bin/env python

# usage: CreateNGSFilterFiles.py [input tab file] [forward primer] [reverse primer] > [output NGS filter file]

import sys, os

def readSamples(size):

	# create the sample list that will be
	# filled with the sample names and tags
	sampleList=[]

	# parse the sample list
	for line in open(sys.argv[1]):

		# split on the seperator
		line=line.strip().split('\t')

		if 'AOHL' in line[0]: continue

		if len(line[1]) != size: continue

		# add the info to the sampleList
		sampleList.append([line[0],'{0}:{1}'.format(line[1],line[1])])

	return sampleList
		

def formatOutput(size):

	# format the output file and print it

	# print the header
	outputfile = open('{0}_{1}.tsv'.format(os.path.splitext(sys.argv[1])[0],str(size)),'w')

	outputfile.write('#exp\tsample\ttags\tforward_primer\treverse_primer\n')

	# get the sampleList
	sampleList=readSamples(size)

	# parse through the list of samples
	for sample in sampleList:
		
		# format the output and print it
		outputfile.write('gh\t{0}\t{1}\t{2}\t{3}\n'.format(sample[0],sample[1],sys.argv[2].upper(),sys.argv[3].upper()))

	outputfile.close()

formatOutput(8)
formatOutput(9)
