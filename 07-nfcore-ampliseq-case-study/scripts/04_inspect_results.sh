#!/bin/bash
set -euo pipefail

NFCORE_ROOT="${NFCORE_ROOT:-/work/${USER}/nfcore-ampliseq-course}"
RESULTS="${NFCORE_ROOT}/results-real"

if [[ ! -d "${RESULTS}" ]]; then
    echo "ERROR: result directory does not exist: ${RESULTS}" >&2
    exit 1
fi

echo 'Pipeline reports:'
find "${RESULTS}" -maxdepth 3 -type f \
    \( -name 'multiqc_report.html' -o -name 'pipeline_report.html' \
    -o -name 'execution_report_*.html' -o -name 'execution_timeline_*.html' \) \
    -print | sort

echo
echo 'Key result tables:'
find "${RESULTS}" -maxdepth 5 -type f \
    \( -name 'overall_summary.tsv' -o -name 'ASV_table*.tsv' \
    -o -name 'ASV_tax*.tsv' -o -name 'feature-table.tsv' \
    -o -name 'rel-table-*.tsv' \) \
    -print | sort

echo
echo 'Review order: pipeline_info -> multiqc -> cutadapt -> dada2 -> qiime2 -> seff'
