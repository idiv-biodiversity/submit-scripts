#!/bin/bash

#$ -S /bin/bash

#$ -o /work/$USER/$JOB_NAME-$JOB_ID.log
#$ -j y

# ------------------------------------------------------------------------------
# command line argument processing / configuration
# ------------------------------------------------------------------------------

# function to display usage
usage() { cat << EOF
Usage:
  <submit-command> [submit-args] $0 [-v] [-c hash] /path/to/data-dir/ /path/to/archive.tar.gz

  -h | -help | --help           shows this help text

  data-dir/                     path to directory to be archived
                                (needs to be in current working directory)

  archive.tar.gz                path to archive, currently supported:
                                tar.gz

  -c hash                       hash to use, one of
                                md5, sha1, sha224, sha256, sha384, sha512
                                default is md5

  -v | --verbose                output every command executed
EOF
}

# set arguments to nothing
unset DATA ARCHIVE HASH VERBOSE

# parse parameters
while true ; do
  case "$1" in
    -h|-help|--help) usage ; exit ;;
    -v|--verbose) VERBOSE=yes ; shift ;;
    -c) shift ; HASH=$1 ; shift ;;
    *) break ;;
  esac
done

source @libdir@/submit-scripts/util.sh
source /etc/profile.d/000-modules.sh
module load parallel
module load pigz
module load tarsum
module load coreutils

trap 'bailout $LINENO $?' ERR

DATA="$1"
ARCHIVE="$2"
HASH=${HASH:-md5}

# checking existance of DATA and ARCHIVE arguments
if [[ -z $DATA || -z $ARCHIVE ]] ; then
  usage
  exit 1
fi

# checking ARCHIVE argument
if [[ ! -e "$(dirname "$ARCHIVE")" ]] ; then
  echo "[$(date)] [WARN] The parent directory of your target ($ARCHIVE -> $(dirname $ARCHIVE)) does not exist! Creating it ..."
  mkdir -p "$(dirname "$ARCHIVE")"
fi

if [[ -n $(ls "$ARCHIVE"* 2> /dev/null) ]] ; then
  echo "[$(date)] [ERROR] $(ls $ARCHIVE*) already exist(s)!"
  exit 1
fi

# checking DATA argument
if [[ ! -d "$DATA" || ! -r "$DATA" || ! -x "$DATA" ]] ; then
  echo "[$(date)] [ERROR] Your source directory ($DATA) must be a valid and readable directory!"
  exit 1
else
  # first change to dirname DATA so tarball contents start with basename DATA
  echo "[$(date)] [INFO] Changing to source directory ($(dirname "$DATA")) ..."

  cd "$(dirname "$DATA")"
  DATA="$(basename "$DATA")"
fi

# checking HASH argument
case "$HASH" in
  md5|sha1|sha224|sha256|sha384|sha512) ;;
  *)
    echo "[$(date)] [ERROR] Hash must be on of md5, sha1, sha224, sha256, sha384, sha512!"
    exit 1
    ;;
esac

# checksum command
HASH_CMD=${HASH}sum

# checksum files
CHECKSUMS="${ARCHIVE}.${HASH}"
CHECKSUMS_INTERNAL="${ARCHIVE}-internal.${HASH}"

# ------------------------------------------------------------------------------
# package creation - archiving / compressing
# ------------------------------------------------------------------------------

echo "[$(date)] [INFO] Creating the archive $ARCHIVE ..."

[[ -n $VERBOSE ]] && echo "[$(date)] [DEBUG] tar c $DATA -b 2048 | write-to $ARCHIVE"

tar c $DATA -b 2048 | write-to "$ARCHIVE"
pipe_bailout $LINENO

# ------------------------------------------------------------------------------
# package verification
# ------------------------------------------------------------------------------

echo "[$(date)] [INFO] Verifying the archive against the original data ..."

[[ -n $VERBOSE ]] && echo "[$(date)] [DEBUG] read-from $ARCHIVE | tarsum -c $HASH | tee $CHECKSUMS_INTERNAL | parallel --halt-on-error 2 --jobs ${NSLOTS:-1} \"echo {} | $HASH_CMD --status -c\""

read-from "$ARCHIVE" | tarsum -c $HASH 2> /dev/null | tee "$CHECKSUMS_INTERNAL" | parallel --halt-on-error 2 --jobs ${NSLOTS:-1} "echo {} | $HASH_CMD --status -c"
pipe_bailout $LINENO

echo "[$(date)] [INFO] Creating the checksum of the archive itself ..."

[[ -n $VERBOSE ]] && echo "[$(date)] [DEBUG] read-from-dd $ARCHIVE | $HASH_CMD | sed -e \"s|-$|$(basename $ARCHIVE)|\" >> $CHECKSUMS"

read-from-dd "$ARCHIVE" | $HASH_CMD | sed -e "s|-$|$(basename $ARCHIVE)|" >> $CHECKSUMS
