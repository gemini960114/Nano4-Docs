# Nano4 Accounts and Partitions

Last verified on Nano4 login host `25a-lgn02`: 2026-07-29.

Live scheduler output overrides this reference.

## Account Sources

Nano4 exposes two different views:

- `wallet`: currently active Nano4 projects and SU balances.
- `sacctmgr show assoc`: Slurm associations, including historical or special
  accounts that might not appear as active wallet projects.

Do not treat an association as proof of an active balance.

## Course Allocation: GOV115088

- Account: `GOV115088` (國網生技醫藥高效能運算推廣與應用計畫)
- Purpose: biomedical HPC training and outreach; the course is CPU-only
- NGS CPU partition: **`ngs62g` only** (per job: 8 CPU, 62 GB, 4 days)

Observed behavior (verified 2026-09-23 with `scontrol` and `sbatch --test-only`):

- `wallet GOV115088` lists the project with an active SU balance.
- Among NGS partitions, only `ngs62g` lists `gov115088` in `AllowAccounts`.
  `ngstest`, `ngsconsole`, `ngs8g`-`ngs32g`, `ngs125g`-`ngs1000g`,
  `ngs248c`/`ngs496c`, `ngscourse*`, `ngs1500g`-`ngs6t` and `ngs1gpu`-`ngs8gpu`
  are restricted to `mst109178` and `ent109430`.
- The association also accepts the general GPU partitions `dev` and `gb200-dev`,
  but course jobs must not request GPUs.

## Biomedical Platform Allocations: MST109178, ENT109430

- Allowed on every `ngs*` partition, including `ngstest`, the fat-memory
  `ngs1500g`-`ngs6t`, and the 14-day `ngs1gpu`-`ngs8gpu` queues.
- Listed in `DenyAccounts` of the general GPU partitions such as `dev` and `8gpus`.

Always validate an account through both the Slurm association and the selected
partition's current `AllowAccounts` / `DenyAccounts`. `sbatch --test-only` confirms
the account/partition combination but does **not** enforce QoS limits such as
`MaxTRESPerJob`; compare CPU and memory requests with `sacctmgr show qos p_<partition>`.

## General Projects and GPU Partitions

Select a general project from the current `wallet` output. Standard Nano4 GPU
partition names observed at verification time were:

- `dev`
- `8gpus`
- `16gpus`
- `32gpus`
- `64gpus`
- `256gpus`

These partitions used H200 GPU nodes at verification time. Names such as
`adi_moda`, `slinky`, and `taide` are special-purpose partitions; never infer
general access from their visibility in `sinfo`.

Verify the chosen partition using:

```bash
scontrol show partition "<PARTITION>"
```

Check `AllowAccounts`, `DenyAccounts`, `AllowGroups`, QoS, `MaxTime`, CPU, memory,
and GPU resources before generating a job.

## NGS Partition Families

Observed standard NGS partitions included:

- Memory-oriented: `ngs8g`, `ngs16g`, `ngs32g`, `ngs62g`, `ngs125g`,
  `ngs250g`, `ngs500g`, `ngs1000g`
- CPU-oriented: `ngs248c`, `ngs496c`
- Course: `ngscourse8g`, `ngscourse32g`, `ngscourse125g`
- Very-high-memory: `ngs1500g`, `ngs2t`, `ngs3t`, `ngs6t`
- Administrative/interactive: `ngstest`, `ngsconsole`

Visibility is not authorization. Query the exact partition every time. Do not use
administrative, console, test, course, or special high-memory partitions unless the
workload and account are explicitly eligible.
