#!/bin/bash

#$ -S /bin/bash

#$ -o /work/$USER/$JOB_NAME-$JOB_ID.log
#$ -j y

[[ $1 = "-h" || $1 = "-help" || $1 = "--help" ]] && {
  echo "usage: <submit-command> [submit-args] $0 /path/to/trace.gz"
  exit 0
}

source @pkglibdir@/util.sh
source /etc/profile.d/000-modules.sh
module load parallel
module load pigz

[[ -z $1 ]] && exit 1

TRACE=$1

traced-pids() {
  read-from "$TRACE" | awk '{ print $1 }' | sort -un
}

traced-pids | parallel -j ${NSLOTS:-1} "read-from '$TRACE' | awk '\$1 ~ /^{}$/ { \$1 = \"\"; print }' | strace-analyzer --short > '$TRACE-analyzed-{}'"
