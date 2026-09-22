#!/usr/bin/env bash
set -euo pipefail

project=""
partition=""

usage() {
    cat <<'USAGE'
Usage:
  slurm-preflight.sh [--project PROJECT_ID] [--partition PARTITION]

Performs read-only Nano4 checks. With no arguments, lists active wallet projects
and current Slurm partitions. It never submits or cancels a job.
USAGE
}

while (($# > 0)); do
    case "$1" in
        --project)
            [[ $# -ge 2 ]] || { echo "錯誤：--project 缺少值" >&2; exit 2; }
            project="$2"
            shift 2
            ;;
        --partition)
            [[ $# -ge 2 ]] || { echo "錯誤：--partition 缺少值" >&2; exit 2; }
            partition="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "錯誤：未知參數：$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

for command_name in hostname wallet scontrol sinfo sacctmgr; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "錯誤：找不到必要指令：$command_name" >&2
        exit 2
    fi
done

host_name="$(hostname -s)"
if [[ ! "$host_name" =~ ^25a-lgn[0-9]+$ ]]; then
    echo "錯誤：目前主機不是 Nano4 login node：$host_name" >&2
    exit 2
fi

cluster_name="$(
    scontrol show config |
        awk -F= '$1 ~ /^[[:space:]]*ClusterName[[:space:]]*$/ {
            gsub(/[[:space:]]/, "", $2)
            cluster = $2
        }
        END { print cluster }'
)"
if [[ "$cluster_name" != "hpc" ]]; then
    echo "錯誤：非預期 Slurm cluster：${cluster_name:-unknown}" >&2
    exit 2
fi

echo "Nano4 host: $host_name"
echo "Slurm cluster: $cluster_name"

project_lower="${project,,}"
if [[ -n "$project" ]]; then
    echo
    echo "Project check: $project"
    wallet_status=0
    wallet_output="$(wallet "$project" 2>&1)" || wallet_status=$?
    if [[ "$project_lower" == "gov115088" ]] &&
         grep -q "NANO4 service enabled" <<<"$wallet_output"; then
        echo "INFO: GOV115088 是特殊 NGS 計畫；wallet 的 NANO4 service 訊息不單獨判定失效。"
    elif ((wallet_status == 0)) &&
         grep -qi "^PROJECT_ID: ${project}," <<<"$wallet_output"; then
        printf '%s\n' "$wallet_output"
    else
        printf '%s\n' "$wallet_output" >&2
        echo "錯誤：wallet 無法確認有效的一般計畫：$project" >&2
        exit 1
    fi

    association="$(
        sacctmgr -nP show assoc user="$USER" account="$project_lower" \
            format=Account,Partition,QOS,DefaultQOS
    )"
    if ! awk -F'|' -v target="$project_lower" \
        'tolower($1) == target { found = 1 } END { exit !found }' \
        <<<"$association"; then
        echo "錯誤：Slurm association 找不到帳號：$project" >&2
        exit 1
    fi
    echo "Slurm association: OK"
else
    echo
    echo "Active wallet projects:"
    wallet
fi

list_contains_account() {
    local list="${1,,}"
    local target="${2,,}"
    [[ "$list" == "all" || ",$list," == *",$target,"* ]]
}

partition_field() {
    local record="$1"
    local key="$2"
    tr ' ' '\n' <<<"$record" |
        awk -F= -v requested="$key" '$1 == requested && !found {
            value = $2
            found = 1
        }
        END { print value }'
}

if [[ -n "$partition" ]]; then
    echo
    echo "Partition check: $partition"
    if ! partition_record="$(scontrol -o show partition "$partition" 2>&1)"; then
        printf '%s\n' "$partition_record" >&2
        echo "錯誤：partition 不存在或無法查詢：$partition" >&2
        exit 1
    fi
    printf '%s\n' "$partition_record"

    if [[ "$project_lower" == "gov115088" && ! "$partition" =~ ^ngs ]]; then
        echo "錯誤：GOV115088 僅可用於經驗證允許的 ngs* partition" >&2
        exit 1
    fi

    if [[ -n "$project_lower" ]]; then
        allow_accounts="$(partition_field "$partition_record" "AllowAccounts")"
        deny_accounts="$(partition_field "$partition_record" "DenyAccounts")"

        if [[ -n "$allow_accounts" ]] &&
           ! list_contains_account "$allow_accounts" "$project_lower"; then
            echo "錯誤：$partition 的 AllowAccounts 不包含 $project" >&2
            exit 1
        fi
        if [[ -n "$deny_accounts" ]] &&
           list_contains_account "$deny_accounts" "$project_lower"; then
            echo "錯誤：$partition 的 DenyAccounts 禁止 $project" >&2
            exit 1
        fi
        echo "Project/partition policy: OK"
    else
        echo "INFO: 未提供 --project，僅顯示 partition，未驗證計畫相容性。"
    fi
else
    echo
    echo "Current partitions:"
    sinfo -h -o '%P|%a|%l|%D|%c|%m|%G'
fi

echo
echo "Preflight completed without scheduler mutation."
