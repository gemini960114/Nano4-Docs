# Result review

Review outputs in this order:

1. `pipeline_info`: release, command, parameters, software and failed processes.
2. `multiqc`: raw-read QC and cross-sample anomalies.
3. `cutadapt`: primer detection and retained reads.
4. `dada2`: filtered, denoised, merged, non-chimeric reads and ASVs.
5. taxonomy and abundance tables: database identity and assignments.
6. QIIME2 diversity: rarefaction depth, exclusions, alpha/beta metrics and PCoA.
7. `sacct`/`seff`: state, exit code, elapsed time, requested memory and MaxRSS.

Do not equate workflow completion with biological validity. Do not infer significance
from visible PCoA separation. State sample-size, study-design, rarefaction, taxonomy
resolution and compositional-data limitations near any interpretation.
