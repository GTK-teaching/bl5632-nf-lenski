
def prepare_tool_indices = ["bowtie2"]


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { paramsSummaryMap       } from 'plugin/nf-schema'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nf_lenski_pipeline'
include { FASTQC_TRIMGALORE      } from '../subworkflows/local/fastqc_trimgalore'
include { PREPARE_GENOME         } from '../subworkflows/local/prepare_genome'
include { BOWTIE2_ALIGN          } from "../modules/nf-core/bowtie2/align/main"
include { BAM_SORT_STATS_SAMTOOLS  } from '../subworkflows/nf-core/bam_sort_stats_samtools/main'
include { BCF_PILEUP_CALL        } from '../subworkflows/local/bcf_pileup_call'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow LENSKI {

    // init

    ch_software_versions = Channel.empty()

    take:
    ch_samplesheet // channel: samplesheet read in from --input

    main:

    ch_multiqc_files = Channel.empty()
    ch_fasta = Channel.from(file(params.fasta)).map { row -> [[id:"fasta"], row] }

/* Read in samplesheet */
    ch_samplesheet
        .map { 
            meta, fastq_1, fastq_2 ->
                if (!fastq_2) {
                    return [ meta + [ single_end:true], [fastq_1] ]
                } else { 
                    return [ meta + [ single_end:false], [fastq_1, fastq_2 ] ]
                }
        }
        .set { ch_fastq }

    PREPARE_GENOME(prepare_tool_indices)
    ch_software_versions = ch_software_versions.mix(PREPARE_GENOME.out.versions)
    ch_fasta = PREPARE_GENOME.out.fasta.first()
    ch_bt2_index = PREPARE_GENOME.out.bowtie2_index.first()
    ch_fasta_index = PREPARE_GENOME.out.fasta_index  
    
    ch_trimmed_reads = Channel.empty()

    if((!params.skip_fastqc) || (!params.skip_trimming)) {
        FASTQC_TRIMGALORE (
            ch_fastq,
            params.skip_fastqc,
            params.skip_trimming
        )
        ch_trimmed_reads     = FASTQC_TRIMGALORE.out.reads
        ch_software_versions = ch_software_versions.mix(FASTQC_TRIMGALORE.out.versions)
    }


BOWTIE2_ALIGN(
    ch_trimmed_reads,
    ch_bt2_index,
    ch_fasta,
    false,
    false)

ch_software_versions = ch_software_versions.mix(BOWTIE2_ALIGN.out.versions)

BAM_SORT_STATS_SAMTOOLS(
    BOWTIE2_ALIGN.out.bam,
    ch_fasta)

ch_software_versions = ch_software_versions.mix(BAM_SORT_STATS_SAMTOOLS.out.versions)
ch_sorted_bam = BAM_SORT_STATS_SAMTOOLS.out.bam

BCF_PILEUP_CALL(
    ch_sorted_bam,
    ch_fasta)
    
ch_software_versions = ch_software_versions.mix(BCF_PILEUP_CALL.out.versions)




    
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_software_versions)
        .collectFile(storeDir: "${params.outdir}/pipeline_info", name: 'nf_core_pipeline_software_mqc_versions.yml', sort: true, newLine: true)
        .set { ch_collated_versions }

 
    emit:
    versions       = ch_software_versions                 // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
