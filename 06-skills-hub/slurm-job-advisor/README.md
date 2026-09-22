# Slurm Job Advisor & Resource Sizing Skill (Nano4 專屬)

針對國網中心晶創26（Nano4 / `nano4.nchc.org.tw`）超級電腦與通用 HPC Slurm 叢集量身打造的**資源規劃與排程腳本專家技能**。

---

## 🎯 核心功能

1. **動態錢包與佇列整合**：直接讀取國網 `wallet` 計畫餘額，確保作業指定具有足夠 SU 點數的帳號（生醫專案 vs 一般 AI 專案）。
2. **防呆與不合理狀況攔截**：杜絕「`ngs62g` 漏填 `--mem` 導致 QoS 卡死」或「在 `dev` 漏填 `--gres=gpu:1`」等 Nano4 特有地雷配置。
3. **結構化引導問答**：當使用者未提供完整需求時，發起 4 步結構化提問（計畫代號、軟體類型、資源規模、時間預估）。
4. **全流程驗證工具**：內建免扣點排程器預檢腳本（`sbatch --test-only`），提交前 100% 確保語法、分區與配額合規。

---

## 📁 目錄結構

```text
slurm-job-advisor/
├── SKILL.md                          # 核心技能指引、問答模板與 Nano4 硬體規格矩陣
├── README.md                         # 說明文件
├── scripts/
│   ├── check_slurm_env.sh            # 查詢 wallet 餘額與 Nano4 常用佇列即時狀態
│   └── validate_slurm.sh             # 靜態參數分析 + sbatch --test-only 免扣點預檢
└── templates/
    ├── single_node_cpu.slurm         # 常規單節點多執行緒腳本範本 (ngs62g)
    ├── fat_node_mem.slurm            # 高記憶體組裝/大數據腳本範本 (ngs250g / ngs6t)
    └── array_job.slurm               # 多樣本批次平行陣列腳本範本 (ngs62g)
```

---

## 🚀 快速指令

### 1. 查詢環境與錢包額度
```bash
bash 06-skills-hub/slurm-job-advisor/scripts/check_slurm_env.sh
```

### 2. 驗證 Slurm 腳本
```bash
bash 06-skills-hub/slurm-job-advisor/scripts/validate_slurm.sh <your_job.slurm>
```
