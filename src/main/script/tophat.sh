#!/bin/bash

#$ -S /bin/bash

#$ -o /work/$USER/$JOB_NAME-$JOB_ID.log
#$ -j y

[[ $1 = "-h" || $1 = "-help" || $1 = "--help" ]] && {
cat << EOF
<submit-command> [submit-args] $0 index [tophat-arguments]"

required arguments

    index                          used as bowtie index argument

automatic arguments (do not supply!)

    -p | --num-threads             set according to request
    -o | --output-dir              set to /work/$USER/tophat-\$JOB_ID

EOF
exit 0
}

source @libdir@/submit-scripts/util.sh
source /etc/profile.d/000-modules.sh
module load tophat
module load pigz
module load pbzip2

BOWTIE_INDEX="$1" ; shift

tophat -p ${NSLOTS:-1} -o "/work/$USER/$JOB_NAME-$JOB_ID" "$BOWTIE_INDEX" "$@"
