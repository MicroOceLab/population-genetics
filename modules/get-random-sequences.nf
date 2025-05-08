process GET_RANDOM_SEQUENCES {
    cpus 2
    memory "2 GB"
    container "MicroOceLab/python:1.0"
    publishDir "${params.results}/get-random-sequences", mode: "copy"

    input:
        tuple val(id), val(sequences)
    
    output:
        tuple val(id), path("${id}-random.fasta")

    script:
        """
        touch ${id}-random.fasta
        get-random-sequences.py ${params.n} ${sequences} ${id}-random.fasta
        """
}