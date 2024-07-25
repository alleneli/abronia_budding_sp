import argparse

def read_fasta(file_path):
    sequences = {}
    current_header = None
    with open(file_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith('>'):
                current_header = line[1:]
                sequences[current_header] = ''
            elif line:
                sequences[current_header] += line
    return sequences

def write_fasta(file_path, sequences, line_length=80):
    with open(file_path, 'w') as f:
        for header, sequence in sequences.items():
            f.write(f'>{header}\n')
            for i in range(0, len(sequence), line_length):
                f.write(sequence[i:i+line_length] + '\n')

def remove_sequence(sequences, header_prefix):
    keys_to_remove = [header for header in sequences if header.startswith(header_prefix)]
    for key in keys_to_remove:
        del sequences[key]

def main():
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description='Remove sequence from alignment.')
    parser.add_argument('-i', '--input', help='Input alignment file', required=True)
    parser.add_argument('-r', '--header', help='Header prefix to remove', required=True)
    parser.add_argument('-o', '--output', help='Output alignment file', required=True)
    args = parser.parse_args()
    
    input_file = args.input
    header_prefix = args.header
    output_file = args.output
    
    # Read FASTA file
    sequences = read_fasta(input_file)
    
    # Remove sequences with headers starting with the specified prefix
    remove_sequence(sequences, header_prefix)
    
    # Write updated sequences to file
    write_fasta(output_file, sequences)
    print(f"Sequences with headers starting with '{header_prefix}' removed successfully.")
    print(f"Updated alignment saved to '{output_file}'.")

if __name__ == "__main__":
    main()


