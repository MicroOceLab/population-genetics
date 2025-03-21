process COMBINE_CONSENSUS_SEQUENCES {
    container "MicroOceLab/python:1.0"
    publishDir "${params.output}/combine-consensus-sequences", mode: "copy"

    input:
        tuple val(sample_id), val(consensus_sequences)
    
    output:
        tuple val(sample_id), path("${sample_id}.fasta")

    script:
        """
        cat ${consensus_sequences} >> ${sample_id}.fasta
        """
}