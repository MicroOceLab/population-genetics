process CALCULATE_SUBSTITUTION_MODEL {
    cpus 4
    container "quay.io/biocontainers/modeltest-ng:0.1.7--hf316886_3"
    publishDir "${params.results}/calculate-substitution-model", mode: "copy"

    input:
        tuple val(id), path(combined_consensus_alignment)
    
    output:
        tuple val(id), eval("echo \${MODEL}"), emit: model
        tuple val(id), path("${id}-substitution-model.out"), emit: model_output
        tuple val(id), path("${id}-substitution-model.tree"), emit: model_tree

    script:
        """
        modeltest-ng \
            -i ${combined_consensus_alignment} \
            -d nt \
            -p 4 \
            -T raxml \
            -o ${id}-substitution-model \
            > DUMP

        MODEL_OUTPUT=(`cat ${id}-substitution-model.out | grep "Model:" | head -1`)
        MODEL=\${MODEL_OUTPUT[1]}
        """
}