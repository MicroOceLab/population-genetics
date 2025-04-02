process COMBINE_CONSENSUS_SEQUENCES {
    container "MicroOceLab/python:1.0"
    publishDir "${params.output}/combine-consensus-sequences", mode: "copy"
    cache "deep"

    input:
        tuple val(id), val(consensus_sequences)
    
    output:
        tuple val(id), path("${id}.fasta")

    script:
        """
        cat ${consensus_sequences} >> ${id}.fasta
        """
}