process MAKE_ALIGNMENT {
    cpus 8
    container "quay.io/biocontainers/mafft:7.221--0"
    publishDir "${params.output}/make-alignment", mode: "copy"

    input:
        tuple val(id), path(formatted_sequences)
    
    output:
        tuple val(id), path("${id}-alignment.fasta")

    script:
        """
        mafft ${formatted_sequences} > ${id}-alignment.fasta
        """
}