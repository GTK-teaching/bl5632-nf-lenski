
# Design principles

- Built up bit by bit.
- Utilise nextflow training best practices.
- Initially start with a few files on local directory, move to AWS batch.
- Document and tag every step

# The skeleton

- Let's start with a template that get stuff from, but it not exactly the same as, an nf-core template.
  - In particular, I'd like to use a few of the base configuration files in nf-core, so we can direct different resources to different processes depending on the labels.

# TAG: 00-Skeleton

- This should run with `nextflow run main.nf -profile awsbatch --input data/samplesheet.csv`
- The result should be just the channel containing the example files


## Fastqc and trimming.

Decided to see if a FASTQC_TRIMGALORE subworkflow (from cutandrun) would work.

This seems to work, and makes for another good tag point.

## tag 01-TrimGalore

If you check out this tag you should be able to run with `nextflow run main.nf -profile awsbatch --input data/samplesheet.csv``
- This version should place the trimmed results and fastqc results into the outdir.
- This version records software versions.