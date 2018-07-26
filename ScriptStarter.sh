#!/bin/bash

function usage()
{
cat << "_EOT_"

   ScriptStarter   
  ------------------- author: xshoji

_EOT_
cat << _EOT_
  Usage:
    ./$(basename "$0") --naming scriptName --author name [ --description "ScriptStarter's description here." --required paramName,sample --required ... --option paramName,sample --option ... --flag flagName --flag ... --env varName,sample --env ... --short ]

  Description:
    This script generates a template of bash script tool.
 
  Required parameters:
    --naming,-n scriptName : Script name.
    --author,-a authorName : Script author.

  Optional parameters:
    --description,-d "Description" : Description of this script. [ example: --description "ScriptStarter's description here." ]
    --required,-r paramName,sample : Required parameter setting. [ example: --required id,1001 ]
    --option,-o paramName,sample   : Optional parameter setting. [ example: --option name,xshoji ]
    --flag,-f paramName            : Optional flag parameter setting. [ example: --flag dryRun ]
    --env,-e varName,sample        : Required environment variable. [ example: --env API_HOST,example.com ]
    --short,-s                     : Enable short parameter. [ example: --short ]

_EOT_
exit 1
}

#==========================================
# Preparation
#==========================================

set -eu

# Parse parameters
ARG_ORG=("$@")
ARGS_REQUIRED=()
ARGS_OPTIONAL=()
ARGS_FLAG=()
ARGS_ENVIRONMENT=()
ARGS_SHORT=()

for ARG in "$@"
do
    SHIFT="true"
    ([ "${ARG}" == "--debug" ]) && { shift 1; set -eux; SHIFT="false"; }
    ([ "${ARG}" == "--naming" ]      || [ "${ARG}" == "-n" ]) && { shift 1; SCRIPT_NAME=${1}; SHIFT="false"; }
    ([ "${ARG}" == "--author" ]      || [ "${ARG}" == "-a" ]) && { shift 1; AUTHOR=${1}; SHIFT="false"; }
    ([ "${ARG}" == "--required" ]    || [ "${ARG}" == "-r" ]) && { shift 1; ARGS_REQUIRED+=("${1}"); SHIFT="false"; }
    ([ "${ARG}" == "--option" ]      || [ "${ARG}" == "-o" ]) && { shift 1; ARGS_OPTIONAL+=("$1"); SHIFT="false"; }
    ([ "${ARG}" == "--flag" ]        || [ "${ARG}" == "-f" ]) && { shift 1; ARGS_FLAG+=(${1}); SHIFT="false"; }
    ([ "${ARG}" == "--env" ]         || [ "${ARG}" == "-e" ]) && { shift 1; ARGS_ENVIRONMENT+=(${1}); SHIFT="false"; }
    ([ "${ARG}" == "--short" ]       || [ "${ARG}" == "-s" ]) && { shift 1; SHORT="true"; SHIFT="false"; }
    ([ "${ARG}" == "--description" ] || [ "${ARG}" == "-d" ]) && { shift 1; DESCRIPTION=${1}; SHIFT="false"; }
    ([ "${SHIFT}" == "true" ] && [ "$#" -gt 0 ]) && { shift 1; }
done
# Check require parameters
[ -z "${SCRIPT_NAME+x}" ] && { echo "[!] --naming is required. "; INVALID_STATE="true"; }
[ -z "${AUTHOR+x}" ] && { echo "[!] --author is required. "; INVALID_STATE="true"; }
[ ! -z "${INVALID_STATE+x}" ] && { usage; exit 1; }
[ -z "${SHORT+x}" ] && { SHORT="false"; }
[ -z "${DESCRIPTION+x}" ] && { DESCRIPTION=""; }


#==========================================
# Functions
#==========================================

