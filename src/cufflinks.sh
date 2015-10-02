#!/bin/bash

#$ -S /bin/bash

#$ -o /work/$USER/$JOB_NAME-$JOB_ID.log
#$ -j y

[[ $1 = "-h" || $1 = "-help" || $1 = "--help" ]] && {
cat << EOF
<submit-command> [submit-args] $0 input [cufflinks-arguments]"

required arguments

    input                          used as cufflinks input file

automatic arguments (do not supply!)

    -o | --output-dir
    -p | --num-threads

EOF
exit 0
}

source @pkglibdir@/util.sh
source /etc/profile.d/000-modules.sh
module load cufflinks

INPUT="$1" ; shift

${TRACE:+tracer} cufflinks -o "$OUTPUT_DIR" -p ${NSLOTS:-1} "$@" "$INPUT"
