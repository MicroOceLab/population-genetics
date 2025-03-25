process PREPARE_SAMPLE_ID {
    container "MicroOceLab/python:1.0"

    input:
        val(sequences)
    
    output:
        tuple eval("echo \${SAMPLE_ID}"), val(sequences)

    script:
        """
        SAMPLE_ID=`prepare-sample-id.py ${sequences}`
        """
}