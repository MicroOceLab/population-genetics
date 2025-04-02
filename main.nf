include { POPULATION_GENETICS } from './workflows/population-genetics'

workflow {
    main:
        POPULATION_GENETICS()
}