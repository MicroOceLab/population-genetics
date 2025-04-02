process FIX_FORMAT {
    container "MicroOceLab/python:1.0"
    publishDir "${params.output}/fix-format", mode: "copy"

    input:
        tuple val(id), path(sequences)
    
    output:
        tuple val(id), path("${id}-formatted.fasta")

    script:
        """
        fix-gaps.sh ${sequences} ${id}-ungapped.fasta
        fix-headers.sh ${id}-ungapped.fasta ${id}-formatted.fasta
        """
}