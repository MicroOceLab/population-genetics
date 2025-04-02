params_reference = ["consensus", "random"]
if (params.reference && !params_reference.contains(params.reference)) {
    error "ERROR: Invalid reference phylogeny mode (--reference) specified"
}


include { PREPARE_ID as PREPARE_QUERY_ID                                     } from '../modules/prepare-id'
include { FIX_FORMAT as FIX_QUERY_FORMAT                                     } from '../modules/fix-format'
include { REMOVE_DUPLICATES as REMOVE_QUERY_DUPLICATES                       } from '../modules/remove-duplicates'
include { MAKE_ALIGNMENT as MAKE_QUERY_ALIGNMENT                             } from '../modules/make-alignment'
include { MAKE_CONSENSUS as MAKE_QUERY_CONSENSUS                             } from '../modules/make-consensus'
include { CALCULATE_SUBSTITUTION_MODEL as CALCULATE_QUERY_SUBSTITUTION_MODEL } from '../modules/calculate-substitution-model'
include { MAKE_PHYLOGENY as MAKE_QUERY_PHYLOGENY                             } from '../modules/make-phylogeny'

include { PREPARE_ID as PREPARE_REFERENCE_ID                                     } from '../modules/prepare-id'
include { FIX_FORMAT as FIX_REFERENCE_FORMAT                                     } from '../modules/fix-format'
include { REMOVE_DUPLICATES as REMOVE_REFERENCE_DUPLICATES                       } from '../modules/remove-duplicates'
include { MAKE_ALIGNMENT as MAKE_INITIAL_REFERENCE_ALIGNMENT                     } from '../modules/make-alignment'
include { MAKE_CONSENSUS as MAKE_REFERENCE_CONSENSUS                             } from '../modules/make-consensus'
include { COMBINE_SEQUENCES as COMBINE_REFERENCE_CONSENSUS                       } from '../modules/combine-sequences'
include { FIX_FORMAT as FIX_REFERENCE_CONSENSUS_FORMAT                           } from '../modules/fix-format'
include { MAKE_ALIGNMENT as MAKE_REFERENCE_ALIGNMENT                             } from '../modules/make-alignment'
include { CALCULATE_SUBSTITUTION_MODEL as CALCULATE_REFERENCE_SUBSTITUTION_MODEL } from '../modules/calculate-substitution-model'
include { MAKE_PHYLOGENY as MAKE_REFERENCE_PHYLOGENY                             } from '../modules/make-phylogeny'

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
            Channel.fromPath('./data/reference/*.fasta')
                .set {ch_reference_fasta}
            
            Channel.fromPath('./data/reference/*.fas')
                .set {ch_reference_fas}

            Channel.fromPath('./data/reference/*.fna')
                .set {ch_reference_fna}

            Channel.fromPath('./data/reference/*.fa')
                .set {ch_reference_fa}
            
            ch_reference_fasta
                .mix(ch_reference_fas, ch_reference_fna, ch_reference_fa)
                .set {ch_reference_sequences}

            ch_reference_sequences
                .count()
                .map { reference_sequence_count ->
                    if (reference_sequence_count == 0) {
                        error "ERROR: Missing reference sequences in './data/reference/'"
                    }
                }

            PREPARE_REFERENCE_ID(ch_reference_sequences)
                .set {ch_reference_sequences_with_id}
            
            FIX_REFERENCE_FORMAT(ch_reference_sequences_with_id)
                .set {ch_formatted_reference_sequences}
            
            REMOVE_REFERENCE_DUPLICATES(ch_formatted_reference_sequences)
                .set {ch_unique_reference_sequences}

            ch_final_reference_sequences = Channel.empty()

            if (params.reference == "consensus") {
                MAKE_INITIAL_REFERENCE_ALIGNMENT(ch_unique_reference_sequences)
                    .set {ch_initial_reference_alignments}
                
                MAKE_REFERENCE_CONSENSUS(ch_initial_reference_alignments)
                    .set {ch_reference_consensus}

                Channel.of("combined-consensus")
                    .set {ch_combined_consensus_id}

                COMBINE_REFERENCE_CONSENSUS(ch_combined_consensus_id
                    .combine(ch_reference_consensus.squashed_sequences
                    .reduce("") {sequence_1, sequence_2 ->
                        "$sequence_1 $sequence_2"}))
                    .set {ch_combined_reference_consensus}

                FIX_REFERENCE_CONSENSUS_FORMAT(ch_combined_reference_consensus)
                    .set {ch_final_reference_sequences}
            }

            MAKE_REFERENCE_ALIGNMENT(ch_final_reference_sequences)
                .set {ch_reference_alignment}
            
            CALCULATE_REFERENCE_SUBSTITUTION_MODEL(ch_reference_alignment)
                .set {ch_reference_substitution}
            
            MAKE_REFERENCE_PHYLOGENY(ch_reference_alignment
                .join(ch_reference_substitution.model))
                .set {ch_reference_phylogeny}
            
            /*
            MAKE_PD_MATRIX(ch_reference_phylogeny)
                .set {ch_reference_pd_matrix}
            
            CALCULATE_MPD(ch_reference_pd_matrix)
                .set {ch_reference_mpd}
            */
        }
}
