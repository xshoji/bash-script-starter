#!/bin/bash

function usage()
{
cat << _EOT_

 ScriptStarter
------------------ author: xshoji

Usage:
  ./$(basename "$0") --naming scriptName [ --author author --description Description --required paramName,sample,description --required ... --optional paramName,sample,description,defaultValue(omittable) --optional ... --flag flagName,description --flag ... --env variableName,sample --env ... --short ]

Description:
  This script generates a template of bash script tool.

Required:
  -n, --naming scriptName : Script name.

Optional:
  -a, --author author                                                 : Script author. [ default: anonymous ]
  -d, --description Description                                       : Description of this script. [ example: --description "ScriptStarter's description here." ]
  -r, --required paramName,sample,description                         : Required parameter setting. [ example: --required id,1001,"Primary id here." ]
  -o, --optional paramName,sample,description,defaultValue(omittable) : Optional parameter setting. [ example: --option name,xshoji,"User name here.",defaultUser ]
  -f, --flag flagName,description                                     : Optional flag parameter setting. [ example: --flag dryRun,"Dry run mode." ]
  -e, --env variableName,sample                                       : Required environment variable. [ example: --env API_HOST,example.com ]
  -s, --short : Enable short parameter. [ example: --short ]
  --debug : Enable debug mode

_EOT_
  [[ "${1+x}" != "" ]] && { exit "${1}"; }
  exit 1
}





#==========================================
# Preparation
#==========================================

set -eu

# Parse parameters
RANDOM_STRING="k4PxCCMcdIdvj0T"
ARGS_REQUIRED=()
ARGS_OPTIONAL=()
ARGS_FLAG=()
ARGS_ENVIRONMENT=()
ARGS_SHORT=()
ARGS_DESCRIPTION=()

for ARG in "$@"
do
    SHIFT="true"
    { [[ "${ARG}" == "--debug" ]]; } && { shift 1; set -eux; SHIFT="false"; }
    { [[ "${ARG}" == "--naming" ]]      || [[ "${ARG}" == "-n" ]]; } && { shift 1; NAMING="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--author" ]]      || [[ "${ARG}" == "-a" ]]; } && { shift 1; AUTHOR="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--required" ]]    || [[ "${ARG}" == "-r" ]]; } && { shift 1; ARGS_REQUIRED+=("${1}"); SHIFT="false"; }
    { [[ "${ARG}" == "--optional" ]]    || [[ "${ARG}" == "-o" ]]; } && { shift 1; ARGS_OPTIONAL+=("${1}"); SHIFT="false"; }
    { [[ "${ARG}" == "--flag" ]]        || [[ "${ARG}" == "-f" ]]; } && { shift 1; ARGS_FLAG+=("${1}"); SHIFT="false"; }
    { [[ "${ARG}" == "--env" ]]         || [[ "${ARG}" == "-e" ]]; } && { shift 1; ARGS_ENVIRONMENT+=("${1}"); SHIFT="false"; }
    { [[ "${ARG}" == "--short" ]]       || [[ "${ARG}" == "-s" ]]; } && { shift 1; SHORT="true"; SHIFT="false"; }
    { [[ "${ARG}" == "--description" ]] || [[ "${ARG}" == "-d" ]]; } && { shift 1; ARGS_DESCRIPTION+=("${1}"); SHIFT="false"; }
    { [[ "${SHIFT}" == "true" ]] && [[ "$#" -gt 0 ]]; } && { shift 1; }
done
[[ -n "${HELP+x}" ]] && { usage 0; }
# Check required parameters
[[ -z "${NAMING+x}" ]] && { echo "[!] --naming is required. "; INVALID_STATE="true"; }
# Check invalid state and display usage
[[ -n "${INVALID_STATE+x}" ]] && { usage; }
# Initialize optional variables
[[ -z "${AUTHOR+x}" ]] && { AUTHOR="anonymous"; }
[[ -z "${DESCRIPTION+x}" ]] && { DESCRIPTION=""; }
[[ -z "${SHORT+x}" ]] && { SHORT="false"; }

# Define constant variable
PROVISIONAL_STRING=$(openssl rand -hex 12 | fold -w 12 | head -1)
BASE_INDENT=""

#==========================================
# Functions
#==========================================

