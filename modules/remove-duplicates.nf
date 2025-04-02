process REMOVE_DUPLICATES {
    container "quay.io/biocontainers/seqkit:2.10.0--h9ee0642_0"
    publishDir "${params.output}/remove-duplicates", mode: "copy"

    input:
        tuple val(id), path(sequences)
    
    output:
        tuple val(id), path("${id}-unique.fasta")

    script:
        """
        seqkit rmdup -s -P < ${sequences} > ${id}-unique.fasta
        """
}