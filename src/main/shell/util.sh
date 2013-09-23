# dedicated to our friends of the UFZ 
#
# ------------------------------------------------------------------------------
# configuration
# ------------------------------------------------------------------------------

export R_BUF_SIZE=${R_BUF_SIZE:-1M}
export W_BUF_SIZE=${W_BUF_SIZE:-1M}

# ---------------------------------------------------------------------------------------------------
# bailout behaviour
# ---------------------------------------------------------------------------------------------------

# usage:
#   trap 'bailout $LINENO $?' ERR
#
# $1 line number
# $2 exit status
bailout() {
  echo "[$(date)] [ERROR] Last command around line $1 failed with exit status \"$2\". Bailing out. Please cleanup and try again."
  exit 1
}

# use always directly after a pipe:
#   foo | bar | baz | ...
#   pipe_bailout $LINENO
#
# $1 line number
pipe_bailout() {
  for i in "${PIPESTATUS[@]}" ; do
    [[ "x$i" != "x0" ]] && bailout $(expr $1 - 1) $i
  done

  return 0
}

# ------------------------------------------------------------------------------
# reading
# ------------------------------------------------------------------------------

read-from-dd() {
  local input="$1"
  dd if="$input" ibs=$R_BUF_SIZE 2> /dev/null
}

read-from-gzip() {
  local input="$1"
  read-from-dd "$input" | gzip --decompress
}

read-from-pigz() {
  local input="$1"
  read-from-dd "$input" | pigz --decompress --processes ${NSLOTS:-1}
}

read-from() {
  local input="$1"

  case "$input" in
    *.gz)
      if which pigz > /dev/null 2>&1 ; then
        read-from-pigz "$input"
      else
        read-from-gzip "$input"
      fi
      ;;
    *)
      read-from-dd "$input"
      ;;
  esac
}

# ------------------------------------------------------------------------------
# writing
# ------------------------------------------------------------------------------

write-to-dd() {
  local output="$1"
  dd of="$output" obs=$W_BUF_SIZE 2> /dev/null
}

write-to-gzip() {
  local output="$1"
  gzip | write-to-dd "$output"
}

write-to-pigz() {
  local output="$1"
  pigz --processes ${NSLOTS:-1} | write-to-dd "$output"
}

write-to() {
  local output="$1"

  mkdir -p "$(dirname "$output")"

  case "$output" in
    *.gz)
      if which pigz > /dev/null 2>&1 ; then
        write-to-pigz "$output"
      else
        write-to-gzip "$output"
      fi
      ;;
    *)
      write-to-dd "$output"
      ;;
  esac
}

# ------------------------------------------------------------------------------
# tracing
# ------------------------------------------------------------------------------

tracer() {
  local output="/work/$USER/$JOB_NAME-$JOB_ID-strace.out.gz"
  strace -T -ttt -f -o >(write-to "$output") "$@"
}

# ------------------------------------------------------------------------------
# functions
# ------------------------------------------------------------------------------

export -f read-from
export -f read-from-dd
export -f read-from-gzip
export -f read-from-pigz
export -f write-to
export -f write-to-dd
export -f write-to-gzip
export -f write-to-pigz
export -f tracer

# ------------------------------------------------------------------------------
# init
# ------------------------------------------------------------------------------

export OUTPUT_DIR="/work/$USER/$JOB_NAME-$JOB_ID"
