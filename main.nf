include { SPECIES_DELIMITATION } from './workflows/species-delimitation'

workflow {
    main:
        SPECIES_DELIMITATION()
}