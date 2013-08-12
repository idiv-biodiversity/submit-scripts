#!/bin/bash
qsub $SUBMIT_OPTS @datadir@/submit-scripts/@submitscript@ "$@"
