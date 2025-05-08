process COMBINE_SEQUENCES {
    cpus 1
    memory "2 GB"
    container "MicroOceLab/python:1.0"
    publishDir "${params.results}/combine-sequences", mode: "copy"
    cache "deep"

    input:
        tuple val(id), val(sequences)
    
    output:
        tuple val(id), path("${id}.fasta")

    script:
        """
        cat ${sequences} >> ${id}.fasta
        """
}