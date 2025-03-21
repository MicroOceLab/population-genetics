process CALCULATE_SUBSTITUTION_MODEL {
    container "quay.io/biocontainers/modeltest-ng:0.1.7--hf316886_3"
    publishDir "${params.output}/calculate-substitution-model", mode: "copy"

    input:
        tuple val(sample_id), path(combined_consensus_alignment)
    
    output:
        tuple val(sample_id), path("${sample_id}-substitution-model.txt")

    script:
        """
        modeltest-ng \
            -i ${combined_consensus_alignment} \
            -d nt \
            -p 4 \
            -T raxml \
            -o ${sample_id}-substitution-model.txt
        """
}