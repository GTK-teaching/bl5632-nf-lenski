
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
