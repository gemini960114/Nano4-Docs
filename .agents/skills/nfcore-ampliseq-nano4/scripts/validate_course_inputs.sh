#!/bin/bash
set -euo pipefail

WORK_ROOT="${1:-}"
MANIFEST="${2:-}"

if [[ -z "${WORK_ROOT}" || ! -d "${WORK_ROOT}" ]]; then
    echo 'Usage: validate_course_inputs.sh <work-root> <manifest.tsv>' >&2
    exit 2
fi
if [[ -z "${MANIFEST}" || ! -f "${MANIFEST}" ]]; then
    echo "ERROR: manifest not found: ${MANIFEST}" >&2
    exit 2
fi

SAMPLESHEET="${WORK_ROOT}/metadata/samplesheet.tsv"
METADATA="${WORK_ROOT}/metadata/metadata.tsv"
[[ -f "${SAMPLESHEET}" ]] || { echo "ERROR: missing ${SAMPLESHEET}" >&2; exit 1; }
[[ -f "${METADATA}" ]] || { echo "ERROR: missing ${METADATA}" >&2; exit 1; }

status=0
while IFS=$'\t' read -r nfcore_id original_id sample_accession run_accession \
    fastq_1_url fastq_1_md5 fastq_2_url fastq_2_md5; do
    [[ "${nfcore_id}" == 'nfcore_id' ]] && continue
    fastq_1="${WORK_ROOT}/data/${run_accession}_1.fastq.gz"
    fastq_2="${WORK_ROOT}/data/${run_accession}_2.fastq.gz"

    for specification in "${fastq_1_md5}:${fastq_1}" "${fastq_2_md5}:${fastq_2}"; do
        expected_md5="${specification%%:*}"
        fastq="${specification#*:}"
        if [[ ! -f "${fastq}" ]]; then
            echo "ERROR: missing ${fastq}" >&2
            status=1
            continue
        fi
        if ! gzip -t "${fastq}"; then
            echo "ERROR: gzip integrity failed: ${fastq}" >&2
            status=1
        elif ! printf '%s  %s\n' "${expected_md5}" "${fastq}" | md5sum --check --status; then
            echo "ERROR: MD5 mismatch: ${fastq}" >&2
            status=1
        fi
    done

    grep -q "^${nfcore_id}"$'\t' "${SAMPLESHEET}" || {
        echo "ERROR: ${nfcore_id} missing from samplesheet" >&2
        status=1
    }
    grep -q "^${nfcore_id}"$'\t'"${original_id}"$'\t' "${METADATA}" || {
        echo "ERROR: ID mapping missing from metadata: ${nfcore_id} -> ${original_id}" >&2
        status=1
    }
done < "${MANIFEST}"

if [[ "${status}" -ne 0 ]]; then
    exit "${status}"
fi

echo 'Input validation passed: IDs, pairs, gzip streams and ENA MD5 values are consistent.'
