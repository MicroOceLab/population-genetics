process MAKE_APPENDED_ALIGNMENT {
    cpus 8
    memory "12 GB"
    container "quay.io/biocontainers/mafft:7.221--0"
    publishDir "${params.results}/make-appended-alignment", mode: "copy"

    input:
        tuple val(id), path(alignment), path(sequences)
    
    output:
        tuple val(id), path("${id}-alignment.fasta")

    script:
        """
        mafft --add ${sequences} --reorder ${alignment} > ${id}-alignment.fasta
        """
}