#!/usr/bin/env python3

from Bio import SeqIO
import random
import sys

def main():
    argv = sys.argv
    n = int(argv[1])
    input_path = f"{argv[2]}"
    output_path =  f"{argv[3]}"

    count = 0
    input_fasta = []
    for entry in SeqIO.parse(input_path, "fasta"):
        input_fasta.append(entry)
        count += 1
    
    indices = list(range(0, count))
    random.shuffle(indices)

    output_fasta = []
    for i in range(0, min(count, n)):
        index = indices[i]
        output_fasta.append(input_fasta[index])
    
    SeqIO.write(output_fasta, output_path, "fasta")

main()