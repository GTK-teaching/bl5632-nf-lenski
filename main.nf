#!/usr/bin/env nextflow
/*
  bl5632-lenski

*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { validateParameters; paramsHelp; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'

//include { LENSKI  } from './workflows/lenski'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Run main analysis pipeline depending on type of input
//
workflow GDA_LENSKI {

    take:
        samplesheet // channel: samplesheet read in from --input

    main:

    samplesheet
    .map { meta, fastq_1, fastq_2 -> 
        if (!fastq_2) {
            return [ meta + [ single_end:true ], [ fastq_1 ] ]
        } else {
            return [ meta + [ single_end:false ], [ fastq_1, fastq_2 ] ]
        }
    }
    .view()

    //
    // WORKFLOW: Run pipeline
    //
    //LENSKI (
    //    samplesheet
    //)

}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:

    if (params.help) {
        log.info paramsHelp("nextflow run main.nf --input samplesheet.csv --outdir results")
        exit 0
        }
    // Validate input parameters
    validateParameters()

    // Print summary of supplied parameters
    log.info paramsSummaryLog(workflow)

    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    log.debug "Running initialisation tasks"

    ch_input = Channel.fromList(samplesheetToList(params.input, "assets/schema_input.json"))


    //
    // WORKFLOW: Run main workflow
    //
    GDA_LENSKI (ch_input)
  
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
