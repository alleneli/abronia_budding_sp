#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Python script to make two kinds of concatenations:
# 1. a concatenation of introns and exons per gene
# 2. a supermatrix concatenation
# for every concatenation the script produces a RAxML partition
# a dataframe is produce with data occupancy per taxon
# a summary text with occupancy statistics is produced

import glob
from Bio import AlignIO
from collections import defaultdict
from Bio.Seq import Seq
from Bio.Seq import UnknownSeq
from Bio.Align import MultipleSeqAlignment
from Bio.SeqRecord import SeqRecord
import pandas as pd

file_pattern = ".fna"
all_files = glob.glob('*'+file_pattern)

genes = map(lambda each:each.split('.')[0], all_files)

### concatenation function, source https://github.com/compbiocore/BioCookbook.jl/blob/master/python/concatenate.py

def concatenate(alignments):

    # Get the full set of labels (i.e. sequence ids) for all the alignments
    all_labels = set(seq.id for aln in alignments for seq in aln)
    
    # Make a dictionary to store info as we go along
    # (defaultdict is convenient -- asking for a missing key gives back an empty list)
    tmp = defaultdict(list)
    
    # Assume all alignments have same alphabet
    #alphabet = alignments[0]._alphabet
    
    for aln in alignments:
        length = aln.get_alignment_length()
        
        # check if any labels are missing in the current alignment
        these_labels = set(rec.id for rec in aln)
        missing = all_labels - these_labels
        
        # if any are missing, create unknown data of the right length,
        # stuff the string representation into the tmp dict
        for label in missing:
            #new_seq = UnknownSeq(length, alphabet=alphabet)
            new_seq = UnknownSeq(length)
            tmp[label].append(str(new_seq))
        
        # else stuff the string representation into the tmp dict
        for rec in aln:
            tmp[rec.id].append(str(rec.seq))
            
    # Stitch all the substrings together using join (most efficient way),
    # and build the Biopython data structures Seq, SeqRecord and MultipleSeqAlignment
    #msa = MultipleSeqAlignment(SeqRecord(Seq(''.join(v), alphabet=alphabet), id=k) 
    return MultipleSeqAlignment(SeqRecord(Seq(''.join(v)), id=k)
               for (k,v) in tmp.items())

#    with open(outfile, "w") as out:
#    AlignIO.write(msa,outfile,"fasta")
###################### end of function

# Construction of the supermatrix

all_aligns = []

#import every aligment out there
for file in all_files:
    print("reading file " + file)
    alignment = AlignIO.read(file, format="fasta")
    all_aligns.append(alignment)

# Concanate all the alignments and create an output file
print("concatenating alignments")
supermatrix = concatenate(all_aligns)
for record in supermatrix:
    record.description = ""
supermatrix_name = "supermatrix.fasta"
output_handle = open(supermatrix_name, "w")
AlignIO.write(supermatrix,output_handle,"fasta")
output_handle.close()


print("writing partition file for supermatrix")

lines = []
file_count = 0
gene_start = 1
gene_finish = 0

for alignment in all_aligns:
    #print len(alignment[0].seq)
    gene_finish += len(alignment[0].seq)
    line = 'DNA, ' + all_files[file_count].split('.')[0] + \
           ' = ' + str(gene_start) + '-' + str(gene_finish) + '\n'
    lines.append(line)
    file_count += 1
    gene_start += len(alignment[0].seq)
    #print line

model_file_name = "supermatrix.model"
with open(model_file_name, "w") as outfile:
    for line in lines:
        outfile.write(line)

print("Creating a dataframe summarizing taxon occupancy")
all_labels = list(seq.id for seq in supermatrix)
all_labels.sort()

columns = ["sample","number_of_regions","total_characters"]
stats = pd.DataFrame(columns=columns)
len(all_labels)
stats['sample'] = all_labels
stats = stats.fillna(0)
stats.set_index('sample', inplace=True)

seq_count = 0
for alignment in all_aligns:
    for sequence in alignment:
        stats.loc[str(sequence.id), 'number_of_regions'] += 1

for sequence in supermatrix:
    seq = str(sequence.seq)
    seq = seq.replace("?","")
    stats.loc[str(sequence.id), 'total_characters'] = len(seq)

stats["region_perc"] = stats['number_of_regions'] / len(all_aligns)
stats['characters_perc'] = stats['total_characters'] / len(supermatrix[0].seq)

stats.to_csv(path_or_buf="taxon_occupancy.csv")


print("Calculating matrix occupancy stats")

total_matrix_dimensions = len(supermatrix) * len(supermatrix[0].seq)
cells_occupied = stats['total_characters'].sum()
cell_occupancy = float(cells_occupied) / float(total_matrix_dimensions)

total_regions = len(supermatrix) * len(all_aligns)
regions_occupied = stats['number_of_regions'].sum()
region_occupancy =  float(regions_occupied) / float(total_regions)

with open("occupancy_stats.txt", "w") as outfile:
    text = "cell occupancy = " + str(cell_occupancy) + "\nregion occupancy = " + str(region_occupancy)
    outfile.write(text)

print("done (っ▀¯▀)つ")
