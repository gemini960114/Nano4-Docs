#!/bin/bash
#SBATCH --job-name=ampliseq_data
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=01:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

# Submit from the chapter directory and provide account/partition on the command line:
# sbatch --account=<PROJECT_ID> --partition=<PARTITION> scripts/01_prepare_real_data.slurm

module purge
set -euo pipefail

COURSE_DIR="${COURSE_DIR:-${SLURM_SUBMIT_DIR}}"
NFCORE_ROOT="${NFCORE_ROOT:-/work/${USER}/nfcore-ampliseq-course}"
MANIFEST="${COURSE_DIR}/data/ena_manifest.tsv"
SOURCE_METADATA="${COURSE_DIR}/metadata/course_subset.tsv"
DATA_DIR="${NFCORE_ROOT}/data"
METADATA_DIR="${NFCORE_ROOT}/metadata"
SAMPLESHEET="${METADATA_DIR}/samplesheet.tsv"

for required_file in "${MANIFEST}" "${SOURCE_METADATA}"; do
    if [[ ! -f "${required_file}" ]]; then
        echo "ERROR: missing course file: ${required_file}" >&2
        exit 1
    fi
done

mkdir -p \
    "${DATA_DIR}" \
    "${METADATA_DIR}" \
    "${NFCORE_ROOT}/cache/nextflow" \
    "${NFCORE_ROOT}/cache/singularity" \
    "${NFCORE_ROOT}/cache/singularity-runtime" \
    "${NFCORE_ROOT}/cache/taxonomy" \
    "${NFCORE_ROOT}/results-test" \
    "${NFCORE_ROOT}/results-real" \
    "${NFCORE_ROOT}/work-test" \
    "${NFCORE_ROOT}/work-real" \
    "${NFCORE_ROOT}/provenance"

install -m 0644 "${SOURCE_METADATA}" "${METADATA_DIR}/metadata.tsv"
printf 'sample\tfastq_1\tfastq_2\n' > "${SAMPLESHEET}"

download_and_verify() {
    local url="$1"
    local expected_md5="$2"
    local destination="$3"
    local partial="${destination}.part"

    if [[ -f "${destination}" ]]; then
        if printf '%s  %s\n' "${expected_md5}" "${destination}" | md5sum --check --status; then
            echo "Reusing verified file: ${destination}"
            return
        fi
        echo "ERROR: existing file failed MD5; preserved for inspection: ${destination}" >&2
        exit 1
    fi

    echo "Downloading ${url}"
    curl --fail --location --retry 3 --continue-at - --output "${partial}" "${url}"
    printf '%s  %s\n' "${expected_md5}" "${partial}" | md5sum --check --status
    mv "${partial}" "${destination}"
}

while IFS=$'\t' read -r nfcore_id original_id sample_accession run_accession \
    fastq_1_url fastq_1_md5 fastq_2_url fastq_2_md5; do
    if [[ "${nfcore_id}" == "nfcore_id" ]]; then
        continue
    fi

    fastq_1="${DATA_DIR}/${run_accession}_1.fastq.gz"
    fastq_2="${DATA_DIR}/${run_accession}_2.fastq.gz"
    download_and_verify "${fastq_1_url}" "${fastq_1_md5}" "${fastq_1}"
    download_and_verify "${fastq_2_url}" "${fastq_2_md5}" "${fastq_2}"
    printf '%s\t%s\t%s\n' "${nfcore_id}" "${fastq_1}" "${fastq_2}" >> "${SAMPLESHEET}"
done < "${MANIFEST}"

cp "${MANIFEST}" "${NFCORE_ROOT}/provenance/ena_manifest.tsv"
cp "${COURSE_DIR}/metadata/study_notes.md" "${NFCORE_ROOT}/provenance/study_notes.md"

echo "Dataset prepared in ${NFCORE_ROOT}"
echo "Samplesheet: ${SAMPLESHEET}"
echo "Metadata: ${METADATA_DIR}/metadata.tsv"
