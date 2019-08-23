#!/bin/bash

function usage()
{
cat << _EOT_

 FunctionStarter
-------------------- author: xshoji

This script generates a template of bash function.

Usage:
  ./$(basename "$0") --naming scriptName [ --description Description --required paramName,sample,description --optional paramName,sample,description,defaultValue(omittable) --flag flagName,description ]

Required:
  -n, --naming scriptName : Script name.

Optional:
  -d, --description Description                                       : Description of this script. [ example: --description "ScriptStarter's description here." ]
  -r, --required paramName,sample,description                         : Required parameter setting. [ example: --required id,1001,"Primary id here." ]
  -o, --optional paramName,sample,description,defaultValue(omittable) : Optional parameter setting. [ example: --option name,xshoji,"User name here.",defaultUser ]
  -f, --flag flagName,description                                     : Optional flag parameter setting. [ example: --flag dryRun,"Dry run mode." ]
  --debug : Enable debug mode

_EOT_
  [[ "${1+x}" != "" ]] && { exit "${1}"; }
  exit 1
}
function printColored() { C=""; case "${1}" in "Yellow") C="\033[0;33m";; "Green") C="\033[0;32m";; esac; printf "%b%b\033[0m" "${C}" "${2}"; }



# Parse parameters
ARGS_REQUIRED=()
ARGS_OPTIONAL=()
ARGS_FLAG=()
ARGS_DESCRIPTION=()

for ARG in "$@"
do
    SHIFT="true"
    { [[ "${ARG}" == "--debug" ]]; } && { shift 1; set -eux; SHIFT="false"; }
    { [[ "${ARG}" == "--naming" ]] || [[ "${ARG}" == "-n" ]]; } && { shift 1; NAMING="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--required" ]]    || [[ "${ARG}" == "-r" ]]; } && { shift 1; ARGS_REQUIRED+=("${1}"); SHIFT="false"; }
    { [[ "${ARG}" == "--optional" ]]    || [[ "${ARG}" == "-o" ]]; } && { shift 1; ARGS_OPTIONAL+=("${1}"); SHIFT="false"; }
    { [[ "${ARG}" == "--flag" ]]        || [[ "${ARG}" == "-f" ]]; } && { shift 1; ARGS_FLAG+=("${1}"); SHIFT="false"; }
    { [[ "${ARG}" == "--description" ]] || [[ "${ARG}" == "-d" ]]; } && { shift 1; ARGS_DESCRIPTION+=("${1}"); SHIFT="false"; }
    { [[ "${SHIFT}" == "true" ]] && [[ "$#" -gt 0 ]]; } && { shift 1; }
done
[[ -n "${HELP+x}" ]] && { usage 0; }
# Check required parameters
[[ -z "${NAMING+x}" ]] && { printColored Yellow "[!] --naming is required.\n"; INVALID_STATE="true"; }
# Check invalid state and display usage
[[ -n "${INVALID_STATE+x}" ]] && { usage; }
# Initialize optional variables
[[ -z "${DESCRIPTION+x}" ]] && { DESCRIPTION=""; }




FUNCTION_NAME="${NAMING}"

#==========================================
# Functions
#==========================================

function printFunctionDocumentBase() {

    echo "#######################################"
    local HAS_DESCRIPTION=""
    for ARG in "$@"
    do
      HAS_DESCRIPTION="true"
      echo "# ${ARG}"
    done
    [ "${HAS_DESCRIPTION}" == "true" ] && { echo "#"; }
    echo "# Usage:"

}



function printUsageExecutionExample() {

    # Add required parameters
    for ARG in "$@"
    do
        local PARAM_NAME=$(awk -F',' '{print $1}' <<<${1})
        local SAMPLE=$(awk -F',' '{print $2}' <<<${1})
        echo -n ' '"--${PARAM_NAME} ${SAMPLE}"
        shift 1
    done
}



function printUsageExecutionExampleFlag() {

    # Add required parameters
    for ARG in "$@"
    do
        local PARAM_NAME=$(awk -F',' '{print $1}' <<<${1})
        echo -n ' '"--${PARAM_NAME}"
        shift 1
    done
}




function printParameterDescription() {
    for ARG in "$@"
    do
        # - [csv - Printing column separated by comma using Awk command line - Stack Overflow](https://stackoverflow.com/questions/26842504/printing-column-separated-by-comma-using-awk-command-line)
        local PARAM_NAME=$(awk -F',' '{print $1}' <<<${1})
        local SAMPLE=$(awk -F',' '{print $2}' <<<${1})
        local DESCRIPTION=$(awk -F',' '{print $3}' <<<${1})
        local PARAM_NAME_SHORT=$(cut -c 1 <<<${PARAM_NAME})
        [ "${SAMPLE}" == "" ] && { SAMPLE=${PARAM_NAME}; }
        [ "${DESCRIPTION}" == "" ] && { DESCRIPTION="${SAMPLE} is specified as ${PARAM_NAME}"; }
        local IS_USED_SHORT_PARAM=$(grep "${PARAM_NAME_SHORT}" <<<$(echo ${ARGS_SHORT[@]+"${ARGS_SHORT[@]}"}) || true)
        echo -n "#   --${PARAM_NAME}"
        if [ "${SHORT}" == "true" ] && [ "${IS_USED_SHORT_PARAM}" == "" ]; then
            ARGS_SHORT+=("${PARAM_NAME_SHORT}")
            echo -n ",-${PARAM_NAME_SHORT}"
        fi
        echo " ${SAMPLE} : ${DESCRIPTION}"
        shift 1
    done
}



