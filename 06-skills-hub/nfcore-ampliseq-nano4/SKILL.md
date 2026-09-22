---
name: nfcore-ampliseq-nano4
description: Prepare, run, validate, and review nf-core/ampliseq workflows on NCHC Nano4 with research-data provenance, Slurm execution, shared Singularity caches, fixed pipeline/database versions, and guarded job submission. Use for real or test amplicon runs on Nano4; do not use to invent biological metadata or infer undocumented primers.
---

# nf-core/ampliseq on Nano4

Produce a reproducible run without changing the study design or hiding HPC decisions.

## Required workflow

1. Identify the exact pipeline release, source accessions, sequencing layout,
   metadata source, primer source and taxonomy release.
2. Inspect the actual FASTQ starts before deciding whether primers remain. Do not
   copy primers from an nf-core example into an unrelated dataset.
3. Preserve original sample identifiers. If nf-core naming rules require a
   reversible normalization, record both normalized and original IDs.
4. Keep FASTQ, `work/`, taxonomy and container caches under `/work/${USER}`.
5. Read [references/data-integrity.md](references/data-integrity.md) when preparing
   or changing input data.
6. Use the `nano4-slurm-operations` skill for live account/partition discovery and
   preflight. Never hardcode a user's project ID into a tracked template.
7. Run the release-matched nf-core test profile before real data. A test-profile
   success proves infrastructure compatibility, not biological validity.
8. Run the Nextflow driver in a small Slurm allocation and set the pipeline process
   executor to Slurm. A container profile alone does not select Slurm.
9. Show the exact account, partition, scripts and resource request and obtain user
   authorization before `sbatch`. Report the returned job ID once; do not poll.
10. Prefer `-resume` after diagnosis. Never delete work or results merely to retry.
11. Read [references/result-review.md](references/result-review.md) when checking a
    completed run or interpreting outputs.

## Version-sensitive parameters

Read the schema/docs for the pinned release. nf-core/ampliseq 2.18.0 uses
`--FW_primer` and `--RV_primer`; later development documentation may use different
names. Pin a taxonomy value such as `silva=138.2` instead of relying on a moving
default.

## Validation helper

Run `scripts/validate_course_inputs.sh <work-root> <manifest.tsv>` after download.
It checks sample mappings, paired files, gzip integrity and ENA MD5 values without
modifying data.
