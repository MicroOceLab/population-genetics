process PREPARE_SAMPLE_ID {
    container "MicroOceLab/python:1.0"

    input:
        val(sequences)
    
    output:
        tuple stdout, val(sequences)

    script:
        """
        echo `prepare-sample-id.py ${sequences}`
        """
}