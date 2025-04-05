// Default module imports
include { PREPARE_ID as PREPARE_REFERENCE_ID                                    } from '../modules/prepare-id'
include { FIX_FORMAT as FIX_REFERENCE_FORMAT                                    } from '../modules/fix-format'
include { MAKE_ALIGNMENT as MAKE_REFERENCE_ALIGNMENT                            } from '../modules/make-alignment'
include { MAKE_APPENDED_ALIGNMENT                                               } from '../modules/make-appended-alignment'
include { CALCULATE_SUBSTITUTION_MODEL as CALCULATE_APPENDED_SUBSTITUTION_MODEL } from '../modules/calculate-substitution-model'
include { MAKE_PHYLOGENY as MAKE_APPENDED_PHYLOGENY                             } from '../modules/make-phylogeny'

// Module imports for params.reference: 'consensus'
include { MAKE_ALIGNMENT as MAKE_REFERENCE_SUBALIGNMENT                         } from '../modules/make-alignment'
include { MAKE_CONSENSUS as MAKE_REFERENCE_CONSENSUS                            } from '../modules/make-consensus'
include { COMBINE_SEQUENCES as COMBINE_REFERENCE_CONSENSUS                      } from '../modules/combine-sequences'
include { FIX_FORMAT as FIX_REFERENCE_CONSENSUS_FORMAT                          } from '../modules/fix-format'

// Module imports for params.reference: 'ranodom'
include { GET_RANDOM_SEQUENCES as GET_RANDOM_REFERENCES                         } from '../modules/get-random-sequences'
include { COMBINE_SEQUENCES as COMBINE_REFERENCE_SEQUENCES                      } from '../modules/combine-sequences'
include { FIX_FORMAT as FIX_REFERENCE_SEQUENCES_FORMAT                          } from '../modules/fix-format'


workflow PHYLOGENETIC_PLACEMENT {
    take:
        ch_query_consensus

    main:
        Channel.fromPath("${params.data}/${params.reference_dir}/*.fasta")
            .set {ch_reference_fasta}
        
        Channel.fromPath("${params.data}/${params.reference_dir}/*.fas")
            .set {ch_reference_fas}
            
        Channel.fromPath("${params.data}/${params.reference_dir}/*.fna")
            .set {ch_reference_fna}

        Channel.fromPath("${params.data}/${params.reference_dir}/*.fa")
            .set {ch_reference_fa}
            
        ch_reference_fasta
            .mix(ch_reference_fas, ch_reference_fna, ch_reference_fa)
            .set {ch_reference_sequences}

        ch_reference_sequences
            .count()
            .map { reference_sequence_count ->
                if (reference_sequence_count == 0) {
                    error "ERROR: Missing reference sequences in '${params.data}/${params.reference_dir}/'"
                }
            }

        PREPARE_REFERENCE_ID(ch_reference_sequences)
            .set {ch_reference_sequences_with_id}
            
        FIX_REFERENCE_FORMAT(ch_reference_sequences_with_id)
            .set {ch_formatted_reference_sequences}

        ch_final_reference_sequences = Channel.empty()

        if (params.reference == "consensus") {
            MAKE_REFERENCE_SUBALIGNMENT(ch_formatted_reference_sequences)
                .set {ch_reference_subalignments}
                
            MAKE_REFERENCE_CONSENSUS(ch_reference_subalignments)
                .set {ch_reference_consensus}

            Channel.of("combined-reference-consensus")
                .set {ch_combined_reference_consensus_id}

            COMBINE_REFERENCE_CONSENSUS(ch_combined_reference_consensus_id
                .combine(ch_reference_consensus
                    .map {reference_consensus -> reference_consensus[1]}
                    .reduce("") {path_1, path_2 -> "$path_1 $path_2"}))
                .set {ch_combined_reference_consensus}

            FIX_REFERENCE_CONSENSUS_FORMAT(ch_combined_reference_consensus)
                .set {ch_final_reference_sequences}

        } else if (params.reference == "random") {
            GET_RANDOM_REFERENCES(ch_formatted_reference_sequences)
                .set {ch_random_reference_sequences}

            Channel.of("combined-reference-sequences")
                .set {ch_combined_reference_sequences_id}

            COMBINE_REFERENCE_SEQUENCES(ch_combined_reference_sequences_id
                .combine(ch_random_reference_sequences
                    .map {random_sequences -> random_sequences[1]}
                    .reduce("") {path_1, path_2 -> "$path_1 $path_2"}))
                .set {ch_combined_reference_sequences}

            FIX_REFERENCE_SEQUENCES_FORMAT(ch_combined_reference_sequences)
                .set {ch_final_reference_sequences}
        }

        MAKE_REFERENCE_ALIGNMENT(ch_final_reference_sequences)
            .set {ch_reference_alignment}

        Channel.of("appended")
            .set {ch_appended_id}

        MAKE_APPENDED_ALIGNMENT(ch_appended_id
            .combine(ch_reference_alignment
                .map {reference_alignment -> reference_alignment[1]})
            .combine(ch_query_consensus
                .map {query_consensus -> query_consensus[1]}))
            .set {ch_appended_alignment}
            
        CALCULATE_APPENDED_SUBSTITUTION_MODEL(ch_appended_alignment)
            .set {ch_appended_substitution}
            
        MAKE_APPENDED_PHYLOGENY(ch_appended_alignment
            .join(ch_appended_substitution.model))
            .set {ch_appended_phylogeny}
}