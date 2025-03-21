process PREPARE_SAMPLE_ID {
    container "alpine:3.21.3"

    input:
        val(sequences)
    
    output:
        tuple stdout, path(sequences)

    script:
        """
        echo `prepare-sample-id.py ${sequences}`
        """
}