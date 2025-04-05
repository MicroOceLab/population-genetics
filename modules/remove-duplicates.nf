process REMOVE_DUPLICATES {
    cpus 1
    container "quay.io/biocontainers/seqkit:2.10.0--h9ee0642_0"
    publishDir "${params.results}/remove-duplicates", mode: "copy"

    input:
        tuple val(id), path(sequences)
    
    output:
        tuple val(id), path("${id}-unique.fasta")

    script:
        """
        seqkit rmdup -s -P < ${sequences} > ${id}-unique.fasta
        """
}