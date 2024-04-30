#!/usr/bin/env bash

nextflow run main.nf \
    --input data/s3-samplesheet.csv \
    --outdir s3://bl5632/group00/results/ \
    --fasta data/genome/ecoli_rel606.fasta \
    -work-dir s3://bl5632/group00/work/ \
    --awsqueue gtk-lab-main-batch-test \
    --awsregion ap-southeast-1 \
    -profile awsbatch -resume

