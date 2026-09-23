# AI reproduction prompt

Use the installed `nfcore-ampliseq-nano4`, `nano4-slurm-operations`, and
`slurm-job-advisor` skills.

Reproduce the manual nf-core/ampliseq course run in a separate directory. Read
`metadata/study_notes.md`, `metadata/course_subset.tsv`, and
`data/ena_manifest.tsv` first.

Constraints:

1. Preserve the ENA FASTQ files, BioSample/run accessions, author treatment,
   litter, dam, sex and original sample IDs.
2. Do not invent control/treatment labels or infer a primer from an example.
3. Pin nf-core/ampliseq to 2.18.0 and taxonomy to `silva=138.2`.
4. Store data, work directories, taxonomy and container caches under
   `/work/${USER}`.
5. Use Slurm for the Nextflow driver and all pipeline processes. Use the NCHC
   offline package (`module load biology/nf-core-ampliseq/2.18.0`) and the course
   project `GOV115088`, whose only NGS CPU partition is `ngs62g`; every Slurm job
   (the Nextflow driver and every pipeline process) must request exactly
   `-c 8 --mem=62G` on that partition, the fixed official pairing; do not
   reduce it. Do not request GPUs.
6. Run the official test profile before the real dataset.
7. Perform live account/partition preflight, then show the proposed commands.
8. Do not submit any job until I explicitly approve the exact account,
   partition, scripts and resource requests.

After approval, report each job ID once. Do not use a polling loop. When the run
finishes, compare the AI-generated config, samplesheet and parameters with the
manual version and explain every material difference.
