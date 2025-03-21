process COMBINE_CONSENSUS_SEQUENCES {
    container "alpine:3.21.3"
    publishDir "${params.output}/combine-consensus-sequences", mode: "copy"

    input:
        tuple val(sample_id), val(consensus_sequences)
    
    output:
        tuple val("combined-consensus"), path("combined-consensus.fasta")

    script:
        """
        cat consensus_sequences >> combined-consensus.fasta
        """
}