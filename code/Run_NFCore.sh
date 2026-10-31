#!/bin/bash
workdir=/home/davidc/ws30_scratch2/Chisangad/Projects/Hansen/Anthony
mkdir -p $workdir
cd $workdir

# Load necessary modules
module load nextflow
export NXF_SINGULARITY_CACHEDIR="/home/davidc/ws30_scratch2/Chisangad/singularity/"
export APPTAINER_CACHEDIR="/home/davidc/ws30_scratch2/Chisangad/.apptainer/"
samplesheet=/home/davidc/ws30/Chisanga/Shi_Lab/Hansen_Lab/Anthony/data/samplesheet_ATAC.csv
profile_config=/home/davidc/ws30_scratch2/Chisangad/BioinfoTools/NFCore_profiles/NFCore_CutnRun.config

/home/davidc/ws30_scratch2/Chisangad/BioinfoTools/Nextflow/nextflow run nf-core/atacseq --input ${samplesheet} -c ${profile_config} \
-profile 'slurm,singularity' \
  --genome GRCh38 \
  --mito_name chrM \
  --macs_gsize 2913022398 \
  --outdir NFCore_ATACseq \
  -resume \
  --narrow_peak true \
  --blacklist /home/davidc/ws30_scratch2/Chisangad/genomes/blacklist/hg38-blacklist.v2.bed \
  -bg true
