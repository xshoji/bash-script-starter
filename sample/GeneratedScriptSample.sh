#!/bin/bash

function usage()
{
cat << _EOT_

 GeneratedScriptSample
-------------------------- author: xshoji

This is generated script sample.

Usage:
  ./$(basename "$0") --id 1001 --type type-a [ --name xshoji --city tokyo --dry-run --read-only ]

Environment variables: 
  export ENV_VAR1=xxxxx
  export ENV_VAR2=xxxxx

Required:
  -i, --id 1001     : "1001" means id.
  -t, --type type-a : [ type-a | type-b ]

Optional:
  -n, --name xshoji : "xshoji" means name.
  -c, --city tokyo  : City.
  -d, --dry-run   : Enable dry-run flag.
  -r, --read-only : Read only mode.

Helper options:
  --help, --debug

_EOT_
  [[ "${1+x}" != "" ]] && { exit "${1}"; }
  exit 1
}
function printColored() { local B="\033[0;"; case "${1}" in "yellow") C="33m";; "green") C="32m";; "red") C="31m";; "blue") C="34m";; esac; printf "%b%b\033[0m" "${B}${C}" "${2}"; }



#------------------------------------------
# Preparation
#------------------------------------------
set -eu

# Parse parameters
for ARG in "$@"
do
    SHIFT="true"
    [[ "${ARG}" == "--debug" ]] && { shift 1; set -eux; SHIFT="false"; }
    { [[ "${ARG}" == "--id" ]] || [[ "${ARG}" == "-i" ]]; } && { shift 1; ID="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--type" ]] || [[ "${ARG}" == "-t" ]]; } && { shift 1; TYPE="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--name" ]] || [[ "${ARG}" == "-n" ]]; } && { shift 1; NAME="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--city" ]] || [[ "${ARG}" == "-c" ]]; } && { shift 1; CITY="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--dry-run" ]] || [[ "${ARG}" == "-d" ]]; } && { shift 1; DRY_RUN="true"; SHIFT="false"; }
    { [[ "${ARG}" == "--read-only" ]] || [[ "${ARG}" == "-r" ]]; } && { shift 1; READ_ONLY="true"; SHIFT="false"; }
    { [[ "${ARG}" == "--help" ]] || [[ "${ARG}" == "-h" ]]; } && { shift 1; HELP="true"; SHIFT="false"; }
    { [[ "${SHIFT}" == "true" ]] && [[ "$#" -gt 0 ]]; } && { shift 1; }
done
[[ -n "${HELP+x}" ]] && { usage 0; }
# Check environment variables
[[ -z "${ENV_VAR1+x}" ]] && { printColored yellow "[!] export ENV_VAR1=xxxxx is required.\n"; INVALID_STATE="true"; }
[[ -z "${ENV_VAR2+x}" ]] && { printColored yellow "[!] export ENV_VAR2=xxxxx is required.\n"; INVALID_STATE="true"; }
# Check required parameters
[[ -z "${ID+x}" ]] && { printColored yellow "[!] --id is required.\n"; INVALID_STATE="true"; }
[[ -z "${TYPE+x}" ]] && { printColored yellow "[!] --type is required.\n"; INVALID_STATE="true"; }
# Check invalid state and display usage
[[ -n "${INVALID_STATE+x}" ]] && { usage; }
# Initialize optional variables
[[ -z "${NAME+x}" ]] && { NAME=""; }
[[ -z "${CITY+x}" ]] && { CITY=""; }
[[ -z "${DRY_RUN+x}" ]] && { DRY_RUN="false"; }
[[ -z "${READ_ONLY+x}" ]] && { READ_ONLY="false"; }



#------------------------------------------
# Main
#------------------------------------------

cat << __EOT__

[ Environment variables ]
ENV_VAR1: ${ENV_VAR1}
ENV_VAR2: ${ENV_VAR2}

[ Required parameters ]
id: ${ID}
type: ${TYPE}

[ Optional parameters ]
name: ${NAME}
city: ${CITY}
dry-run: ${DRY_RUN}
read-only: ${READ_ONLY}

__EOT__


# STARTER_URL=https://raw.githubusercontent.com/xshoji/bash-script-starter/master/ScriptStarter.sh
# curl -sf ${STARTER_URL} |bash -s - \
#   -n GeneratedScriptSample \
#   -a xshoji \
#   -d "This is generated script sample." \
#   -e ENV_VAR1,xxxxx \
#   -e ENV_VAR2,xxxxx \
#   -r id,1001 \
#   -r type,type-a,"[ type-a | type-b ]" \
#   -o name,xshoji \
#   -o city,tokyo,"City." \
#   -f dry-run \
#   -f read-only,"Read only mode." \
#   -s > GeneratedScriptSample.sh
