process FIX_FORMAT {
    container "MicroOceLab/python:1.0"
    publishDir "${params.output}/fix-format", mode: "copy"

    input:
        tuple val(sample_id), path(ungapped_sequences)
    
    output:
        tuple val(sample_id), path("${sample_id}-formatted.fasta")

    script:
        """
        fix-format.sh ${ungapped_sequences} ${sample_id}-formatted.fasta
        """
}