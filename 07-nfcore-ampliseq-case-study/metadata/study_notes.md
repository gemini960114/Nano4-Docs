# Dataset provenance

- Study: *Early life stress in mice alters gut microbiota independent of maternal microbiota inheritance*
- Paper: <https://doi.org/10.1152/ajpregu.00072.2020>
- BioProject: [PRJNA605008](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA605008/)
- Author analysis repository: <https://github.com/KMKemp/ELS>
- Author metadata: <https://raw.githubusercontent.com/KMKemp/ELS/main/mapping_file.txt>
- Sequencing: Illumina MiSeq paired-end 250 bp, 16S rRNA V4
- Forward primer 515F: `GTGYCAGCMGCCGCGGTAA`
- Reverse primer 806R: `GGACTACNVGGGTWTCTAAT`

## Course subset

The complete study contains more samples than are suitable for a classroom run. This
course uses six unchanged ENA runs selected from the author metadata with all of the
following held constant:

- `EXP = exp1`
- `PD = PD10`
- `SEX = MALE`
- three author-defined `Control` samples and three author-defined `MSEW` samples
- one sample from each of three different litters in each treatment

The selection reduces download and compute time. It does **not** reproduce the full
study and must not be used to claim that the published biological conclusions were
replicated.

## Sample identifier normalization

nf-core/ampliseq 2.18.0 restricts sample identifiers to ASCII letters, numbers and
underscores. The author IDs contain hyphens, so the pipeline-facing ID uses the only
necessary reversible normalization:

```text
C-L1-03 -> C_L1_03
```

`course_subset.tsv` retains both `ID` and `original_sample_id`. Treatment, litter,
dam, sex, BioSample and run accession are copied from the public records; no teaching
groups were invented.
