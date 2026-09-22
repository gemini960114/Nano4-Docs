# AI review prompt

Review the manual and AI-generated nf-core/ampliseq runs without changing or
deleting either run.

Check:

- dataset accession, MD5 and FASTQ pairing;
- reversible sample-ID mapping;
- metadata values and group provenance;
- primer sequences and actual primer presence in reads;
- pipeline and taxonomy versions;
- Slurm executor, account/partition propagation and resource limits;
- `/work/${USER}` cache/work placement;
- test-profile success before the real run;
- MultiQC, Cutadapt, DADA2, taxonomy and diversity outputs;
- `sacct` and `seff` resource efficiency.

Produce a concise comparison report. Separate workflow correctness from
biological interpretation, and do not claim that this six-sample subset
reproduces the full paper.
