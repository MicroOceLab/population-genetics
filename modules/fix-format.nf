process FIX_FORMAT {
    container "alpine:3.21.3"
    publishDir "${params.output}/fix-format", mode: "copy"

    input:
        tuple val(sample_id), path(ungapped_sequences)
    
    output:
        tuple val(sample_id), path("${sample_id}-formatted.fasta")

    script:
        """
        fix-format.sh ${sequences} ${sample_id}-formatted.fasta
        """
}