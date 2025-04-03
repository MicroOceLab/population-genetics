process PREPARE_ID {
    cpus 1
    container "MicroOceLab/python:1.0"

    input:
        val(sequences)
    
    output:
        tuple eval("echo \${ID}"), val(sequences)

    script:
        """
        ID=`prepare-id.py ${sequences}`
        """
}