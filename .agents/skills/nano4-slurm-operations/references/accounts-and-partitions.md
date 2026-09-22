# Nano4 Accounts and Partitions

Last verified on Nano4 login host `25a-lgn02`: 2026-07-29.

Live scheduler output overrides this reference.

## Account Sources

Nano4 exposes two different views:

- `wallet`: currently active Nano4 projects and SU balances.
- `sacctmgr show assoc`: Slurm associations, including historical or special
  accounts that might not appear as active wallet projects.

Do not treat an association as proof of an active balance. Conversely, do not treat
the special `GOV115088` wallet response as proof that its NGS allocation is invalid.

## Biomedical Allocation

- Account: `GOV115088`
- Purpose: dedicated biomedical/NGS allocation
- Partition family: `ngs*` (e.g. `ngs62g`, `ngs250g`)
- Standard GPU partitions: prohibited

Observed behavior:

- `wallet GOV115088` reports that the NANO4 service is not enabled.
- The Slurm association includes `gov115088`.
- `ngs62g` and `ngs250g` explicitly include `gov115088` in `AllowAccounts`.
- `ngs8g`, `ngs16g`, `ngs32g`, `ngs125g` do NOT include `gov115088` in `AllowAccounts`.
- The standard GPU `dev` partition explicitly includes `gov115088` in
  `DenyAccounts`.

Therefore validate this account through both the Slurm association and the selected
NGS partition's current policy.

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
