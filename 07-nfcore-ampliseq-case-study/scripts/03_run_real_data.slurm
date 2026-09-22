#!/bin/bash
#SBATCH --job-name=ampliseq_real
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=96:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

module purge
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
command -v nextflow >/dev/null || {
    echo 'ERROR: nextflow is not available on PATH' >&2
    exit 1
}
command -v singularity >/dev/null || command -v apptainer >/dev/null || {
    echo 'ERROR: neither singularity nor apptainer is available on PATH' >&2
    exit 1
}

mkdir -p \
    "${NFCORE_ROOT}/cache/nextflow" \
    "${NFCORE_ROOT}/cache/singularity" \
    "${NFCORE_ROOT}/cache/singularity-runtime" \
    "${NFCORE_ROOT}/cache/taxonomy" \
    "${NFCORE_ROOT}/results-real" \
    "${NFCORE_ROOT}/work-real"

export NXF_HOME="${NFCORE_ROOT}/cache/nextflow"
export NXF_SINGULARITY_CACHEDIR="${NFCORE_ROOT}/cache/singularity"
export APPTAINER_CACHEDIR="${NFCORE_ROOT}/cache/singularity-runtime"
export SINGULARITY_CACHEDIR="${NFCORE_ROOT}/cache/singularity-runtime"

nextflow run nf-core/ampliseq \
    -r 2.18.0 \
    -profile singularity \
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
