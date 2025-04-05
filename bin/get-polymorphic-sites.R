#!/usr/bin/env Rscript

# Packages
library(ape)
library(pegas)
library(glue)


# Input
project_dir <- getwd() 
argv <- commandArgs(TRUE)
sequences <- read.FASTA(argv[1])
polymorphic_sites_file <- argv[2]


# Polymorphic Sites
polymorphic_sites = seg.sites(sequences)
polymorphic_sites_count = length(polymorphic_sites)
cat(glue("Polymorphic sites: {paste(c(polymorphic_sites), collapse = ', ')}"), file = glue("{project_dir}/{polymorphic_sites_file}.txt"), sep = "\n")
cat(glue("No. of polymorphic sites: {polymorphic_sites_count}"), file = glue("{project_dir}/{polymorphic_sites_file}.txt"), sep = "\n", append = TRUE)