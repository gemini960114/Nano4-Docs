# Nano4 Slurm Commands

## Project and Balance

List active wallet projects:

```bash
wallet
```

Inspect one general project:

```bash
wallet "<PROJECT_ID>"
```

The local `wallet` command does not implement conventional `--help`; do not use
`wallet --help` as a capability test.

Inspect the current user's Slurm association for one account:

```bash
sacctmgr -nP show assoc user="$USER" account="<project-id-lowercase>" \
  format=Account,Partition,QOS,DefaultQOS
```

## Partition Discovery

List current partitions and resources:

```bash
sinfo -h -o '%P|%a|%l|%D|%c|%m|%G'
```

Inspect an exact partition policy:

```bash
scontrol show partition "<PARTITION>"
```

Never parse only the partition name. Inspect account allow/deny rules and resource
limits from the full record.

## Submission

Create `logs/` before submitting when the script writes there:

```bash
mkdir -p logs
sbatch --account="<PROJECT_ID>" path/to/job.slurm
```

Capture the returned job ID. Do not add the user's project ID to a tracked Slurm
script.

## Queue and Accounting

Current jobs:

```bash
squeue -u "$USER" -o '%.18i %.12P %.28j %.10T %.10M %.10l %.6D %R'
```

One job:

```bash
squeue -j "<JOB_ID>"
```

Completed or failed job:

```bash
sacct -j "<JOB_ID>" --format=JobID,JobName%30,Account,Partition,State,ExitCode,Elapsed,Timelimit,AllocCPUS,ReqMem,MaxRSS
```

## Cancellation

After resolving the exact target and receiving authorization:

```bash
scancel "<JOB_ID>"
```

Cancellation does not remove job outputs or workflow work directories.
