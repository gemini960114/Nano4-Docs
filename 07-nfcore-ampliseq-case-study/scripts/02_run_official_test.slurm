#!/bin/bash
#SBATCH --job-name=ampliseq_test
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8             # ngs62g 官方規格：每個作業 8 核心
#SBATCH --mem=62G                     # ngs62g 官方規格：每個作業 62 GB
#SBATCH --time=08:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

# Submit from the chapter directory:
# export NFCORE_ACCOUNT=GOV115088 NFCORE_PARTITION=ngs62g
# sbatch --account="${NFCORE_ACCOUNT}" --partition="${NFCORE_PARTITION}" \
#     --export=ALL,NFCORE_ACCOUNT,NFCORE_PARTITION scripts/02_run_official_test.slurm

set -euo pipefail

: "${NFCORE_ACCOUNT:?Submit with NFCORE_ACCOUNT exported}"
: "${NFCORE_PARTITION:?Submit with NFCORE_PARTITION exported}"

COURSE_DIR="${COURSE_DIR:-${SLURM_SUBMIT_DIR}}"
NFCORE_ROOT="${NFCORE_ROOT:-/work/${USER}/nfcore-ampliseq-course}"
CONFIG="${COURSE_DIR}/config/nano4.config"

[[ -f "${CONFIG}" ]] || {
    echo "ERROR: missing ${CONFIG}" >&2
    exit 1
}

source "${COURSE_DIR}/scripts/nfcore_env.sh"
mkdir -p "${NFCORE_ROOT}/results-test" "${NFCORE_ROOT}/work-test"

nextflow -version
nextflow -c "${NFCORE_SITE_CONFIG}" -c "${CONFIG}" \
    config "${NFCORE_AMPLISEQ_HOME}" -profile test,singularity \
    > "${NFCORE_ROOT}/provenance/test-profile.effective.config"

nextflow run "${NFCORE_AMPLISEQ_HOME}" \
    -profile test,singularity \
    -c "${NFCORE_SITE_CONFIG}" \
    -c "${CONFIG}" \
    --outdir "${NFCORE_ROOT}/results-test" \
    -work-dir "${NFCORE_ROOT}/work-test" \
    -resume
