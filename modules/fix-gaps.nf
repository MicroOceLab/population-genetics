process FIX_GAPS {
    container "alpine:3.21.3"
    publishDir "${params.output}/fix-gaps", mode: "copy"

    input:
        tuple val(sample_id), path(sequences)
    
    output:
        tuple val(sample_id), path("${sample_id}-ungapped.fasta")

    script:
        sample_id = sample_id.replaceAll("\\s","")

        """
        fix-gaps.sh ${sequences} ${sample_id}-ungapped.fasta
        """
}