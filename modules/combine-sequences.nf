process COMBINE_SEQUENCES {
    container "MicroOceLab/python:1.0"
    publishDir "${params.output}/combine-sequences", mode: "copy"
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