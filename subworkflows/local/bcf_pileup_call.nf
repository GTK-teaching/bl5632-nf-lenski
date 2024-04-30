
include { BCFTOOLS_MPILEUP } from '../../modules/local/bcftools/mpileup/main'


workflow BCF_PILEUP_CALL {
    take:
    sorted_bam
    fasta



    main:

    log.info(params.save_mpileup)
    ch_versions      = Channel.empty()

    BCFTOOLS_MPILEUP(
        sorted_bam,
        fasta
    )


    ch_versions  = ch_versions.mix(BCFTOOLS_MPILEUP.out.versions)

    emit:
    vcf         = BCFTOOLS_MPILEUP.out.vcf
    mpileup     = BCFTOOLS_MPILEUP.out.mpileup //optional: true
    versions    = ch_versions                 // channel: [ versions.yml ]

}