function printUsageFunctionTopPart() {

cat << __EOT__
#!/bin/bash

function usage()
{
cat << _EOT_

${BASE_INDENT} ${1}
__EOT__

echo -n "${BASE_INDENT}"
local NAME_LENGTH=${#1}
NAME_LENGTH=$((NAME_LENGTH + 5))
COMMAND="printf -- '-%.0s' {1..${NAME_LENGTH}}"
eval "${COMMAND}"
echo " author: ${2}"
echo ""

}

function parseValue() {
  echo "${1}" |sed "s/\\\,/${RANDOM_STRING}/g" |awk -F',' '{print $'"${2}"'}' |sed "s/${RANDOM_STRING}/,/g"
}

function printUsageExecutionExampleBase() {

    echo "${BASE_INDENT}Usage:"
    echo -n "${BASE_INDENT}  ./\$(basename \"\$0\")"

}



function printUsageExecutionExample() {
    local PARAM_NAME
    local SAMPLE
    # Add required parameters
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        SAMPLE=$(parseValue "${1}" 2)
        echo -n ' '"--${PARAM_NAME} ${SAMPLE}"
        shift 1
    done
}



function printUsageExecutionExampleFlag() {
    local PARAM_NAME
    # Add required parameters
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        echo -n ' '"--${PARAM_NAME}"
        shift 1
    done
}



function printScriptDescription() {
cat << __EOT__

${BASE_INDENT}Description:
__EOT__
    local PRINTED_DESCRIPTIONS=()
    if [[ ${#ARGS_DESCRIPTION[@]} -gt 0 ]]; then
        PRINTED_DESCRIPTIONS=("${ARGS_DESCRIPTION[@]}")
    else
        PRINTED_DESCRIPTIONS+=("This is ${NAMING}")
    fi
    for PRINTED_DESCRIPTION in "${PRINTED_DESCRIPTIONS[@]}"
    do
        echo "${BASE_INDENT}  ${PRINTED_DESCRIPTION}"
    done
    echo ""
}


function printEnvironmentVariableDescription() {
    local PARAM_NAME
    local SAMPLE
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        SAMPLE=$(parseValue "${1}" 2)
        echo "${BASE_INDENT}  export ${PARAM_NAME}=${SAMPLE}"
        shift 1
    done
}


function printParameterDescription() {
    local PARAMETER_SAMPLE_LENGTH_MAX
    local PARAMETER_DESCRIPTION_LINES
    local CURRENT_PARAM_SAMPLE_STRING

    PARAMETER_SAMPLE_LENGTH_MAX=0
    PARAMETER_DESCRIPTION_LINES=()
    for DESCRIPTION_LINE in "$@"
    do
        CURRENT_PARAM_SAMPLE_STRING=$(echo "${DESCRIPTION_LINE}" |sed "s/${PROVISIONAL_STRING}.*//g")
        SAMPLE_STRING_LENGTH="${#CURRENT_PARAM_SAMPLE_STRING}"
        if [[ "${PARAMETER_SAMPLE_LENGTH_MAX}" -lt "${SAMPLE_STRING_LENGTH}" ]]; then
            PARAMETER_SAMPLE_LENGTH_MAX=${SAMPLE_STRING_LENGTH}
        fi
    done

    local CURRENT_PARAM_SAMPLE_STRING
    local CURRENT_LINE_LENGTH
    local DIFF_SPACE_LENGTH
    for DESCRIPTION_LINE in "$@"
    do
        CURRENT_PARAM_SAMPLE_STRING=$(echo "${DESCRIPTION_LINE}" |sed "s/${PROVISIONAL_STRING}.*//g")
        CURRENT_LINE_LENGTH="${#CURRENT_PARAM_SAMPLE_STRING}"
        DIFF_SPACE_LENGTH=$(( PARAMETER_SAMPLE_LENGTH_MAX -  CURRENT_LINE_LENGTH ))
        CREATE_SPACE_COMMAND="printf ' %.0s' {0..${DIFF_SPACE_LENGTH}}"
        DIFF_SPACE_STRING=$(eval "${CREATE_SPACE_COMMAND}")
        PRINTED_LINE=$(echo "${DESCRIPTION_LINE}" |sed "s/${PROVISIONAL_STRING}/${DIFF_SPACE_STRING}/g")
        echo "${BASE_INDENT}  ${PRINTED_LINE}"
    done
}

function printParameterDescriptionRequired() {

    local PARAMETER_DESCRIPTION_LINES=()
    local PARAM_NAME
    local SAMPLE
    local DESCRIPTION
    local PARAM_NAME_SHORT
    local IS_USED_SHORT_PARAM
    local LINE
    for ARG in "$@"
    do
        # - [csv - Printing column separated by comma using Awk command line - Stack Overflow](https://stackoverflow.com/questions/26842504/printing-column-separated-by-comma-using-awk-command-line)
        PARAM_NAME=$(parseValue "${1}" 1)
        SAMPLE=$(parseValue "${1}" 2)
        DESCRIPTION=$(parseValue "${1}" 3)
        PARAM_NAME_SHORT=$(cut -c 1 <<<"${PARAM_NAME}")
        [[ "${SAMPLE}" == "" ]] && { SAMPLE=${PARAM_NAME}; }
        [[ "${DESCRIPTION}" == "" ]] && { DESCRIPTION="\"${SAMPLE}\" means ${PARAM_NAME}"; }
        IS_USED_SHORT_PARAM=$(grep "${PARAM_NAME_SHORT}" <<<$(echo ${ARGS_SHORT[@]+"${ARGS_SHORT[@]}"}) || true)
        LINE=$(echo -n "--${PARAM_NAME}")
        if [[ "${SHORT}" == "true" ]] && [[ "${IS_USED_SHORT_PARAM}" == "" ]]; then
            ARGS_SHORT+=("${PARAM_NAME_SHORT}")
            LINE=$(echo -n "-${PARAM_NAME_SHORT}, ${LINE}")
        fi
        LINE=$(echo -n "${LINE} ${SAMPLE}")
        LINE=$(echo -n "${LINE}${PROVISIONAL_STRING}: ${DESCRIPTION}")
        PARAMETER_DESCRIPTION_LINES+=( "${LINE}" )
        shift 1
    done

    printParameterDescription "${PARAMETER_DESCRIPTION_LINES[@]}"
}



function printParameterDescriptionOptional() {

    local PARAM_NAME
    local SAMPLE
    local DESCRIPTION
    local DEFAULT
    local PARAM_NAME_SHORT
    local IS_USED_SHORT_PARAM
    local LINE
    local PARAMETER_DESCRIPTION_LINES=()
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        SAMPLE=$(parseValue "${1}" 2)
        DESCRIPTION=$(parseValue "${1}" 3)
        DEFAULT=$(parseValue "${1}" 4)
        PARAM_NAME_SHORT=$(cut -c 1 <<<"${PARAM_NAME}")
        [[ "${SAMPLE}" == "" ]] && { SAMPLE="${PARAM_NAME}"; }
        [[ "${DESCRIPTION}" == "" ]] && { DESCRIPTION="\"${SAMPLE}\" means ${PARAM_NAME}"; }
        IS_USED_SHORT_PARAM=$(grep "${PARAM_NAME_SHORT}" <<<$(echo ${ARGS_SHORT[@]+"${ARGS_SHORT[@]}"}) || true)
        LINE=$(echo -n "--${PARAM_NAME}")
        if [[ "${SHORT}" == "true" ]] && [[ "${IS_USED_SHORT_PARAM}" == "" ]]; then
            ARGS_SHORT+=("${PARAM_NAME_SHORT}")
            LINE=$(echo -n "-${PARAM_NAME_SHORT}, ${LINE}")
        fi
        LINE=$(echo -n "${LINE} ${SAMPLE}")
        LINE=$(echo -n "${LINE}${PROVISIONAL_STRING}: ${DESCRIPTION}")
        [[ "${DEFAULT}" != "" ]] && { LINE=$(echo -n "${LINE} [ default: ${DEFAULT} ]"); }
        PARAMETER_DESCRIPTION_LINES+=( "${LINE}" )
        shift 1
    done

    printParameterDescription "${PARAMETER_DESCRIPTION_LINES[@]}"
}



function printParameterDescriptionFlag() {

    local PARAM_NAME
    local PARAM_NAME_SHORT
    local DESCRIPTION
    local IS_USED_SHORT_PARAM
    local LINE
    local PARAMETER_DESCRIPTION_LINES=()
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        PARAM_NAME_SHORT=$(cut -c 1 <<<"${PARAM_NAME}")
        DESCRIPTION=$(parseValue "${1}" 2)
        [[ "${DESCRIPTION}" == "" ]] && { DESCRIPTION="Enable ${PARAM_NAME} flag"; }
        IS_USED_SHORT_PARAM=$(grep "${PARAM_NAME_SHORT}" <<<$(echo ${ARGS_SHORT[@]+"${ARGS_SHORT[@]}"}) || true)
        LINE=$(echo -n "--${PARAM_NAME}")
        if [[ "${SHORT}" == "true" ]] && [[ "${IS_USED_SHORT_PARAM}" == "" ]]; then
            ARGS_SHORT+=("${PARAM_NAME_SHORT}")
            LINE=$(echo -n "-${PARAM_NAME_SHORT}, ${LINE}")
        fi
        LINE=$(echo -n "${LINE}${PROVISIONAL_STRING}: ${DESCRIPTION}")
        PARAMETER_DESCRIPTION_LINES+=( "${LINE}" )
        shift 1
    done

    printParameterDescription "${PARAMETER_DESCRIPTION_LINES[@]}"
}



function printUsageFunctionBottomPart() {
cat << __EOT__
_EOT_
  [[ "\${1+x}" != "" ]] && { exit "\${1}"; }
  exit 1
}

__EOT__
}

function printParseArgument() {
    local PARAM_NAME
    local PARAM_NAME_SHORT
    local VAR_NAME
    local CONDITION
    local IS_USED_SHORT_PARAM
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        PARAM_NAME_SHORT=$(cut -c 1 <<<"${1}")
        VAR_NAME=$(echo "${PARAM_NAME}" | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        CONDITION='[[ "${ARG}" == "--'"${PARAM_NAME}"'" ]]'
        IS_USED_SHORT_PARAM=$(grep "1${PARAM_NAME_SHORT}" <<<$(echo ${ARGS_SHORT[@]+"${ARGS_SHORT[@]}"}) || true)
        if [[ "${SHORT}" == "true" ]] && [[ "${IS_USED_SHORT_PARAM}" == "" ]]; then
            [[ "${PARAM_NAME_SHORT}" == "h" ]] && { HELP_SHORT_PARAM_ENABLE="false"; }
            ARGS_SHORT+=("1${PARAM_NAME_SHORT}")
            CONDITION='{ '"${CONDITION}"' || [[ "${ARG}" == "-'"${PARAM_NAME_SHORT}"'" ]]; }'
        fi
        echo '    '"${CONDITION}"' && { shift 1; '"${VAR_NAME}"'="${1}"; SHIFT="false"; }'
        shift 1
    done
}


function printParseArgumentFlag() {
    local PARAM_NAME
    local PARAM_NAME_SHORT
    local VAR_NAME
    local CONDITION
    local IS_USED_SHORT_PARAM
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        PARAM_NAME_SHORT=$(cut -c 1 <<<"${1}")
        VAR_NAME=$(echo "${PARAM_NAME}" | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        CONDITION='[[ "${ARG}" == "--'"${PARAM_NAME}"'" ]]'
        IS_USED_SHORT_PARAM=$(grep "1${PARAM_NAME_SHORT}" <<<$(echo ${ARGS_SHORT[@]+"${ARGS_SHORT[@]}"}) || true)
        if [[ "${SHORT}" == "true" ]] && [[ "${IS_USED_SHORT_PARAM}" == "" ]]; then
            [[ "${PARAM_NAME_SHORT}" == "h" ]] && { HELP_SHORT_PARAM_ENABLE="false"; }
            ARGS_SHORT+=("1${PARAM_NAME_SHORT}")
            CONDITION='{ '"${CONDITION}"' || [[ "${ARG}" == "-'"${PARAM_NAME_SHORT}"'" ]]; }'
        fi
        echo '    '"${CONDITION}"' && { shift 1; '"${VAR_NAME}"'="true"; SHIFT="false"; }'
        shift 1
    done
}



function printCheckRequiredEnvironmentVariable() {
    local VAR_NAME
    local SAMPLE
    for ARG in "$@"
    do
        VAR_NAME=$(parseValue "${1}" 1)
        SAMPLE=$(parseValue "${1}" 2)
        echo '[[ -z "${'"${VAR_NAME}"'+x}" ]] && { echo "[!] export '"${VAR_NAME}"'='"${SAMPLE}"' is required. "; INVALID_STATE="true"; }'
        shift 1
    done
}


function printCheckRequiredArgument() {
    local PARAM_NAME
    local VAR_NAME
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        VAR_NAME=$(echo "${PARAM_NAME}" | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        echo '[[ -z "${'"${VAR_NAME}"'+x}" ]] && { echo "[!] --'"${PARAM_NAME}"' is required. "; INVALID_STATE="true"; }'
        shift 1
    done
}

function printSetInitialValueOptional() {
    local PARAM_NAME
    local SAMPLE
    local DESCRIPTION
    local DEFAULT
    local PARAM_NAME_SHORT
    local VAR_NAME
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        SAMPLE=$(parseValue "${1}" 2)
        DESCRIPTION=$(parseValue "${1}" 3)
        DEFAULT=$(parseValue "${1}" 4)
        PARAM_NAME_SHORT=$(cut -c 1 <<<"${PARAM_NAME}")
        [[ "${SAMPLE}" == "" ]] && { SAMPLE="${PARAM_NAME}"; }
        VAR_NAME=$(echo "${PARAM_NAME}" | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        echo '[[ -z "${'"${VAR_NAME}"'+x}" ]] && { '"${VAR_NAME}"=\""${DEFAULT}"\"'; }'
        shift 1
    done
}

function printSetInitialValueFlag() {
    local PARAM_NAME
    local VAR_NAME
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        VAR_NAME=$(echo "${PARAM_NAME}" | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        echo '[[ -z "${'"${VAR_NAME}"'+x}" ]] && { '"${VAR_NAME}"=\"'false'\"'; }'
        shift 1
    done
}

function printVariableEnvironment() {
    local VAR_NAME
    echo "[ Environment variables ]"
    for ARG in "$@"
    do
        VAR_NAME=$(parseValue "${1}" 1)
        echo "${VAR_NAME}"': ${'"${VAR_NAME}"'}'
        shift 1
    done
    echo ""
}


function printVariableRequired() {
    local PARAM_NAME
    local VAR_NAME
    echo "[ Required parameters ]"
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        VAR_NAME=$(echo "${PARAM_NAME}" | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        echo "${PARAM_NAME}"': ${'"${VAR_NAME}"'}'
        shift 1
    done
    echo ""
}

function printVariableOptional() {
    local PARAM_NAME
    local VAR_NAME
    echo "[ Optional parameters ]"
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        VAR_NAME=$(echo "${PARAM_NAME}" | perl -pe 's/(?:^|_)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}')
        echo "${PARAM_NAME}"': ${'"${VAR_NAME}"'}'
        shift 1
    done
    echo ""
}






#==========================================
# Main
#==========================================

printUsageFunctionTopPart "${NAMING}" "${AUTHOR}"



# Print usage example
printUsageExecutionExampleBase

# - [Bash empty array expansion with `set -u` - Stack Overflow](https://stackoverflow.com/questions/7577052/bash-empty-array-expansion-with-set-u)
printUsageExecutionExample ${ARGS_REQUIRED[@]+"${ARGS_REQUIRED[@]}"}

if [[ ${#ARGS_OPTIONAL[@]} -gt 0 ]] || [[ ${#ARGS_FLAG[@]} -gt 0 ]]; then
    echo -n " ["
fi

printUsageExecutionExample ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}
printUsageExecutionExampleFlag ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}

if [[ ${#ARGS_OPTIONAL[@]} -gt 0 ]] || [[ ${#ARGS_FLAG[@]} -gt 0 ]]; then
    echo -n " ]"
fi
echo ""



# Print script description
printScriptDescription



# Print parameter description
if [[ ${#ARGS_ENVIRONMENT[@]} -gt 0 ]]; then
    echo "${BASE_INDENT}Environment variables: "
    printEnvironmentVariableDescription "${ARGS_ENVIRONMENT[@]}"
    echo " "
fi

if [[ ${#ARGS_REQUIRED[@]} -gt 0 ]]; then
    echo "${BASE_INDENT}Required:"
    printParameterDescriptionRequired "${ARGS_REQUIRED[@]}"
    echo " "
fi

echo "${BASE_INDENT}Optional:"
if [[ ${#ARGS_OPTIONAL[@]} -gt 0 ]]; then
    printParameterDescriptionOptional ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}
fi
if [[ ${#ARGS_FLAG[@]} -gt 0 ]]; then
    printParameterDescriptionFlag ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}
fi

echo "${BASE_INDENT}  --debug : Enable debug mode"
echo ""

printUsageFunctionBottomPart


cat << "__EOT__"



#------------------------------------------
# Preparation
#------------------------------------------
set -eu

# Parse parameters
for ARG in "$@"
do
    SHIFT="true"
    [[ "${ARG}" == "--debug" ]] && { shift 1; set -eux; SHIFT="false"; }
__EOT__

HELP_SHORT_PARAM_ENABLE="true"
printParseArgument ${ARGS_REQUIRED[@]+"${ARGS_REQUIRED[@]}"}
printParseArgument ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}
printParseArgumentFlag ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}

HELP_PARSER='    [[ "${ARG}" == "--help" ]] && { shift 1; HELP="true"; SHIFT="false"; }'
if [[ ${HELP_SHORT_PARAM_ENABLE} == "true" ]]; then
  HELP_PARSER='    { [[ "${ARG}" == "--help" ]] || [[ "${ARG}" == "-h" ]]; } && { shift 1; HELP="true"; SHIFT="false"; }'
fi
echo "${HELP_PARSER}"

cat << "__EOT__"
    { [[ "${SHIFT}" == "true" ]] && [[ "$#" -gt 0 ]]; } && { shift 1; }
done
__EOT__

# Help mode
echo '[[ -n "${HELP+x}" ]] && { usage 0; }'

[[ ${#ARGS_ENVIRONMENT[@]} -gt 0 ]] && { echo "# Check environment variables"; }
printCheckRequiredEnvironmentVariable ${ARGS_ENVIRONMENT[@]+"${ARGS_ENVIRONMENT[@]}"}
[[ ${#ARGS_REQUIRED[@]} -gt 0 ]] && { echo "# Check required parameters"; }
printCheckRequiredArgument ${ARGS_REQUIRED[@]+"${ARGS_REQUIRED[@]}"}

# Check invalid state
echo "# Check invalid state and display usage"
echo '[[ -n "${INVALID_STATE+x}" ]] && { usage; }'

if [[ ${#ARGS_OPTIONAL[@]} -gt 0 ]] || [[ ${#ARGS_FLAG[@]} -gt 0 ]]; then
    echo "# Initialize optional variables"
fi
printSetInitialValueOptional ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}
printSetInitialValueFlag ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}

cat << __EOT__



#------------------------------------------
# Main
#------------------------------------------

__EOT__


if [[ ${#ARGS_ENVIRONMENT[@]} -gt 0 ]] || [[ ${#ARGS_REQUIRED[@]} -gt 0 ]] || [[ ${#ARGS_OPTIONAL[@]} -gt 0 ]] || [[ ${#ARGS_FLAG[@]} -gt 0 ]]; then
    echo 'cat << __EOT__'
    echo ''
    REQUIRED_EOT="true"
fi

if [[ ${#ARGS_ENVIRONMENT[@]} -gt 0 ]]; then
    printVariableEnvironment "${ARGS_ENVIRONMENT[@]}"
fi
if [[ ${#ARGS_REQUIRED[@]} -gt 0 ]]; then
    printVariableRequired "${ARGS_REQUIRED[@]}"
fi
if [[ ${#ARGS_OPTIONAL[@]} -gt 0 ]] || [[ ${#ARGS_FLAG[@]} -gt 0 ]]; then
    printVariableOptional ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"} ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}
fi

[[ -n "${REQUIRED_EOT+x}" ]] && { echo '__EOT__'; }


#bash ~/Develop/bashscript/bash-script-starter/ScriptStarter.sh \
#  -n ScriptStarter \
#  -a xshoji \
#  -d "This script generates a template of bash script tool." \
#  -r naming,scriptName,"Script name." \
#  -o author,author,"Script author.",anonymous \
#  -o description,"Description","Description of this script. [ example: --description \"ScriptStarter's description here.\" ]" \
#  -o required,"paramName\,sample\,description","Required parameter setting. [ example: --required id\,1001\,\"Primary id here.\" ]" \
#  -o optional,"paramName\,sample\,description\,defaultValue(omittable)","Optional parameter setting. [ example: --option name\,xshoji\,\"User name here.\"\,defaultUser ]" \
#  -o flag,"flagName\,description","Optional flag parameter setting. [ example: --flag dryRun\,\"Dry run mode.\" ]" \
#  -o env,"variableName\,sample","Required environment variable. [ example: --env API_HOST\,example.com ]" \
#  -f short,"Enable short parameter. [ example: --short ]" \
#  -s > /tmp/test.sh
