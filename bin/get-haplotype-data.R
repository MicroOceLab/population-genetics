#!/usr/bin/env Rscript

# Packages
library(ape)
library(pegas)
library(glue)
library(utils)
library(stringr)


# Input
project_dir <- getwd() 
argv <- commandArgs(TRUE)
sequences <- read.FASTA(argv[1])
haplotypes_file <- argv[2]


# Haplotypes
haplotypes <- haplotype(sequences)
write.dna(haplotypes, glue("{project_dir}/{haplotypes_file}.fasta"), format = "fasta")


# Haplotype Frequencies
haplotype_frequencies <- haploFreq(as.matrix(sequences), split = "-", what = 1)
write.table(as.matrix(haplotype_frequencies), file = glue("{project_dir}/{haplotypes_file}.freq"), sep = "\t", eol = "\n", row.names = TRUE, col.names = TRUE)


# Haplotype Network
png(filename = glue("{project_dir}/{haplotypes_file}.png"), height = 1024, width = 1024, res = 150)
haplotype_network <- haploNet(haplotypes)
plot(haplotype_network, size = sqrt(attr(haplotype_network, "freq")), pie = haplotype_frequencies, threshold = c(5, 20), cex = 1, legend = c(-7, 11))
dev.off()


# Haplotype Diversity Indices
labels <- array(unlist(labels(sequences)))
unique_locations <- array(unlist(unique(lapply(labels, function (label) str_split(label, "-")[[1]][1]))))
number_of_locations <- length(unique_locations)

haplotype_diversity_indices <- array("", dim = number_of_locations)
for (i in 1:number_of_locations) {
  sequences_in_location_i <- as.matrix(sequences)[array(grep(unique_locations[i], labels)), ]
  haplotype_diversity_indices[i] <- glue("{unique_locations[i]}\t{hap.div(sequences_in_location_i)}")
}

write.table(as.matrix(haplotype_diversity_indices), file = glue("{project_dir}/{haplotypes_file}.div"), sep = "\t", eol = "\n", row.names = FALSE, col.names = FALSE)

