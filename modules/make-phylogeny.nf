process MAKE_PHYLOGENY {
    container "quay.io/biocontainers/raxml-ng:0.9.0--h192cbe9_1"
    publishDir "${params.output}/make-phylogeny", mode: "copy"
    cache "deep"

    input:
        tuple val(sample_id), path(alignment), val(substitution_model)
    
    output:
        tuple val(sample_id), path("${sample_id}.raxml.bestTree.tre"), emit: best_tree
        tuple val(sample_id), path("${sample_id}.raxml.bootstraps.tre"), emit: bootstraps
        tuple val(sample_id), path("${sample_id}.raxml.log.txt"), emit: log
        tuple val(sample_id), path("${sample_id}.raxml.rba"), emit: rba
        tuple val(sample_id), path("${sample_id}.raxml.reduced.phy.tre"), emit: reduced
        tuple val(sample_id), path("${sample_id}.raxml.startTree.tre"), emit: start_tree
        tuple val(sample_id), path("${sample_id}.raxml.support.tre"), emit: support

    script:
        """
        raxml-ng \
            --all \
            --msa ${alignment} \
            --model ${substitution_model} \
            --prefix \${PWD}/${sample_id} \
            --seed 119318 \
            --bs-metric tbe \
            --tree rand{1} \
            --bs-trees 1000

        mv ${sample_id}.raxml.bestTree ${sample_id}.raxml.bestTree.tre
        mv ${sample_id}.raxml.bootstraps ${sample_id}.raxml.bootstraps.tre
        mv ${sample_id}.raxml.log ${sample_id}.raxml.log.txt
        mv ${sample_id}.raxml.reduced.phy ${sample_id}.raxml.reduced.phy.tre
        mv ${sample_id}.raxml.startTree ${sample_id}.raxml.startTree.tre
        mv ${sample_id}.raxml.support ${sample_id}.raxml.support.tre
        """
}