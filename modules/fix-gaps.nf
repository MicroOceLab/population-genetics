process FIX_GAPS {
    container "MicroOceLab/python:1.0"
    publishDir "${params.output}/fix-gaps", mode: "copy"

    input:
        tuple val(sample_id), path(sequences)
    
    output:
        tuple val(sample_id), path("${sample_id}-ungapped.fasta")

    script:
        """
        fix-gaps.sh ${sequences} ${sample_id}-ungapped.fasta
        """
}