#!/usr/bin/env Rscript

# Packages
library(ape)
library(glue)


# Input
project_dir <- getwd() 
argv <- commandArgs(TRUE)
phylogeny <- read.tree(argv[1])
pd_matrix_file <- argv[2]


# Pairwise Distance Matrix
pd_matrix <- cophenetic(phylogeny)
write.table(pd_matrix, file = glue("{project_dir}/{pd_matrix_file}.tsv"), quote = FALSE, sep='\t')


# Mean Pairwise Distance
n <- length(colnames(pd_matrix))
mpd <- sum(rowSums(pd_matrix)/(n*(n-1)))
cat(glue("MPD: {mpd}"), file = glue("{project_dir}/{pd_matrix_file}.mpd"), sep = "\n")
