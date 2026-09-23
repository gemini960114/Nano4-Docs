---
trigger: always_on
---

# Nano4 課程規則

開始任何工作前，先閱讀並完全遵守 @../../AGENTS.md（本工作區根目錄的 AGENTS.md）。

若無法讀取該檔案，至少遵守以下規則：

- 這是國網中心 Nano4 多人共用超級電腦，禁止 `sudo`；目前所在的是登入節點，不在這裡跑重度運算。
- 本課程計畫 `GOV115088` 只能使用 `ngs62g`，每個作業固定 `--cpus-per-task=8 --mem=62G`，不可調小。
- 運算一律寫成 Slurm 腳本以 `sbatch` 送出：執行內容第一行 `module purge`，日誌用 `%x-%j.out` / `%x-%j.err`；FastQC 要一起載入 `biology/JDK/26.0.1`。
- 大型資料與結果放 `/work/$USER`；送出後查一次 `sacct` 即可，不要在迴圈中反覆查詢 `squeue`。
- 使用者是生醫研究者：先用白話說明計畫，經同意後再送出作業，完成後用白話解讀結果。
