#!/usr/bin/env python

# Usage: SplitFasta.py -f [sequence file] -c [count]

# author: Youri Lammers
# contact: youri.lammers@uit.no / youri.lammers@gmail.com

# import the modules used by the script
import os, argparse, itertools

# Retrieve the commandline arguments
parser = argparse.ArgumentParser(description = 'Split a fasta file into several sub files, each containing max [count] reads.')

parser.add_argument('-f', '--sequence_file', metavar='Sequence file', dest='sequence', type=str,
			help='The sequence file in fasta format.')
parser.add_argument('-c', '--count', metavar='sequence count per file', dest='count', type=int,
			help='The number of sequences per sub file.')
args = parser.parse_args()

def extract_sequences():

	# open the sequence file submitted by the user, get 
	sequence_file = open(args.sequence)

	# parse throught the file
        lines = (x[1] for x in itertools.groupby(sequence_file, key=lambda line: line[0] == '>'))

	# walk through the header and obtain the sequences
        for headers in lines:
		header = headers.next().strip()
		sequence = ''.join(line.strip() for line in lines.next())
				
		# yield the header + sequence
		yield [header, sequence]


def main ():

	# current sequence count, file count and basename
	cur_count, file_count, basename = 0, 1, os.path.splitext(args.sequence)[0]

	# open the current output file, name is the input
	# file + _sub[file_count]
	output_file = open('{0}_sub{1}.fasta'.format(basename,file_count),'w')

	# get a read from the input file
	for read in extract_sequences():

		# write the sequence (max 60 nucl per line)
		output_file.write('{0}\n{1}\n'.format(read[0],'\n'.join([read[1][i:i+60] for i in range(0, len(read[1]), 60)])))

		# increase the sequence count
		cur_count += 1

		# if the total count is reached, close the current file,
		# open a new file and reset the sequence count
		if cur_count >= args.count:
			#output_file.close()
			file_count += 1
			output_file = open('{0}_sub{1}.fasta'.format(basename,file_count),'w')
			cur_count = 0

if __name__ == '__main__':
	main()
