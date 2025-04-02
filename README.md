# population-genetics
Bioinformatics pipeline for studying the phylogeny and haplotype diversity of sequenced markers

To run the default pipeline, place your query sequences in 'data/query' and run:

```bash
nextflow run main.nf
```

To run the pipeline with additional analysis against reference sequences, place your sequences in 'data/reference' and run either:
 
```bash
nextflow run main.nf \
    --reference consensus
```

OR

```bash
nextflow run main.nf \
    --reference random
```

Note that '--reference consensus' generates a consensus sequence for each reference FASTA file, while '--reference random' selects 30 random sequences instead.