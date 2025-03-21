process MAKE_CONSENSUS_SEQUENCE {
    container "quay.io/biocontainers/emboss:5.0.0--h362c646_6"
    publishDir "${params.output}/make-consensus-sequence", mode: "copy"

    input:
        tuple val(sample_id), path(alignment)
    
    output:
        tuple val(sample_id), path("${sample_id}-consensus.fasta"), emit: sequences
        path("${sample_id}-consensus.fasta"), emit: squashed_sequences

    script:
        """
        cons \
            -sequence ${alignment} \
            -outseq ${sample_id}-consensus.fasta
        """
}