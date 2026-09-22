#!/bin/bash
#SBATCH --job-name=ampliseq_test
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=08:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

module purge
set -euo pipefail

: "${NFCORE_ACCOUNT:?Submit with NFCORE_ACCOUNT exported}"
: "${NFCORE_PARTITION:?Submit with NFCORE_PARTITION exported}"

COURSE_DIR="${COURSE_DIR:-${SLURM_SUBMIT_DIR}}"
NFCORE_ROOT="${NFCORE_ROOT:-/work/${USER}/nfcore-ampliseq-course}"
CONFIG="${COURSE_DIR}/config/nano4.config"

command -v nextflow >/dev/null || {
    echo 'ERROR: nextflow is not available on PATH' >&2
    exit 1
}
command -v singularity >/dev/null || command -v apptainer >/dev/null || {
    echo 'ERROR: neither singularity nor apptainer is available on PATH' >&2
    exit 1
}
[[ -f "${CONFIG}" ]] || {
    echo "ERROR: missing ${CONFIG}" >&2
    exit 1
}

mkdir -p \
    "${NFCORE_ROOT}/cache/nextflow" \
    "${NFCORE_ROOT}/cache/singularity" \
    "${NFCORE_ROOT}/cache/singularity-runtime" \
    "${NFCORE_ROOT}/results-test" \
    "${NFCORE_ROOT}/work-test" \
    "${NFCORE_ROOT}/provenance"

export NXF_HOME="${NFCORE_ROOT}/cache/nextflow"
export NXF_SINGULARITY_CACHEDIR="${NFCORE_ROOT}/cache/singularity"
export APPTAINER_CACHEDIR="${NFCORE_ROOT}/cache/singularity-runtime"
export SINGULARITY_CACHEDIR="${NFCORE_ROOT}/cache/singularity-runtime"

nextflow -version
nextflow config nf-core/ampliseq -r 2.18.0 -profile test,singularity \
    > "${NFCORE_ROOT}/provenance/test-profile.effective.config"

nextflow run nf-core/ampliseq \
    -r 2.18.0 \
    -profile test,singularity \
    -c "${CONFIG}" \
    --outdir "${NFCORE_ROOT}/results-test" \
    -work-dir "${NFCORE_ROOT}/work-test" \
    -resume
