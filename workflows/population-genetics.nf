// Error checks
params_query_modes = ["all", "all-consensus", "consensus"]
if (!params.query_mode) {
    error "ERROR: Missing query mode (--query_mode) for main workflow"
    
} else if (params.query_mode && !params_query_modes.contains(params.query_mode)) {
    error "ERROR: Invalid query mode (--query_mode) specified for POPULATION_GENETICS workflow"
}

params_reference_modes = ["consensus", "random", "all"]
if (params.reference_mode && !params_reference_modes.contains(params.reference_mode)) {
    error "ERROR: Invalid reference mode (--reference_mode) specified for PHYLOGENETIC_PLACEMENT subworkflow"
}


// Default module imports
include { PREPARE_ID as PREPARE_QUERY_ID                                     } from '../modules/prepare-id'
include { FIX_FORMAT as FIX_QUERY_FORMAT                                     } from '../modules/fix-format'
include { COMBINE_SEQUENCES as COMBINE_QUERY_SEQUENCES                       } from '../modules/combine-sequences'
include { MAKE_ALIGNMENT as MAKE_QUERY_ALIGNMENT                             } from '../modules/make-alignment'
include { GET_POLYMORPHIC_SITES                                              } from '../modules/get-polymorphic-sites'
include { GET_HAPLOTYPE_DATA                                                 } from '../modules/get-haplotype-data'
include { FIX_FORMAT as FIX_HAPLOTYPE_FORMAT                                 } from '../modules/fix-format'
include { CALCULATE_SUBSTITUTION_MODEL as CALCULATE_QUERY_SUBSTITUTION_MODEL } from '../modules/calculate-substitution-model'
include { MAKE_PHYLOGENY as MAKE_QUERY_PHYLOGENY                             } from '../modules/make-phylogeny'
include { MAKE_CONSENSUS as MAKE_QUERY_CONSENSUS                             } from '../modules/make-consensus'

// Module imports for params.query_mode: 'consensus' or 'all-consensus'
include { MAKE_ALIGNMENT as MAKE_QUERY_SUBALIGNMENT                          } from '../modules/make-alignment'
include { COMBINE_SEQUENCES as COMBINE_QUERY_CONSENSUS                       } from '../modules/combine-sequences'
include { FIX_FORMAT as FIX_QUERY_CONSENSUS_FORMAT                           } from '../modules/fix-format'

// Default subworkflow import
include { PHYLOGENETIC_PLACEMENT } from '../subworkflows/phylogenetic-placement'


workflow POPULATION_GENETICS {
    main:
        Channel.fromPath("${params.data}/${params.query_dir}/*.fasta")
            .set {ch_query_fasta}
            
        Channel.fromPath("${params.data}/${params.query_dir}/*.fas")
            .set {ch_query_fas}

        Channel.fromPath("${params.data}/${params.query_dir}/*.fna")
            .set {ch_query_fna}

        Channel.fromPath("${params.data}/${params.query_dir}/*.fa")
            .set {ch_query_fa}

        ch_query_fasta
            .mix(ch_query_fas, ch_query_fna, ch_query_fa)
            .set {ch_query_sequences}

        ch_query_sequences
            .count()
            .map { query_sequence_count ->
                if (query_sequence_count == 0) {
                    error "ERROR: Missing query sequences in '${params.data}/${params.query_dir}/'"
                }
            }

        PREPARE_QUERY_ID(ch_query_sequences)
            .set {ch_query_sequences_with_id}

        FIX_QUERY_FORMAT(ch_query_sequences_with_id)
            .set {ch_formatted_query_sequences}

        Channel.of("combined-query")
            .set {ch_combined_query_id}

        COMBINE_QUERY_SEQUENCES(ch_combined_query_id
            .combine(ch_formatted_query_sequences
                .map {query_sequences -> query_sequences[1]}
                .reduce("") {path_1, path_2 -> "$path_1 $path_2"}))
            .set {ch_combined_query_sequences}

        MAKE_QUERY_ALIGNMENT(ch_combined_query_sequences)
            .set {ch_query_alignment}

        GET_POLYMORPHIC_SITES(ch_query_alignment)
            .set {ch_polymorphic_sites}
        
        GET_HAPLOTYPE_DATA(ch_query_alignment)
            .set {ch_haplotype}

        FIX_HAPLOTYPE_FORMAT(ch_haplotype.sequences)
            .set {ch_formattedd_haplotype_sequences}

        CALCULATE_QUERY_SUBSTITUTION_MODEL(ch_query_alignment)
            .set {ch_query_substitution}

        MAKE_QUERY_PHYLOGENY(ch_query_alignment
                .join(ch_query_substitution.model))
                .set {ch_query_phylogeny}

        ch_final_query_sequences = Channel.empty()

        if (params.query_mode == "consensus") {
            MAKE_QUERY_SUBALIGNMENT(ch_formatted_query_sequences)
                .set {ch_query_subalignments}

            MAKE_QUERY_CONSENSUS(ch_query_subalignments)
                .set {ch_query_consensus}

            Channel.of("combined-query-consensus")
                .set {ch_combined_query_consensus_id}

            COMBINE_QUERY_CONSENSUS(ch_combined_query_consensus_id
                .combine(ch_query_consensus
                    .map {query_consensus -> query_consensus[1]}
                    .reduce("") {path_1, path_2 -> "$path_1 $path_2"}))
                .set {ch_combined_query_consensus}
            
            FIX_QUERY_CONSENSUS_FORMAT(ch_combined_query_consensus)
                .set {ch_final_query_sequences}

        } else if (params.query_mode == "all-consensus") {
            MAKE_QUERY_CONSENSUS(ch_query_alignment)
                .set {ch_query_consensus}

            FIX_QUERY_CONSENSUS_FORMAT(ch_query_consensus)
                .set {ch_final_query_sequences}

        } else if (params.query_mode == "all") {
            ch_combined_query_sequences
                .set {ch_final_query_sequences}
        }

        if (params.reference_mode) {
            PHYLOGENETIC_PLACEMENT(ch_final_query_sequences)
        }
}
