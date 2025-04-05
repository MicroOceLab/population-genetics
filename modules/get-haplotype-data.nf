process GET_HAPLOTYPE_DATA {
    cpus 4
    container "MicroOceLab/r:1.0"
    publishDir "${params.results}/get-haplotype-data", mode: "copy"

    input:
        tuple val(id), val(sequences)
    
    output:
        tuple val(id), path("${id}-haplotypes.fasta"), emit: sequences
        tuple val(id), path("${id}-haplotypes.freq"), emit: frequencies
        tuple val(id), path("${id}-haplotypes.png"), emit: network
        tuple val(id), path("${id}-haplotypes.div"), emit: diversity_indices

    script:
        """
        get-haplotype-data.R ${sequences} ${id}-haplotypes.txt
        """
}