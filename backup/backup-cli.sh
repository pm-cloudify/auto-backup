#!/usr/bin/bash

set -e

usage() {

    cat <<EOF
Usage: $0 [OPTIONS]
    -h,   --help          Show help
    -u,   --user          Sets username
    -p,   --password      Sets password
    --db, --database    Sets database
    -t,   --tag           Sets a dag at the begging of dumped file, default is: "app"
EOF
}

DB_USER=""
DB_PASSWD=""
DB_NAME=""
TAG_NAME="app"

# **** ref: This is a builtin feature to create POSIX-compatible cli
# Parse options
# while getopts ":hvf:" opt; do
#   case "$opt" in
#     h) usage; exit 0 ;;
#     :) printf '%s\n' "Option -$OPTARG requires an argument." >&2; usage; exit 2 ;;
#   esac
# done


# parsing options in a POSIX-compatible way
while [ $# -gt 0 ]; do
    case "$1" in
        # help
        -h|--help)
            usage; exit 0
        ;;
        # set user
        -u)
            if [ $# -lt 2 ]; then
                printf 'Error -u required an argument' ; exit 1
            fi
            DB_USER=$2; shift 2
        ;;
        --user=*)
            DB_USER=${1#--user=}; shift 2
        ;;
        --user)
            if [ $# -lt 2 ]; then
                printf '%s\n' "Error: --user requires an argument" >&2; exit 2
            fi
            DB_USER=$2; shift 2
        ;;
        # set password
        -p)
            if [ $# -lt 2 ]; then
                printf 'Error -p required an argument' ; exit 1
            fi
            DB_PASSWD=$2; shift 2
        ;;
        --password=*)
            DB_PASSWD=${1#--password=}; shift 2
        ;;
        --password)
            if [ $# -lt 2 ]; then
                printf '%s\n' "Error: --password requires an argument" >&2; exit 2
            fi
            DB_PASSWD=$2; shift 2
        ;;
        # set database
        --db)
            if [ $# -lt 2 ]; then
                printf 'Error --db required an argument' ; exit 1
            fi
            DB_NAME=$2; shift 2
        ;;
        --database=*)
            DB_NAME=${1#--database=}; shift 2
        ;;
        --database)
            if [ $# -lt 2 ]; then
                printf '%s\n' "Error: --database requires an argument" >&2; exit 2
            fi
            DB_NAME=$2; shift 2
        ;;
        # set tag name
        -t)
            if [ $# -lt 2 ]; then
                printf 'Error -t required an argument' ; exit 1
            fi
            TAG_NAME=$2; shift 2
        ;;
        --tag=*)
            TAG_NAME=${1#--tag=}; shift 2
        ;;
        --tag)
            if [ $# -lt 2 ]; then
                printf '%s\n' "Error: --tag requires an argument" >&2; exit 2
            fi
            TAG_NAME=$2; shift 2
        ;;
        -*) 
            printf '%s\n' "Unknown option: $1" >&2; usage; exit 2
        ;;
        *) 
            break
        ;;
    esac
done

# TODO: add a feature to add these options safely here.

if [ -z "$DB_USER" ]; then
        printf '%s\n' "user is required!" >&2
        exit 1
fi

if [ -z "$DB_PASSWD" ]; then
        printf '%s\n' "password is required!" >&2
        exit 1
fi

if [ -z "$DB_NAME" ]; then
        printf '%s\n' "database is required!" >&2
        exit 1
fi


TIMESTAMP=$(date +'%Y%m%d-%H%M%S')
mkdir -p "$HOME/dumped"
outfile="$HOME/dumped/${TAG_NAME}-${DB_NAME}-${TIMESTAMP}.dump"

tmp_err=$(mktemp)

docker exec mongodb sh -c "mongodump --authenticationDatabase admin -u '$DB_USER' -p '$DB_PASSWD' --db '$DB_NAME' --archive" > "$outfile" 2> "$tmp_err"
rc=$?

if [ "$rc" -ne 0 ]; then
  echo "mongodump failed (exit $rc). Error output:" >&2
  sed 's/^/  /' "$tmp_err" >&2
  rm -f "$tmp_err"
  exit "$rc"
fi

if [ ! -s "$outfile" ]; then
  echo "mongodump reported success but output file is empty: $outfile" >&2
  echo "stderr was:" >&2
  sed 's/^/  /' "$tmp_err" >&2
  rm -f "$tmp_err"
  exit 2
fi

echo "Dump succeeded, file: $outfile"
rm -f "$tmp_err"
