process MAKE_CONSENSUS {
    cpus 8
    container "quay.io/biocontainers/emboss:5.0.0--h362c646_6"
    publishDir "${params.results}/make-consensus", mode: "copy"

    input:
        tuple val(id), path(alignment)
    
    output:
        tuple val(id), path("${id}-consensus.fasta")

    script:
        """
        cons \
            -sequence ${alignment} \
            -outseq ${id}-consensus.fasta \
            -name ${id}-consensus \
            -plurality 0.2
        """
}