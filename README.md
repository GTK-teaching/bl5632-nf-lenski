
# Design principles

- Built up bit by bit.
- Utilise nextflow training best practices.
- Initially start with a few files on local directory, move to AWS batch.
- Document and tag every step

# The skeleton

- Let's start with a template that get stuff from, but it not exactly the same as, an nf-core template.
  - In particular, I'd like to use a few of the base configuration files in nf-core, so we can direct different resources to different processes depending on the labels.

# TAG: 00-Skeleton

- This should run with `nextflow run main.nf --input data/samplesheet.csv --outdir results`
- The result should be just the channel containing the example files


## Fastqc and trimming.

Decided to see if a FASTQC_TRIMGALORE subworkflow (from cutandrun) would work.

This seems to work, and makes for another good tag point.

# TAG: 01-TrimGalore

If you check out this tag you should be able to run with `nextflow run main.nf --input data/samplesheet.csv --outdir results`
- This version should place the trimmed results and fastqc results into the outdir.
- This version records software versions.

# TAG: 02-Bowtie2_index

I still needed to build the genome index (both botwie2 and faidx, so I cobbled together a PREPARE_GENOME subworkflow based on one of the nf-core pipelines.  Not sure why the bowtie2/build module from nf-core uses process-high, so I changed it to process-medium.

Should be runnable with 

    nextflow run main.nf --input data/samplesheet.csv --outdir results/ --fasta data/genome/ecoli_rel606.fasta

# TAG: 03-bowtie

This runs bowtie and samtools. It took a bit of work to realise that the bowtie index needed to be a value Channel, not a queue channel, so I could re-use it.

Should be runnable with 

    nextflow run main.nf --input data/samplesheet.csv --outdir results/ --fasta data/genome/ecoli_rel606.fasta

# Tag: 04-bcftools