function printUsageFunctionTopPart() {

local NAME_LENGTH=${#1}

cat << __EOT__
#!/bin/bash

function usage()
{
cat << _EOT_

   ${1}   
__EOT__

echo -n '  '
for ((i=0; i < ${NAME_LENGTH}+5; i++)); do
    echo -n '-'
done
echo " author: ${2}" 
echo ""

}

function printUsageExecutionExampleBase() {

    echo "  Usage:"
    echo -n '    ./$(basename "$0")'

}



function printUsageExecutionExample() {

    # Add required parameters
    for ARG in "$@"
    do
        local PARAM_NAME=$(cut -d',' -f 1 <<<${1})
        local SAMPLE=$(cut -d',' -f 2 <<<${1})
        echo -n ' '"--${PARAM_NAME} ${SAMPLE}"
        shift 1
    done
}



function printUsageExecutionExampleFlag() {

    # Add required parameters
    for ARG in "$@"
    do
        local PARAM_NAME=$(cut -d',' -f 1 <<<${1})
        echo -n ' '"--${PARAM_NAME}"
        shift 1
    done
}



function printScriptDescription() {
    if [ "${DESCRIPTION}" == "" ]; then
        local PRINTED_DESCRIPTION="This is ${SCRIPT_NAME}"
    else
        local PRINTED_DESCRIPTION="${DESCRIPTION}"
    fi
cat << __EOT__
 
  Description:
    ${PRINTED_DESCRIPTION}
 
__EOT__
}


function printEnvironmentVariableDescription() {
    for ARG in "$@"
    do
        local PARAM_NAME=$(cut -d',' -f 1 <<<${1})
        local SAMPLE=$(cut -d',' -f 2 <<<${1})
        echo "    export ${PARAM_NAME}=${SAMPLE}"
        shift 1
    done
}



function printParameterDescription() {
    for ARG in "$@"
    do
        local PARAM_NAME=$(cut -d',' -f 1 <<<${1})
        local SAMPLE=$(cut -d',' -f 2 <<<${1})
        local PARAM_NAME_SHORT=$(cut -c 1 <<<${1})
        local IS_USED_SHORT_PARAM=$(grep "${PARAM_NAME_SHORT}" <<<$(echo ${ARGS_SHORT[@]+"${ARGS_SHORT[@]}"}) || true)
        echo -n "    --${PARAM_NAME}"
        if [ "${SHORT}" == "true" ] && [ "${IS_USED_SHORT_PARAM}" == "" ]; then
            ARGS_SHORT+=("${PARAM_NAME_SHORT}")
            echo -n ",-${PARAM_NAME_SHORT}"
        fi
        echo " ${SAMPLE} : ${SAMPLE} is specified as ${PARAM_NAME}"
        shift 1
    done
}



function printParameterDescriptionFlag() {
    for ARG in "$@"
    do
        local PARAM_NAME=$(cut -d',' -f 1 <<<${1})
        local PARAM_NAME_SHORT=$(cut -c 1 <<<${1})
        local IS_USED_SHORT_PARAM=$(grep "${PARAM_NAME_SHORT}" <<<$(echo ${ARGS_SHORT[@]+"${ARGS_SHORT[@]}"}) || true)
        echo -n "    --${PARAM_NAME}"
        if [ "${SHORT}" == "true" ] && [ "${IS_USED_SHORT_PARAM}" == "" ]; then
            ARGS_SHORT+=("${PARAM_NAME_SHORT}")
            echo -n ",-${PARAM_NAME_SHORT}"
        fi
        echo " : Enable ${PARAM_NAME} flag"
        shift 1
    done
}



function printUsageFunctionBottomPart() {
cat << __EOT__
_EOT_
exit 1
}

__EOT__
}

function printParseArgument() {
    for ARG in "$@"
    do
        local PARAM_NAME=$(cut -d',' -f 1 <<<${1})
        local PARAM_NAME_SHORT=$(cut -c 1 <<<${1})
        local VAR_NAME=$(echo ${PARAM_NAME} | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        local CONDITION='[ "${ARG}" == "--'"${PARAM_NAME}"'" ]'
        local IS_USED_SHORT_PARAM=$(grep "1${PARAM_NAME_SHORT}" <<<$(echo ${ARGS_SHORT[@]+"${ARGS_SHORT[@]}"}) || true)
        if [ "${SHORT}" == "true" ] && [ "${IS_USED_SHORT_PARAM}" == "" ]; then
            ARGS_SHORT+=("1${PARAM_NAME_SHORT}")
            CONDITION='('"${CONDITION}"' || [ "${ARG}" == "-'"${PARAM_NAME_SHORT}"'" ])'
        fi
        echo '    '"${CONDITION}"' && { shift 1; '"${VAR_NAME}"'=${1}; SHIFT="false"; }'
        shift 1
    done
}


function printParseArgumentFlag() {
    for ARG in "$@"
    do
        local PARAM_NAME=$(cut -d',' -f 1 <<<${1})
        local PARAM_NAME_SHORT=$(cut -c 1 <<<${1})
        local VAR_NAME=$(echo ${PARAM_NAME} | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        local CONDITION='[ "${ARG}" == "--'"${PARAM_NAME}"'" ]'
        local IS_USED_SHORT_PARAM=$(grep "1${PARAM_NAME_SHORT}" <<<$(echo ${ARGS_SHORT[@]+"${ARGS_SHORT[@]}"}) || true)
        if [ "${SHORT}" == "true" ] && [ "${IS_USED_SHORT_PARAM}" == "" ]; then
            ARGS_SHORT+=("1${PARAM_NAME_SHORT}")
            CONDITION='('"${CONDITION}"' || [ "${ARG}" == "-'"${PARAM_NAME_SHORT}"'" ])'
        fi
        echo '    '"${CONDITION}"' && { shift 1; '"${VAR_NAME}"'="true"; SHIFT="false"; }'
        shift 1
    done
}



function printCheckRequiredEnvironmentVariable() {
    for ARG in "$@"
    do
        local VAR_NAME=$(cut -d',' -f 1 <<<${1})
        local SAMPLE=$(cut -d',' -f 2 <<<${1})
        echo '[ -z "${'"${VAR_NAME}"'+x}" ] && { echo "[!] export '"${VAR_NAME}"'='"${SAMPLE}"' is required. "; INVALID_STATE="true"; }'
        shift 1
    done
}


function printCheckRequiredArgument() {
    for ARG in "$@"
    do
        local PARAM_NAME=$(cut -d',' -f 1 <<<${1})
        local VAR_NAME=$(echo ${PARAM_NAME} | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        echo '[ -z "${'"${VAR_NAME}"'+x}" ] && { echo "[!] --'"${PARAM_NAME}"' is required. "; INVALID_STATE="true"; }'
        shift 1
    done
}

function printSetInitialValue() {
    for ARG in "$@"
    do
        local PARAM_NAME=$(cut -d',' -f 1 <<<${1})
        local VAR_NAME=$(echo ${PARAM_NAME} | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        echo '[ -z "${'"${VAR_NAME}"'+x}" ] && { '"${VAR_NAME}"=\"\"'; }'
        shift 1
    done
}

function printVariableEnvironment() {
    echo 'echo "[ Environment variables ]"'
    for ARG in "$@"
    do
        local VAR_NAME=$(cut -d',' -f 1 <<<${1})
        echo 'echo "'"${VAR_NAME}"': ${'"${VAR_NAME}"'}"'
        shift 1
    done
    echo 'echo ""'
}


function printVariableRequired() {
    echo 'echo "[ Required parameters ]"'
    for ARG in "$@"
    do
        local PARAM_NAME=$(cut -d',' -f 1 <<<${1})
        local VAR_NAME=$(echo ${PARAM_NAME} | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        echo 'echo "'"${PARAM_NAME}"': ${'"${VAR_NAME}"'}"'
        shift 1
    done
    echo 'echo ""'
}

function printVariableOptional() {
    echo 'echo "[ Optional parameters ]"'
    for ARG in "$@"
    do
        local PARAM_NAME=$(cut -d',' -f 1 <<<${1})
        local VAR_NAME=$(echo ${PARAM_NAME} | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        echo 'echo "'"${PARAM_NAME}"': ${'"${VAR_NAME}"'}"'
        shift 1
    done
    echo 'echo ""'
}






#==========================================
# Main
#==========================================

printUsageFunctionTopPart ${SCRIPT_NAME} ${AUTHOR}



# Print usage example
printUsageExecutionExampleBase

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



# Print script description
printScriptDescription ${SCRIPT_NAME}



# Print parameter description
if [ ${#ARGS_ENVIRONMENT[@]} -gt 0 ]; then
    echo "  Environment settings are required such as follows,"
    printEnvironmentVariableDescription "${ARGS_ENVIRONMENT[@]}"
    echo " "
fi

if [ ${#ARGS_REQUIRED[@]} -gt 0 ]; then
    echo "  Required parameters:"
    printParameterDescription "${ARGS_REQUIRED[@]}"
    echo " "
fi

echo "  Optional parameters:"
if [ ${#ARGS_OPTIONAL[@]} -gt 0 ] || [ ${#ARGS_FLAG[@]} -gt 0 ]; then
    printParameterDescription ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}
    printParameterDescriptionFlag ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}
fi
echo "    --debug : Enable debug mode"
echo ""

printUsageFunctionBottomPart


[ ${#ARGS_ENVIRONMENT[@]} -gt 0 ] && { echo "# Check environment variables"; }
printCheckRequiredEnvironmentVariable ${ARGS_ENVIRONMENT[@]+"${ARGS_ENVIRONMENT[@]}"}
cat << "__EOT__"



#------------------------------------------
# Preparation
#------------------------------------------
set -eu

# Parse parameters
for ARG in "$@"
do
    SHIFT="true"
    [ "${ARG}" == "--debug" ] && { shift 1; set -eux; SHIFT="false"; }
    ([ "${ARG}" == "--help" ] || [ "${ARG}" == "-h" ]) && { shift 1; IS_HELP="true"; SHIFT="false"; }
__EOT__

printParseArgument ${ARGS_REQUIRED[@]+"${ARGS_REQUIRED[@]}"}
printParseArgument ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}
printParseArgumentFlag ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}

cat << "__EOT__"
    ([ "${SHIFT}" == "true" ] && [ "$#" -gt 0 ]) && { shift 1; }
done
__EOT__


[ ${#ARGS_REQUIRED[@]} -gt 0 ] && { echo "# Check required parameters"; }
printCheckRequiredArgument ${ARGS_REQUIRED[@]+"${ARGS_REQUIRED[@]}"}
echo '[ ! -z "${INVALID_STATE+x}" ] && { usage; exit 1; }'
echo '[ ! -z "${IS_HELP+x}" ] && { usage; exit 0; }'
if [ ${#ARGS_OPTIONAL[@]} -gt 0 ] || [ ${#ARGS_FLAG[@]} -gt 0 ]; then
    echo "# Initialize optional variables"
fi
printSetInitialValue ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}
printSetInitialValue ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}

cat << __EOT__



#------------------------------------------
# Main
#------------------------------------------


__EOT__


if [ ${#ARGS_ENVIRONMENT[@]} -gt 0 ] || [ ${#ARGS_REQUIRED[@]} -gt 0 ] || [ ${#ARGS_OPTIONAL[@]} -gt 0 ] || [ ${#ARGS_FLAG[@]} -gt 0 ]; then
    echo 'echo ""'
fi

if [ ${#ARGS_ENVIRONMENT[@]} -gt 0 ]; then
    printVariableEnvironment "${ARGS_ENVIRONMENT[@]}"
fi
if [ ${#ARGS_REQUIRED[@]} -gt 0 ]; then
    printVariableRequired "${ARGS_REQUIRED[@]}"
fi
if [ ${#ARGS_OPTIONAL[@]} -gt 0 ] || [ ${#ARGS_FLAG[@]} -gt 0 ]; then
    printVariableOptional ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"} ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}
fi
