process FIX_GAPS {
    container "alpine:3.21.3"
    publishDir "${params.output}/fix-gaps", mode: "copy"

    input:
        tuple val(sample_id), val(sequences)
    
    output:
        tuple val(sample_id), val(ungapped_sequences)

    script:
        sample_id = sample_id.replaceAll("\\s","")

        """
        fix-gaps.sh ${sequences} ${sample_id}-ungapped.fasta
        """
}