#!/bin/bash

#$ -S /bin/bash

#$ -o /work/$USER/$JOB_NAME-$JOB_ID.log
#$ -j y

[[ $1 = "-h" || $1 = "-help" || $1 = "--help" ]] && {
  echo "usage: <submit-command> [submit-args] $(basename $0) input.vcf.gz output [$(basename $0)-arguments]"
  exit 0
}

source @pkglibdir@/util.sh
source /etc/profile.d/000-modules.sh
module load vcftools

INPUT_VCF=$1 ; shift
OUTPUT=$1    ; shift

${TRACE:+tracer} vcftools --gzvcf $INPUT_VCF "$@" --out $OUTPUT
