# Input-data integrity

## Provenance record

Record the publication DOI, BioProject/study accession, BioSample and run accession,
download URL, repository checksum, sequencing layout, amplicon target, primer source,
metadata source, subset criteria and every identifier transformation.

Selecting a documented subset is acceptable when the selection rule is explicit.
Do not describe a subset as reproduction of the complete study.

## Metadata

- Copy values from the repository or publication; do not create convenient groups.
- Retain confounders and design variables such as batch, subject, litter, sex and
  time point when available.
- The nf-core metadata first column must match the pipeline-facing sample ID.
- Keep an `original_sample_id` column after reversible normalization.
- Do not run group comparisons when the subset lacks replication or has known
  confounding without stating the limitation.

## Primers

Obtain primer sequences from the study methods or author workflow, then inspect raw
reads for compatible leading sequences. Degenerate bases must be interpreted using
IUPAC codes. Use primer trimming only when primers remain; use the pipeline's explicit
skip option only when the distributed files were already trimmed, and document why.

## Downloads

Download on an authorized compute node when transfer may exceed login-node limits.
Use HTTPS, resumable partial files and repository-provided checksums. Do not silently
replace an existing file that fails checksum; stop and preserve it for diagnosis.
