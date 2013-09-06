#!/bin/bash

SUBMIT_SCRIPT="@datadir@/submit-scripts/@submitscript@"

[[ $1 = "-h" || $1 = "-help" || $1 = "--help" ]] && {
cat << EOF
Submitter Usage
===============

Submit the job without submit arguments:

    $(basename $0) [app-args]

or explicitly with submit arguments:

    SUBMIT_OPTS="submit-args" $(basename $0) [app-args]

or implicitly with submit arguments from the shell variable:

    export SUBMIT_OPTS="submit-args"
    $(basename $0) [app-args]

Submit Script Usage
===================

$(bash "$SUBMIT_SCRIPT" $1 | sed 's/^/    /')

EOF
exit 0
}

set -x

qsub $SUBMIT_OPTS "$SUBMIT_SCRIPT" "$@"
