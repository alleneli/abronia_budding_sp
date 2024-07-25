#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Python code to organize files after treeshrink has been ran in a directory
# it creates "shrinked" fasta files in a new folder for subsequent concatenation


import glob
from Bio import SeqIO
import os
import shutil

file_pattern = ".fna"
all_files = glob.glob('*'+file_pattern)
all_prefix = map(lambda each: each.split('_')[0], all_files)

for prefix in all_prefix:
    seq_to_rem = []
    file_path_w_rogues = prefix + '_treeshrink/' + prefix + '.treefile.shrunk_0.30.txt'
    with open(file_path_w_rogues) as infile:
        print( 'removing rogue tips from ' + str(prefix))
        for line in infile:
            seqs = line.split('\n')[0]
            seqs = seqs.split('\t')[:-1]
            seq_to_rem =  seq_to_rem + seqs
    fasta_file = prefix + ''
    output = fasta_file + '.ts'
    records = list(SeqIO.parse(fasta_file, format="fasta"))
    records_keep =[]
    for record in records:
        if str(record.name) not in seq_to_rem:
            #print str(record.name)
            records_keep.append(record)
    with open(output, "w") as output_handle:
        SeqIO.write(records_keep, output_handle, "fasta")

# organize files

os.makedirs('shrinked_trees_fastas_01')


print( "Tiding up file structure")

for prefix in all_prefix:
     tree_file = prefix + 'treefile_treeshrink/' + prefix + '.treefile.shrunk_0.30.treefile'
     rogues = prefix + 'treefile_treeshrink/' + prefix + '.treefile.shrunk_0.30.txt'
     fasta_shrinked = prefix + 'fna.ts'

     dest_tree_file = './shrinked_trees_fastas_01/' + prefix + '.treefile.shrunk_0.30.treefile'
     dest_rogues = './shrinked_trees_fastas_01/' + prefix + 'treefile.shrunk_0.30.txt'
     dest_fasta_shrinked = './shrinked_trees_fastas_01/' + prefix + '.fna.ts'

     shutil.move(tree_file, dest_tree_file)
     shutil.move(rogues, dest_rogues)
     shutil.move(fasta_shrinked, dest_fasta_shrinked)

     dir_to_rem = prefix + '_treeshrink'
     os.rmdir(dir_to_rem)



