process GET_RANDOM_SEQUENCES {
    container "MicroOceLab/python:1.0"
    publishDir "${params.output}/get-random-sequences", mode: "copy"

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