// Error checks
params_query = ["all", "all-consensus", "consensus"]
if (!params.query) {
    error "ERROR: Missing query mode (--query_mode) for main workflow"
    
} else if (params.query && !params_query.contains(params.query)) {
    error "ERROR: Invalid query mode (--query_mode) specified for POPULATION_GENETICS workflow"
}

params_reference = ["consensus", "random"]
if (params.reference && !params_reference.contains(params.reference)) {
    error "ERROR: Invalid reference mode (--reference_mode) specified for PHYLOGENETIC_PLACEMENT subworkflow"
}


// Default module imports
include { PREPARE_ID as PREPARE_QUERY_ID                                     } from '../modules/prepare-id'
include { FIX_FORMAT as FIX_QUERY_FORMAT                                     } from '../modules/fix-format'
include { COMBINE_SEQUENCES as COMBINE_QUERY_SEQUENCES                       } from '../modules/combine-sequences'
include { REMOVE_DUPLICATES as REMOVE_QUERY_DUPLICATES                       } from '../modules/remove-duplicates'
include { MAKE_ALIGNMENT as MAKE_QUERY_ALIGNMENT                             } from '../modules/make-alignment'
include { CALCULATE_SUBSTITUTION_MODEL as CALCULATE_QUERY_SUBSTITUTION_MODEL } from '../modules/calculate-substitution-model'
include { MAKE_PHYLOGENY as MAKE_QUERY_PHYLOGENY                             } from '../modules/make-phylogeny'
include { MAKE_CONSENSUS as MAKE_QUERY_CONSENSUS                             } from '../modules/make-consensus'

// Module imports for params.query: 'consensus' or 'all-consensus'
include { MAKE_ALIGNMENT as MAKE_QUERY_SUBALIGNMENT                          } from '../modules/make-alignment'
include { COMBINE_SEQUENCES as COMBINE_QUERY_CONSENSUS                       } from '../modules/combine-sequences'
include { FIX_FORMAT as FIX_QUERY_CONSENSUS_FORMAT                           } from '../modules/fix-format'

// Default subworkflow import
include { PHYLOGENETIC_PLACEMENT } from '../subworkflows/phylogenetic-placement'


workflow POPULATION_GENETICS {
    main:
        Channel.fromPath("${params.data}/*.fasta")
            .set {ch_query_fasta}
            
        Channel.fromPath("${params.data}/*.fas")
            .set {ch_query_fas}

        Channel.fromPath("${params.data}/*.fna")
            .set {ch_query_fna}

        Channel.fromPath("${params.data}/*.fa")
            .set {ch_query_fa}

        ch_query_fasta
            .mix(ch_query_fas, ch_query_fna, ch_query_fa)
            .set {ch_query_sequences}

        ch_query_sequences
            .count()
            .map { query_sequence_count ->
                if (query_sequence_count == 0) {
                    error "ERROR: Missing query sequences in '${params.data}/'"
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
        
        REMOVE_QUERY_DUPLICATES(ch_combined_query_sequences)
            .set {ch_unique_query_sequences}

        MAKE_QUERY_ALIGNMENT(ch_unique_query_sequences)
            .set {ch_query_alignment}

        CALCULATE_QUERY_SUBSTITUTION_MODEL(ch_query_alignment)
            .set {ch_query_substitution}

        MAKE_QUERY_PHYLOGENY(ch_query_alignment
                .join(ch_query_substitution.model))
                .set {ch_query_phylogeny}

        ch_final_query_sequences = Channel.empty()

        if (params.query == "consensus") {
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

        } else if (params.query == "all-consensus") {
            MAKE_QUERY_CONSENSUS(ch_query_alignment)
                .set {ch_query_consensus}

            FIX_QUERY_CONSENSUS_FORMAT(ch_query_consensus)
                .set {ch_final_query_sequences}

        } else if (params.query == "all") {
            ch_combined_query_sequences
                .set {ch_final_query_sequences}
        }

        if (params.reference) {
            PHYLOGENETIC_PLACEMENT(ch_final_query_sequences)
        }
}
