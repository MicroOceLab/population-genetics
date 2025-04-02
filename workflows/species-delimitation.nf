include { PREPARE_ID                                 } from '../modules/prepare-id'
include { FIX_FORMAT                                 } from '../modules/fix-format'
include { MAKE_ALIGNMENT                             } from '../modules/make-alignment'
include { MAKE_CONSENSUS_SEQUENCE                    } from '../modules/make-consensus-sequence'
include { COMBINE_CONSENSUS_SEQUENCES                } from '../modules/combine-consensus-sequences'
include { FIX_FORMAT as FIX_CONSENSUS_FORMAT         } from '../modules/fix-format'
include { MAKE_ALIGNMENT as MAKE_CONSENSUS_ALIGNMENT } from '../modules/make-alignment'
include { CALCULATE_SUBSTITUTION_MODEL               } from '../modules/calculate-substitution-model'
include { MAKE_PHYLOGENY                             } from '../modules/make-phylogeny'
include { MAKE_PD_MATRIX                             } from '../modules/make-pd-matrix'
include { CALCULATE_MPD                              } from '../modules/calculate-mpd'


workflow SPECIES_DELIMITATION {
    main:
        Channel.fromPath('./data/*.fasta')
            .set {ch_reference_fasta}
        
        Channel.fromPath('./data/*.fas')
            .set {ch_reference_fas}
        
        ch_reference_fasta
            .mix(ch_reference_fas)
            .set {ch_reference_sequences}

        PREPARE_ID(ch_reference_sequences)
            .set {ch_reference_sequences_with_id}
        
        FIX_FORMAT(ch_reference_sequences_with_id)
            .set {ch_formatted_reference_sequences}
         
        MAKE_ALIGNMENT(ch_formatted_reference_sequences)
            .set {ch_reference_alignments}
         
        MAKE_CONSENSUS_SEQUENCE(ch_reference_alignments)
            .set {ch_reference_consensus}

        Channel.of("combined-consensus")
            .set {ch_combined_consensus_id}

        COMBINE_CONSENSUS_SEQUENCES(ch_combined_consensus_id
            .combine(ch_reference_consensus.squashed_sequences
            .reduce("") {sequence_1, sequence_2 ->
                "$sequence_1 $sequence_2"}))
            .set {ch_combined_reference_consensus_sequences}

        FIX_CONSENSUS_FORMAT(ch_combined_reference_consensus_sequences)
            .set {ch_formatted_reference_consensus_sequences}
        
        MAKE_CONSENSUS_ALIGNMENT(ch_formatted_reference_consensus_sequences)
            .set {ch_reference_consensus_alignment}
         
        CALCULATE_SUBSTITUTION_MODEL(ch_reference_consensus_alignment)
            .set {ch_reference_substitution}
        
        MAKE_PHYLOGENY(ch_reference_consensus_alignment
            .join(ch_reference_substitution.model))
            .set {ch_reference_phylogeny}
        
        MAKE_PD_MATRIX(ch_reference_phylogeny)
            .set {ch_reference_pd_matrix}
         
        CALCULATE_MPD(ch_reference_pd_matrix)
            .set {ch_reference_mpd}
        
}
