#!/usr/bin/env bash
GROUP="group00"

nextflow run main.nf \
    --input data/s3-samplesheet.csv \
    --outdir s3://bl5632/${GROUP}/results/ \
    --fasta data/genome/ecoli_rel606.fasta \
    -work-dir s3://bl5632/${GROUP}/work/ \
    --awsqueue gtk-lab-main-batch-test \
    --awsregion ap-southeast-1 \
    -profile awsbatch -resume

