process GET_POLYMORPHIC_SITES {
    cpus 2
    container "MicroOceLab/r:1.0"
    publishDir "${params.results}/get-polymorphic-sites", mode: "copy"

    input:
        tuple val(id), val(sequences)
    
    output:
        tuple val(id), path("${id}-polymorphic-sites.txt")

    script:
        """
        get-polymorphic-sites.R ${sequences} ${id}-polymorphic-sites
        """
}