function printParameterDescriptionFlag() {
    for ARG in "$@"
    do
        local PARAM_NAME=$(awk -F',' '{print $1}' <<<${1})
        local PARAM_NAME_SHORT=$(cut -c 1 <<<${PARAM_NAME})
        local DESCRIPTION=$(awk -F',' '{print $2}' <<<${1})
        [ "${DESCRIPTION}" == "" ] && { DESCRIPTION="Enable ${PARAM_NAME} flag"; }
        local IS_USED_SHORT_PARAM=$(grep "${PARAM_NAME_SHORT}" <<<$(echo ${ARGS_SHORT[@]+"${ARGS_SHORT[@]}"}) || true)
        echo -n "#   --${PARAM_NAME}"
        if [ "${SHORT}" == "true" ] && [ "${IS_USED_SHORT_PARAM}" == "" ]; then
            ARGS_SHORT+=("${PARAM_NAME_SHORT}")
            echo -n ",-${PARAM_NAME_SHORT}"
        fi
        echo " : ${DESCRIPTION}"
        shift 1
    done
}



function printFunctionDocumentBottomPart() {
    echo "#######################################"
}

function printFunctionTopPart() {
    echo "function ${1}() {"
}

function printLocalDeclarationArgument() {
    for ARG in "$@"
    do
        local PARAM_NAME=$(awk -F',' '{print $1}' <<<${1})
        local VAR_NAME=$(echo ${PARAM_NAME} | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        echo '    local '${VAR_NAME}='""'
        shift 1
    done
}

function printParseArgument() {
    for ARG in "$@"
    do
        local PARAM_NAME=$(awk -F',' '{print $1}' <<<${1})
        local PARAM_NAME_SHORT=$(cut -c 1 <<<${1})
        local VAR_NAME=$(echo ${PARAM_NAME} | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        local CONDITION='[ "${_ARG}" == "--'"${PARAM_NAME}"'" ]'
        local IS_USED_SHORT_PARAM=$(grep "1${PARAM_NAME_SHORT}" <<<$(echo ${ARGS_SHORT[@]+"${ARGS_SHORT[@]}"}) || true)
        if [ "${SHORT}" == "true" ] && [ "${IS_USED_SHORT_PARAM}" == "" ]; then
            ARGS_SHORT+=("1${PARAM_NAME_SHORT}")
            CONDITION='('"${CONDITION}"' || [ "${_ARG}" == "-'"${PARAM_NAME_SHORT}"'" ])'
        fi
        echo '        '"${CONDITION}"' && { shift 1; '"${VAR_NAME}"'="${1}"; _SHIFT="false"; }'
        shift 1
    done
}


function printParseArgumentFlag() {
    for ARG in "$@"
    do
        local PARAM_NAME=$(awk -F',' '{print $1}' <<<${1})
        local PARAM_NAME_SHORT=$(cut -c 1 <<<${1})
        local VAR_NAME=$(echo ${PARAM_NAME} | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        local CONDITION='[ "${_ARG}" == "--'"${PARAM_NAME}"'" ]'
        local IS_USED_SHORT_PARAM=$(grep "1${PARAM_NAME_SHORT}" <<<$(echo ${ARGS_SHORT[@]+"${ARGS_SHORT[@]}"}) || true)
        if [ "${SHORT}" == "true" ] && [ "${IS_USED_SHORT_PARAM}" == "" ]; then
            ARGS_SHORT+=("1${PARAM_NAME_SHORT}")
            CONDITION='('"${CONDITION}"' || [ "${_ARG}" == "-'"${PARAM_NAME_SHORT}"'" ])'
        fi
        echo '        '"${CONDITION}"' && { shift 1; '"${VAR_NAME}"'="true"; _SHIFT="false"; }'
        shift 1
    done
}



function printCheckRequiredArgument() {
    for ARG in "$@"
    do
        local PARAM_NAME=$(awk -F',' '{print $1}' <<<${1})
        local VAR_NAME=$(echo ${PARAM_NAME} | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        echo '    [ "${'"${VAR_NAME}"'}" == "" ] && { echo "[!] '${FUNCTION_NAME}'() requires --'"${PARAM_NAME}"' "; _INVALID_STATE="true"; }'
        shift 1
    done
}


function printVariableRequired() {
    echo '    echo "  Required arguments"'
    for ARG in "$@"
    do
        local PARAM_NAME=$(awk -F',' '{print $1}' <<<${1})
        local VAR_NAME=$(echo ${PARAM_NAME} | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        echo '    echo "    - '"${PARAM_NAME}"': ${'"${VAR_NAME}"'}"'
        shift 1
    done
}

function printVariableOptional() {
    echo '    echo "  Optional arguments"'
    for ARG in "$@"
    do
        local PARAM_NAME=$(awk -F',' '{print $1}' <<<${1})
        local VAR_NAME=$(echo ${PARAM_NAME} | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        echo '    echo "    - '"${PARAM_NAME}"': ${'"${VAR_NAME}"'}"'
        shift 1
    done
}






#==========================================
# Main
#==========================================

# Print usage example
printFunctionDocumentBase ${ARGS_DESCRIPTION[@]+"${ARGS_DESCRIPTION[@]}"}
echo -n "#   ${FUNCTION_NAME}"

# - [Bash empty array expansion with `set -u` - Stack Overflow](https://stackoverflow.com/questions/7577052/bash-empty-array-expansion-with-set-u)
printUsageExecutionExample ${ARGS_REQUIRED[@]+"${ARGS_REQUIRED[@]}"}

if [ ${#ARGS_OPTIONAL[@]} -gt 0 ] || [ ${#ARGS_FLAG[@]} -gt 0 ]; then
    echo -n " ["
fi

printUsageExecutionExample ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}
printUsageExecutionExampleFlag ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}

if [ ${#ARGS_OPTIONAL[@]} -gt 0 ] || [ ${#ARGS_FLAG[@]} -gt 0 ]; then
    echo -n " ]"
fi
echo ""
echo "# "


if [ ${#ARGS_REQUIRED[@]} -gt 0 ]; then
    echo "# Required arguments:"
    printParameterDescription "${ARGS_REQUIRED[@]}"
    echo "# "
fi

echo "# Optional arguments:"
if [ ${#ARGS_OPTIONAL[@]} -gt 0 ] || [ ${#ARGS_FLAG[@]} -gt 0 ]; then
    printParameterDescription ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}
    printParameterDescriptionFlag ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}
fi

printFunctionDocumentBottomPart


printFunctionTopPart ${FUNCTION_NAME}


cat << "__EOT__"
    # Argument parsing
    local _ARG=""; local _SHIFT=""; local _INVALID_STATE=""
__EOT__

printLocalDeclarationArgument ${ARGS_REQUIRED[@]+"${ARGS_REQUIRED[@]}"}
printLocalDeclarationArgument ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}
printLocalDeclarationArgument ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}

cat << "__EOT__"
    for _ARG in "$@"
    do
        local _SHIFT="true"
__EOT__

printParseArgument ${ARGS_REQUIRED[@]+"${ARGS_REQUIRED[@]}"}
printParseArgument ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}
printParseArgumentFlag ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}

cat << "__EOT__"
        ([ "${_SHIFT}" == "true" ] && [ "$#" -gt 0 ]) && { shift 1; }
    done
__EOT__

[ ${#ARGS_REQUIRED[@]} -gt 0 ] && { echo "    # Check required arguments"; }
printCheckRequiredArgument ${ARGS_REQUIRED[@]+"${ARGS_REQUIRED[@]}"}

# Check invalid state
echo "    # Check invalid state"
echo '    [ "${_INVALID_STATE}" == "true" ] && { exit 1; }'
echo "    "
echo "    # Main"


if [ ${#ARGS_REQUIRED[@]} -gt 0 ] || [ ${#ARGS_OPTIONAL[@]} -gt 0 ] || [ ${#ARGS_FLAG[@]} -gt 0 ]; then
    echo '    echo ""'
    echo '    echo "'${FUNCTION_NAME}'()"'
    REQUIRED_EOT="true"
fi

if [ ${#ARGS_REQUIRED[@]} -gt 0 ]; then
    printVariableRequired "${ARGS_REQUIRED[@]}"
fi
if [ ${#ARGS_OPTIONAL[@]} -gt 0 ] || [ ${#ARGS_FLAG[@]} -gt 0 ]; then
    printVariableOptional ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"} ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}
fi

[ ! -z "${REQUIRED_EOT+x}" ] && { echo '    echo ""'; }

echo "}"


# STARTER_URL=https://raw.githubusercontent.com/xshoji/bash-script-starter/master/ScriptStarter.sh
# curl -sf ${STARTER_URL} |bash -s - \
#   -n FunctionStarter \
#   -a xshoji \
#   -d "This script generates a template of bash function." \
#   -r naming,scriptName,"Script name." \
#   -o description,"Description","Description of this script. [ example: --description \"ScriptStarter's description here.\" ]" \
#   -o required,"paramName\,sample\,description","Required parameter setting. [ example: --required id\,1001\,\"Primary id here.\" ]" \
#   -o optional,"paramName\,sample\,description\,defaultValue(omittable)","Optional parameter setting. [ example: --option name\,xshoji\,\"User name here.\"\,defaultUser ]" \
#   -o flag,"flagName\,description","Optional flag parameter setting. [ example: --flag dryRun\,\"Dry run mode.\" ]" \
#   -s > /tmp/test.sh; open /tmp/test.sh

