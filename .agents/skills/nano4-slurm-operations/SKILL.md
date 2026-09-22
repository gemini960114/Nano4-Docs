---
name: nano4-slurm-operations
description: Operate Slurm safely on the NCHC Nano4 cluster, including wallet balance checks, project/account authorization, partition discovery and compatibility, CPU/GPU resource selection, sbatch submission, squeue/sacct status inspection, and non-polling monitoring. Use for any Nano4 job preparation, submission, diagnosis, cancellation, project selection, partition choice, or questions involving GOV115088, ngs partitions, or general GPU projects.
---

# Nano4 Slurm Operations

Perform live discovery before relying on documented values. Nano4 project balances,
associations, partitions, limits, and Allow/DenyAccounts can change.

## Preflight

1. Confirm the login host matches `25a-lgn*` and Slurm reports cluster `hpc`.
2. Run the bundled read-only preflight:

   ```bash
   bash .agents/skills/nano4-slurm-operations/scripts/slurm-preflight.sh \
     --project "<PROJECT_ID>" \
     --partition "<PARTITION>"
   ```

3. Stop before submission if the script reports an account, policy, association, or
   partition error.
4. If working outside this repository, resolve the installed skill directory first
   and run the same script from that location.

Read [references/accounts-and-partitions.md](references/accounts-and-partitions.md)
when selecting an account or partition. Read
[references/commands.md](references/commands.md) for exact Nano4 commands and job
lifecycle operations.

## Account and Partition Selection

- Treat `GOV115088` as the dedicated biomedical allocation. Use it only with a live
  `ngs*` partition that explicitly allows the account.
- Do not use `GOV115088` on standard GPU partitions. Select an active general
  project from `wallet`, then verify the target partition's account policy.
- Do not assume every general project can use every GPU or special-purpose
  partition. Inspect `AllowAccounts`, `DenyAccounts`, QoS, time, and resources.
- Do not reject `GOV115088` solely because `wallet GOV115088` says the NANO4 service
  is not enabled. This special NGS allocation must instead pass both Slurm
  association and partition-policy checks.
- Never place a personal project ID in a version-controlled `#SBATCH --account`
  directive. Supply it at submission:

  ```bash
  sbatch --account="<PROJECT_ID>" job.slurm
  ```

## Resource Selection

- Match requested CPU, memory, GPU count/type, and walltime to the live partition
  information.
- Request GPUs explicitly on GPU partitions with the appropriate `--gpus` or
  `--gres` option. Do not send CPU-only work to expensive GPU partitions without a
  justified reason.
- Use NGS partitions for biomedical CPU/high-memory workloads when the selected
  account is allowed.
- Always set a finite `#SBATCH --time` unless a repository rule provides a
  justified alternative.
- Ensure the Slurm output directory exists before calling `sbatch`; Slurm opens
  output files before running the script body.

## Submission Safety

Before submission:

1. Resolve the exact job script, working directory, inputs, outputs, account,
   partition, and resource request.
2. Run `bash -n` for Bash job scripts.
3. Confirm the job script fails fast with `set -euo pipefail`.
4. Confirm the command performs no download on a compute node when the workflow
   requires offline assets.
5. Require the user's project choice when multiple active general projects are
   valid; do not choose which budget to charge without authorization.

After submission, report the job ID immediately. Take one `squeue`/`sacct` snapshot
and use a product scheduling or background-monitoring mechanism when available.
Never occupy the session with a continuous `sleep` polling loop.

## Status, Failure, and Cancellation

- Use `squeue` for queued/running state and `sacct` for terminal state, exit code,
  elapsed time, and resource accounting.
- Inspect the Slurm output/error files and application logs before resubmitting.
- Prefer workflow-native resume capabilities when available.
- Treat `scancel` as a state-changing action. Resolve the exact job ID and obtain
  user authorization unless cancellation was explicitly requested.
- Never delete work directories, results, or logs merely to retry a job.
