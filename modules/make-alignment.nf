process MAKE_ALIGNMENT {
    container "quay.io/biocontainers/mafft:7.221--0"
    publishDir "${params.output}/make-alignment", mode: "copy"

    input:
        tuple val(sample_id), path(formatted_sequences)
    
    output:
        tuple val(sample_id), path("${sample_id}-alignment.fasta")

    script:
        """
        mafft ${formatted_sequences} > ${sample_id}-alignment.fasta
        """
}