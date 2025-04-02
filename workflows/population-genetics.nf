params_reference = ["consensus", "random"]
if (params.reference && !params_reference.contains(params.reference)) {
    error "ERROR: Invalid reference mode (--reference) specified for phylogenetic placement"
}

include { PREPARE_ID as PREPARE_QUERY_ID                                     } from '../modules/prepare-id'
include { FIX_FORMAT as FIX_QUERY_FORMAT                                     } from '../modules/fix-format'
include { REMOVE_DUPLICATES as REMOVE_QUERY_DUPLICATES                       } from '../modules/remove-duplicates'
include { MAKE_ALIGNMENT as MAKE_QUERY_ALIGNMENT                             } from '../modules/make-alignment'
include { MAKE_CONSENSUS as MAKE_QUERY_CONSENSUS                             } from '../modules/make-consensus'
include { CALCULATE_SUBSTITUTION_MODEL as CALCULATE_QUERY_SUBSTITUTION_MODEL } from '../modules/calculate-substitution-model'
include { MAKE_PHYLOGENY as MAKE_QUERY_PHYLOGENY                             } from '../modules/make-phylogeny'

include { PHYLOGENETIC_PLACEMENT } from '../subworkflows/phylogenetic-placement'

/*
include { MAKE_PD_MATRIX                                                         } from '../modules/make-pd-matrix'
include { CALCULATE_MPD                                                          } from '../modules/calculate-mpd'
*/

workflow POPULATION_GENETICS {
    main:
        Channel.fromPath('./data/query/*.fasta')
            .set {ch_query_fasta}
            
        Channel.fromPath('./data/query/*.fas')
            .set {ch_query_fas}

        Channel.fromPath('./data/query/*.fna')
            .set {ch_query_fna}

        Channel.fromPath('./data/query/*.fa')
            .set {ch_query_fa}

        ch_query_fasta
            .mix(ch_query_fas, ch_query_fna, ch_query_fa)
            .set {ch_query_sequences}

        ch_query_sequences
            .count()
            .map { query_sequence_count ->
                if (query_sequence_count == 0) {
                    error "ERROR: Missing query sequences in './data/query/'"
                }
            }

        PREPARE_QUERY_ID(ch_query_sequences)
            .set {ch_query_sequences_with_id}

        FIX_QUERY_FORMAT(ch_query_sequences_with_id)
            .set {ch_formatted_query_sequences}
        
        REMOVE_QUERY_DUPLICATES(ch_formatted_query_sequences)
            .set {ch_unique_query_sequences}

        MAKE_QUERY_ALIGNMENT(ch_unique_query_sequences)
            .set {ch_query_alignment}

        MAKE_QUERY_CONSENSUS(ch_query_alignment)
            .set {ch_query_consensus}

        CALCULATE_QUERY_SUBSTITUTION_MODEL(ch_query_alignment)
            .set {ch_query_substitution}

        MAKE_QUERY_PHYLOGENY(ch_query_alignment
                .join(ch_query_substitution.model))
                .set {ch_query_phylogeny}

        if (params.reference) {
            PHYLOGENETIC_PLACEMENT(ch_query_consensus)

            /*
            MAKE_PD_MATRIX(ch_reference_phylogeny)
                .set {ch_reference_pd_matrix}
            
            CALCULATE_MPD(ch_reference_pd_matrix)
                .set {ch_reference_mpd}
            */
        }
}
