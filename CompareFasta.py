#!/usr/bin/env python

# Usage: CompareFasta.py -f1 [sequence file] -f2 [sequence file] -a [action]

# author: Youri Lammers
# contact: youri.lammers@uit.no / youri.lammers@gmail.com

# import the modules used by the script
import os, argparse, itertools, sys

# Retrieve the commandline arguments
parser = argparse.ArgumentParser(description = 'Split a fasta file into several sub files, each containing max [count] reads.')

parser.add_argument('-f1', '--sequence_file1', metavar='First sequence file', dest='sequence1', type=str,
			help='The first sequence file in fasta format.')
parser.add_argument('-f2', '--sequence_file2', metavar='Second sequence file', dest='sequence2', type=str,
			help='The second sequence file in fasta format.')
parser.add_argument('-a', '--action', metavar='Action to undertacke', dest='action', type=str,
			help='Action can be: difference (f1-f2) or overlap (f1==f2)')
args = parser.parse_args()

def extract_sequences(file):

	# open the sequence file submitted by the user, get 
	sequence_file = open(file)

	sequences, nucl = {}, []

	# parse throught the file
        lines = (x[1] for x in itertools.groupby(sequence_file, key=lambda line: line[0] == '>'))

	# walk through the header and obtain the sequences
        for headers in lines:
		header = headers.next().strip()
		sequence = ''.join(line.strip() for line in lines.next())
				
		# add the header + sequence to the dictionary
		if sequence not in sequences:
			sequences[sequence] = [header]
		else:
			sequences[sequence].append(header)
		
		# add the sequence to the sequence list
		nucl.append(sequence)


	# return the sequences
	return [sequences, list(set(nucl))]


def main ():

	# get the sequences for fasta 1 and fasta 2
	f1, f2 = extract_sequences(args.sequence1),extract_sequences(args.sequence2)

	# result dictionary
	resultdict, count = {}, 0

	# compare the fasta files
	if args.action == "difference":

		for nucl in f1[1]:
			if nucl not in f2[1]:
				count += 1
				for seq in f1[0][nucl]:
					print '{0}\n{1}'.format(seq,nucl)

	elif args.action == "overlap":

		for nucl in f1[1]:
			if nucl in f2[1]:
				count += 1
				for seq in f1[0][nucl]:
					print '{0}\n{1}'.format(seq,nucl)
	
	print >> sys.stderr, count


if __name__ == '__main__':
	main()
