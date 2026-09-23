#!/bin/bash
# Shared environment for the Chapter 07 Slurm driver jobs.
# Sourced by 02_run_official_test.slurm and 03_run_real_data.slurm.
#
# Uses the NCHC offline nf-core package: the ampliseq 2.18.0 pipeline code and
# its Singularity images are pre-installed, so nothing is pulled from GitHub.
# Only reference taxonomy (e.g. SILVA 138.2) is downloaded once into /work.

: "${NFCORE_ROOT:?NFCORE_ROOT must be set before sourcing nfcore_env.sh}"

module purge
module load biology/nf-core-ampliseq/2.18.0

command -v nextflow >/dev/null || {
    echo 'ERROR: nextflow is not available after module load biology/nf-core-ampliseq/2.18.0' >&2
    exit 1
}
[[ -d "${NFCORE_AMPLISEQ_HOME:-}" && -f "${NFCORE_SITE_CONFIG:-}" ]] || {
    echo 'ERROR: NFCORE_AMPLISEQ_HOME / NFCORE_SITE_CONFIG not provided by the module' >&2
    exit 1
}

mkdir -p \
    "${NFCORE_ROOT}/cache/nextflow" \
    "${NFCORE_ROOT}/cache/singularity" \
    "${NFCORE_ROOT}/cache/singularity-library" \
    "${NFCORE_ROOT}/cache/singularity-runtime" \
    "${NFCORE_ROOT}/cache/apptainer-tmp" \
    "${NFCORE_ROOT}/cache/taxonomy" \
    "${NFCORE_ROOT}/provenance"

export NXF_HOME="${NFCORE_ROOT}/cache/nextflow"

# Read images from the shared, read-only library first; anything missing is
# pulled into the personal cache instead of failing on the read-only directory.
# A few shared entries are HTML error pages saved by a failed prefetch
# (e.g. bioconductor-biostrings-2.58.0), so link only the valid images into a
# personal library and let Nextflow re-download the broken ones.
SHARED_LIBRARY="${NXF_SINGULARITY_CACHEDIR}"
PERSONAL_LIBRARY="${NFCORE_ROOT}/cache/singularity-library"
mkdir -p "${PERSONAL_LIBRARY}"
find "${PERSONAL_LIBRARY}" -maxdepth 1 -type l -delete
for image in "${SHARED_LIBRARY}"/*.img; do
    target="$(readlink -f "${image}")"
    if [[ $(stat -c %s "${target}") -lt 65536 ]] && head -c 16 "${target}" | grep -qi '<html'; then
        echo "WARNING: skipping broken shared image $(basename "${image}")" >&2
        continue
    fi
    ln -s "${target}" "${PERSONAL_LIBRARY}/$(basename "${image}")"
done
export NXF_SINGULARITY_LIBRARYDIR="${PERSONAL_LIBRARY}"
export NXF_SINGULARITY_CACHEDIR="${NFCORE_ROOT}/cache/singularity"
export APPTAINER_CACHEDIR="${NFCORE_ROOT}/cache/singularity-runtime"
export SINGULARITY_CACHEDIR="${NFCORE_ROOT}/cache/singularity-runtime"
export APPTAINER_TMPDIR="${NFCORE_ROOT}/cache/apptainer-tmp"
export SINGULARITY_TMPDIR="${NFCORE_ROOT}/cache/apptainer-tmp"
