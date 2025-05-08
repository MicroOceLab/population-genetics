process MAKE_PHYLOGENY {
    cpus 12
    memory "12 GB"
    container "quay.io/biocontainers/raxml-ng:0.9.0--h192cbe9_1"
    publishDir "${params.results}/make-phylogeny", mode: "copy"
    cache "deep"

    input:
        tuple val(id), path(alignment), val(substitution_model)
    
    output:
        tuple val(id), path("${id}.raxml.bestTree.tre"), emit: best_tree
        tuple val(id), path("${id}.raxml.bootstraps.tre"), emit: bootstraps
        tuple val(id), path("${id}.raxml.log.txt"), emit: log
        tuple val(id), path("${id}.raxml.rba"), emit: rba
        tuple val(id), path("${id}.raxml.startTree.tre"), emit: start_tree
        tuple val(id), path("${id}.raxml.support.tre"), emit: support

    script:
        """
        raxml-ng \
            --all \
            --msa ${alignment} \
            --model ${substitution_model} \
            --prefix \${PWD}/${id} \
            --seed 119318 \
            --bs-metric tbe \
            --tree rand{1} \
            --bs-trees 1000 \
            --force perf_threads

        mv ${id}.raxml.bestTree ${id}.raxml.bestTree.tre
        mv ${id}.raxml.bootstraps ${id}.raxml.bootstraps.tre
        mv ${id}.raxml.log ${id}.raxml.log.txt
        mv ${id}.raxml.startTree ${id}.raxml.startTree.tre
        mv ${id}.raxml.support ${id}.raxml.support.tre
        """
}