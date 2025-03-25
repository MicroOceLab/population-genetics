process FIX_FORMAT {
    container "MicroOceLab/python:1.0"
    publishDir "${params.output}/fix-format", mode: "copy"

    input:
        tuple val(sample_id), path(sequences)
    
    output:
        tuple val(sample_id), path("${sample_id}-formatted.fasta")

    script:
        """
        fix-gaps.sh ${sequences} ${sample_id}-ungapped.fasta
        fix-headers.sh ${sample_id}-ungapped.fasta ${sample_id}-formatted.fasta
        """
}