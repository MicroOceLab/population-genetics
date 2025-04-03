process FIX_FORMAT {
    cpus 1
    container "quay.io/biocontainers/seqkit:2.10.0--h9ee0642_0"
    publishDir "${params.output}/fix-format", mode: "copy"

    input:
        tuple val(id), path(sequences)
    
    output:
        tuple val(id), path("${id}-formatted.fasta")

    script:
        """
        fix-gaps.sh ${sequences} ${id}-ungapped.fasta
        fix-headers.sh ${id}-ungapped.fasta ${id}-header-fixed.fasta
        seqkit seq ${id}-header-fixed.fasta -o ${id}-formatted.fasta
        """
}