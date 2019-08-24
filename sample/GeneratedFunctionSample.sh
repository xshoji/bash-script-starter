#!/bin/bash

#######################################
# This is generated function sample.
#
# Usage:
#   GeneratedFunctionSample --id 1001 --type type-a [ --name xshoji --city tokyo --dry-run --read-only ]
# 
# Required arguments:
#   --id 1001 : 1001 is specified as id
#   --type type-a : [ type-a | type-b ]
# 
# Optional arguments:
#   --name xshoji : xshoji is specified as name
#   --city tokyo : City.
#   --dry-run : Enable dry-run flag
#   --read-only : Read only mode.
#######################################
function GeneratedFunctionSample() {
    # Argument parsing
    local _ARG=""; local _SHIFT=""; local _INVALID_STATE=""
    local ID="";    local TYPE="";    local NAME="";    local CITY="";    local DRY-RUN="";    local READ-ONLY="";
    for _ARG in "$@"; do local _SHIFT="true"; [ "${_ARG}" == "--id" ] && { shift 1; ID="${1}"; _SHIFT="false"; }; [ "${_ARG}" == "--type" ] && { shift 1; TYPE="${1}"; _SHIFT="false"; }; [ "${_ARG}" == "--name" ] && { shift 1; NAME="${1}"; _SHIFT="false"; }; [ "${_ARG}" == "--city" ] && { shift 1; CITY="${1}"; _SHIFT="false"; }; [ "${_ARG}" == "--dry-run" ] && { shift 1; DRY-RUN="true"; _SHIFT="false"; }; [ "${_ARG}" == "--read-only" ] && { shift 1; READ-ONLY="true"; _SHIFT="false"; }; ([ "${_SHIFT}" == "true" ] && [ "$#" -gt 0 ]) && { shift 1; }; done
    # Check required arguments
    [ "${ID}" == "" ] && { echo "[!] GeneratedFunctionSample() requires --id "; _INVALID_STATE="true"; }
    [ "${TYPE}" == "" ] && { echo "[!] GeneratedFunctionSample() requires --type "; _INVALID_STATE="true"; }
    # Check invalid state
    [ "${_INVALID_STATE}" == "true" ] && { exit 1; }
    
    # Main
    echo ""
    echo "GeneratedFunctionSample()"
    echo "  Required arguments"
    echo "    - id: ${ID}"
    echo "    - type: ${TYPE}"
    echo "  Optional arguments"
    echo "    - name: ${NAME}"
    echo "    - city: ${CITY}"
    echo "    - dry-run: ${DRY-RUN}"
    echo "    - read-only: ${READ-ONLY}"
    echo ""
}


# STARTER_URL=https://raw.githubusercontent.com/xshoji/bash-script-starter/master/FunctionStarter.sh
# curl -sf ${STARTER_URL} |bash -s - \
#   -n GeneratedFunctionSample \
#   -a xshoji \
#   -d "This is generated function sample." \
#   -r id,1001 \
#   -r type,type-a,"[ type-a | type-b ]" \
#   -o name,xshoji \
#   -o city,tokyo,"City." \
#   -f dry-run \
#   -f read-only,"Read only mode." \
#   -s > GeneratedFunctionSample.sh
