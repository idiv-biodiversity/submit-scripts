#!/bin/bash

#$ -S /bin/bash

#$ -o /work/$USER/$JOB_NAME-$JOB_ID.log
#$ -j y

[[ $1 = "-h" || $1 = "-help" || $1 = "--help" ]] && {
cat << EOF
<submit-command> [submit-args] $0 input output [cutadapt-arguments]"

required arguments

    input                          used as cutadapt input file
    output                         used as cutadapt output file

EOF
exit 0
}

source @pkglibdir@/util.sh
source /etc/profile.d/000-modules.sh
module load cutadapt

INPUT="$1"  ; shift
OUTPUT="$1" ; shift

${TRACE:+tracer} cutadapt "$INPUT" -o "$OUTPUT" "$@"
