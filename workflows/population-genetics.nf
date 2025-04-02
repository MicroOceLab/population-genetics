params_reference = ["consensus", "random"]
if (params.reference && !params_reference.contains(params.reference)) {
    error "ERROR: Invalid reference phylogeny mode (--reference) specified"
}

include { PREPARE_ID as PREPARE_REFERENCE_ID                                     } from '../modules/prepare-id'
include { FIX_FORMAT as FIX_REFERENCE_FORMAT                                     } from '../modules/fix-format'
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
        if (params.reference) {
            Channel.fromPath('./data/reference/*.fasta')
                .set {ch_reference_fasta}
            
            Channel.fromPath('./data/reference/*.fas')
                .set {ch_reference_fas}
            
            ch_reference_fasta
                .mix(ch_reference_fas)
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

            ch_final_reference_sequences = Channel.empty()

            if (params.reference == "consensus") {
                MAKE_INITIAL_REFERENCE_ALIGNMENT(ch_formatted_reference_sequences)
                    .set {ch_reference_alignments}
                
                MAKE_REFERENCE_CONSENSUS(ch_reference_alignments)
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
                .set {ch_reference_consensus_alignment}
            
            CALCULATE_REFERENCE_SUBSTITUTION_MODEL(ch_reference_consensus_alignment)
                .set {ch_reference_substitution}
            
            MAKE_REFERENCE_PHYLOGENY(ch_reference_consensus_alignment
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
