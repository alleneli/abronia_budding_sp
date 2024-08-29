#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
from Bio import SeqIO

def rewrite_headers_in_cwd():
    cwd = os.getcwd()  # Get current working directory
    rewrite_headers_in_folder(cwd)

def rewrite_headers_in_folder(folder_path):
    # List all files in the folder
    files = os.listdir(folder_path)
    # Filter for .fna files
    fna_files = [file for file in files if file.endswith(".fna")]

    # Process each .fna file
    for file in fna_files:
        input_file = os.path.join(folder_path, file)
        # Call the header rewriting function for each file
        rewrite_header(input_file)

def rewrite_header(input_file):
    # Extract filename without extension
    filename = os.path.splitext(os.path.basename(input_file))[0]

    # Read input FASTA file and rewrite headers
    records = list(SeqIO.parse(input_file, 'fasta'))
    
    for record in records:
        record.id = f"{filename}_{record.id}"
        record.description = ""

    # Write modified sequences to new file
    output_file = f"{filename}_file_header.fna"
    with open(output_file, 'w') as outfile:
        SeqIO.write(records, outfile, 'fasta')
    
    print(f"Headers rewritten and saved to {output_file}")

if __name__ == "__main__":
    # Check if additional arguments are provided
    if len(sys.argv) > 1:
        print("Usage: python rewrite_header.py")
        sys.exit(1)
    
    rewrite_headers_in_cwd()





