#!/bin/bash
#SBATCH --job-name=ampliseq_real
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8             # ngs62g 官方規格：每個作業 8 核心
#SBATCH --mem=62G                     # ngs62g 官方規格：每個作業 62 GB
#SBATCH --time=96:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

# Submit from the chapter directory after 01 and 02 have succeeded:
# export NFCORE_ACCOUNT=GOV115088 NFCORE_PARTITION=ngs62g
# sbatch --account="${NFCORE_ACCOUNT}" --partition="${NFCORE_PARTITION}" \
#     --export=ALL,NFCORE_ACCOUNT,NFCORE_PARTITION scripts/03_run_real_data.slurm

set -euo pipefail

: "${NFCORE_ACCOUNT:?Submit with NFCORE_ACCOUNT exported}"
: "${NFCORE_PARTITION:?Submit with NFCORE_PARTITION exported}"

COURSE_DIR="${COURSE_DIR:-${SLURM_SUBMIT_DIR}}"
NFCORE_ROOT="${NFCORE_ROOT:-/work/${USER}/nfcore-ampliseq-course}"
CONFIG="${COURSE_DIR}/config/nano4.config"
SAMPLESHEET="${NFCORE_ROOT}/metadata/samplesheet.tsv"
METADATA="${NFCORE_ROOT}/metadata/metadata.tsv"

for required_file in "${CONFIG}" "${SAMPLESHEET}" "${METADATA}"; do
    if [[ ! -f "${required_file}" ]]; then
        echo "ERROR: missing required file: ${required_file}" >&2
        exit 1
    fi
done

source "${COURSE_DIR}/scripts/nfcore_env.sh"
mkdir -p "${NFCORE_ROOT}/results-real" "${NFCORE_ROOT}/work-real"

nextflow run "${NFCORE_AMPLISEQ_HOME}" \
    -profile singularity \
    -c "${NFCORE_SITE_CONFIG}" \
    -c "${CONFIG}" \
    --input "${SAMPLESHEET}" \
    --FW_primer 'GTGYCAGCMGCCGCGGTAA' \
    --RV_primer 'GGACTACNVGGGTWTCTAAT' \
    --metadata "${METADATA}" \
    --metadata_category 'TREATMENT' \
    --dada_ref_taxonomy 'silva=138.2' \
    --ref_taxonomy_storage "${NFCORE_ROOT}/cache/taxonomy" \
    --outdir "${NFCORE_ROOT}/results-real" \
    -work-dir "${NFCORE_ROOT}/work-real" \
    -resume
