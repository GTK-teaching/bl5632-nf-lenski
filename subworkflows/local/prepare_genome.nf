/*
 * Uncompress and prepare reference genome files
*/

include { BOWTIE2_BUILD                                        } from '../../modules/local/bowtie2/build/main'
include { SAMTOOLS_FAIDX                                       } from '../../modules/nf-core/samtools/faidx/main'

workflow PREPARE_GENOME {
    take:
    prepare_tool_indices // list: tools to prepare indices for


    main:
    ch_versions      = Channel.empty()


    ch_fasta = Channel.from( file(params.fasta) ).map { row -> [[id:"fasta"], row] }

    /*    
    * Index genome fasta file
    */
    ch_fasta_index = SAMTOOLS_FAIDX ( ch_fasta, [[id:"fasta"], []] ).fai
    ch_versions    = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)

    
        /*
    * Uncompress Bowtie2 index or generate from scratch if required for both genomes
    */
    ch_bt2_index         = Channel.empty()
    ch_bt2_versions      = Channel.empty()
    
    if ("bowtie2" in prepare_tool_indices) {
        ch_bt2_index = BOWTIE2_BUILD ( ch_fasta ).index.map{ row -> [ [id:"target_index"], row[1] ] }
        ch_versions  = ch_versions.mix(BOWTIE2_BUILD.out.versions)
    }

    
    emit:
    fasta                  = ch_fasta                    // path: genome.fasta
    fasta_index            = ch_fasta_index              // path: genome.fai
    bowtie2_index          = ch_bt2_index                // path: bt2/index/
    
    versions               = ch_versions                 // channel: [ versions.yml ]
}
