process MAKE_PD_MATRIX {
    cpus 4
    memory "12 GB"
    container "MicroOceLab/r:1.0"
    publishDir "${params.results}/make-pd-matrix", mode: "copy"

    input:
        tuple val(id), val(phylogeny)
    
    output:
        tuple val(id), path("${id}-pd-matrix.tsv"), emit: matrix
        tuple val(id), path("${id}-pd-matrix.mpd"), emit: matrix_mpd

    script:
        """
        make-pd-matrix.R ${phylogeny} ${id}-pd-matrix
        """
}