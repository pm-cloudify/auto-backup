#!/usr/bin/bash

set -e

usage() {

    cat <<EOF
Usage: $0 [OPTIONS]
    -h, --help          Show help
    -u, --user          Sets username
    -p, --password      Sets password
    -d, --database      Sets database
    -t, --tag           Sets a dag at the begging of dumped file, default is: "app"
EOF
}

TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
DB_USER=""
DB_PASSWD=""
DB_NAME=""
TAG_NAME=""


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
            DB_USER=$2; shift
        ;;
        --user=*)
            DB_USER=${1#--user=}; shift
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
            DB_PASSWD=$2; shift
        ;;
        --password=*)
            DB_PASSWD=${1#--password=}; shift
        ;;
        --password)
            if [ $# -lt 2 ]; then
                printf '%s\n' "Error: --password requires an argument" >&2; exit 2
            fi
            DB_PASSWD=$2; shift 2
        ;;
        # set database
        -d)
            if [ $# -lt 2 ]; then
                printf 'Error -d required an argument' ; exit 1
            fi
            DB_NAME=$2; shift
        ;;
        --database=*)
            DB_NAME=${1#--database=}; shift
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
            TAG_NAME=$2; shift
        ;;
        --tag=*)
            TAG_NAME=${1#--tag=}; shift
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


docker exec mongodb sh -c "mongodump --authenticationDatabase admin -u $DB_USER -p $DB_PASSWD --db $DB_NAME --archive" > "~/mogodump/$TAG_NAME-$DB_NAME-$TIMESTAMP.dump"
