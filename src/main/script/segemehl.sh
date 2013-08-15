#!/bin/bash

#$ -S /bin/bash

#$ -o /work/$USER/$JOB_NAME-$JOB_ID.log
#$ -j y

[[ $1 = "-h" || $1 = "-help" || $1 = "--help" ]] && {
cat << EOF
<submit-command> [submit-args] $0 database index output [segemehl-arguments]"

required arguments

    database    used for argument -d | --database
    index       used for argument -i | --index
    output      used for argument -o | --outfile

automatic arguments (do not supply!)

    -t | --threads

EOF
exit 0
}

source @libdir@/submit-scripts/util.sh
source /etc/profile.d/000-modules.sh
module load segemehl
module load pigz

DATABASE=$1 ; shift
INDEX=$1    ; shift
OUTPUT=$1   ; shift

segemehl -t ${NSLOTS:-1} -d <(read-from "$DATABASE") -i <(read-from "$INDEX") "$@" | write-to "$OUTPUT"
