process PREPARE_SAMPLE_ID {
    input:
        val(sequences)
    
    output:
        tuple stdout, val(sequences)

    script:
        """
        echo `prepare-sample-id.py ${sequences}`
        """
}