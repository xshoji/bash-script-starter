#!/bin/bash

function usage()
{
cat << _EOT_

 ScriptStarter
------------------ author: xshoji

This script generates a template of bash script tool.

Usage:
  ./$(basename "$0") --naming scriptName [ --author author --description Description --description ... --required paramName,sample,description --required ... --optional paramName,sample,description,defaultValue(omittable) --optional ... --flag flagName,description --flag ... --env variableName,sample --env ... --short  --keep-starter-parameters --protect-arguments ]

Required:
  -n, --naming scriptName : Script name.

Optional:
  -a, --author author                                                 : Script author.
  -d, --description Description                                       : Description of this script. [ example: --description "ScriptStarter's description here." ]
  -r, --required paramName,sample,description                         : Required parameter setting. [ example: --required id,1001,"Primary id here." ]
  -o, --optional paramName,sample,description,defaultValue(omittable) : Optional parameter setting. [ example: --option name,xshoji,"User name here.",defaultUser ]
  -f, --flag flagName,description                                     : Optional flag setting. [ example: --flag dryRun,"Dry run mode." ]
  -e, --env variableName,sample                                       : Required environment variable setting. [ example: --env API_HOST,example.com ]
  -s, --short                   : Enable short parameter. [ example: --short ]
  -k, --keep-starter-parameters : Keep parameter details of bash-script-starter in the generated scprit. [ example: --keep-starter-parameters ]
  -p, --protect-arguments       : Declare argument variables as readonly. [ example: --protect-arguments ]

Helper options:
  --help, --debug

_EOT_
  [[ "${1+x}" != "" ]] && { exit "${1}"; }
  exit 1
}
function printColored() { local B="\033[0;"; local C=""; case "${1}" in "red") C="31m";; "green") C="32m";; "yellow") C="33m";; "blue") C="34m";; esac; printf "%b%b\033[0m" "${B}${C}" "${2}"; }





#==========================================
# Preparation
#==========================================

set -eu

# Parse parameters
ARGS_REQUIRED=()
ARGS_OPTIONAL=()
ARGS_FLAG=()
ARGS_ENVIRONMENT=()
ARGS_SHORT=()
ARGS_DESCRIPTION=()

readonly BASH_SCRIPT_STARTER_ARGS=("$@")
for ARG in "$@"
do
    SHIFT="true"
    { [[ "${ARG}" == "--debug" ]]; } && { shift 1; set -eux; SHIFT="false"; }
    { [[ "${ARG}" == "--naming" ]]                  || [[ "${ARG}" == "-n" ]]; } && { shift 1; NAMING="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--author" ]]                  || [[ "${ARG}" == "-a" ]]; } && { shift 1; AUTHOR="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--description" ]]             || [[ "${ARG}" == "-d" ]]; } && { shift 1; ARGS_DESCRIPTION+=("${1}"); SHIFT="false"; }
    { [[ "${ARG}" == "--required" ]]                || [[ "${ARG}" == "-r" ]]; } && { shift 1; ARGS_REQUIRED+=("${1}"); SHIFT="false"; }
    { [[ "${ARG}" == "--optional" ]]                || [[ "${ARG}" == "-o" ]]; } && { shift 1; ARGS_OPTIONAL+=("${1}"); SHIFT="false"; }
    { [[ "${ARG}" == "--flag" ]]                    || [[ "${ARG}" == "-f" ]]; } && { shift 1; ARGS_FLAG+=("${1}"); SHIFT="false"; }
    { [[ "${ARG}" == "--env" ]]                     || [[ "${ARG}" == "-e" ]]; } && { shift 1; ARGS_ENVIRONMENT+=("${1}"); SHIFT="false"; }
    { [[ "${ARG}" == "--short" ]]                   || [[ "${ARG}" == "-s" ]]; } && { shift 1; SHORT="true"; SHIFT="false"; }
    { [[ "${ARG}" == "--keep-starter-parameters" ]] || [[ "${ARG}" == "-k" ]]; } && { shift 1; KEEP_STARTER_PARAMETERS="true"; SHIFT="false"; }
    { [[ "${ARG}" == "--protect-arguments" ]]       || [[ "${ARG}" == "-p" ]]; } && { shift 1; PROTECT_ARGUMENTS="true"; SHIFT="false"; }
    { [[ "${SHIFT}" == "true" ]] && [[ "$#" -gt 0 ]]; } && { shift 1; }
done
[[ -n "${HELP+x}" ]] && { usage 0; }
# Check required parameters
[[ -z "${NAMING+x}" ]] && { printColored yellow "[!] --naming is required.\n"; INVALID_STATE="true"; }
# Check invalid state and display usage
[[ -n "${INVALID_STATE+x}" ]] && { usage; }
# Initialize optional variables
[[ -z "${AUTHOR+x}" ]] && { AUTHOR=""; }
[[ -z "${DESCRIPTION+x}" ]] && { DESCRIPTION=""; }
[[ -z "${SHORT+x}" ]] && { SHORT="false"; }
[[ -z "${KEEP_STARTER_PARAMETERS+x}" ]] && { KEEP_STARTER_PARAMETERS="false"; }
[[ -z "${PROTECT_ARGUMENTS+x}" ]] && { PROTECT_ARGUMENTS="false"; }
[[ -z "${PROTECT_ARGUMENTS+x}" ]] && { PROTECT_ARGUMENTS="false"; }


# Define constant variable
readonly PROVISIONAL_STRING=$(openssl rand -hex 12 | fold -w 12 | head -1)
readonly BASE_INDENT=""
readonly BASH_SCRIPT_STARTER_URL="https://raw.githubusercontent.com/xshoji/bash-script-starter/master/ScriptStarter.sh"

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
  AUTHOR=""
  [[ "${2}" != "" ]] && { AUTHOR=" author: ${2}"; }
  echo "${AUTHOR}"
  echo
}

function parseValue() {
  echo "${1}" |sed "s/\\\,/${PROVISIONAL_STRING}/g" |awk -F',' '{print $'"${2}"'}' |sed "s/${PROVISIONAL_STRING}/,/g"
}

function escapeDoubleQuote() {
  echo -n $(echo "${1}" |sed 's/\"/\\"/g')
}

function toVarName() {
  local PARAM_NAME="${1}"
  echo "${PARAM_NAME}" | perl -pe 's/(?:^|_|-)(.)/\U$1/g' | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))' |awk '{print toupper($1)}'
}

function printScriptDescription() {
    local PRINTED_DESCRIPTIONS=()
    if [[ ${#ARGS_DESCRIPTION[@]} -gt 0 ]]; then
        PRINTED_DESCRIPTIONS=("${ARGS_DESCRIPTION[@]}")
    else
        PRINTED_DESCRIPTIONS+=("This is ${NAMING}.")
    fi
    for PRINTED_DESCRIPTION in "${PRINTED_DESCRIPTIONS[@]}"
    do
        echo "${BASE_INDENT}${PRINTED_DESCRIPTION}"
    done
    echo
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
        [[ "${DESCRIPTION}" == "" ]] && { DESCRIPTION="\"${SAMPLE}\" means ${PARAM_NAME}."; }
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
        [[ "${DESCRIPTION}" == "" ]] && { DESCRIPTION="\"${SAMPLE}\" means ${PARAM_NAME}."; }
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
        [[ "${DESCRIPTION}" == "" ]] && { DESCRIPTION="Enable ${PARAM_NAME} flag."; }
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

function printColoredMessageFunction() {
    cat << __EOT__
function printColored() { local B="\033[0;"; local C=""; case "\${1}" in "red") C="31m";; "green") C="32m";; "yellow") C="33m";; "blue") C="34m";; esac; printf "%b%b\033[0m" "\${B}\${C}" "\${2}"; }
__EOT__
}

function printBashScriptStarterCurl() {
    local LOCAL_ARGS=("$@")
    echo -n "# [ keep-starter-parameters ] : curl -sf ${BASH_SCRIPT_STARTER_URL} |bash -s - "
    for ARG in "${LOCAL_ARGS[@]}"
    do
        SHIFT="true"
        { [[ "${ARG}" == "--debug" ]]; } && { shift 1; set -eux; SHIFT="false"; }
        { [[ "${ARG}" == "--naming" ]]                  || [[ "${ARG}" == "-n" ]]; } && { echo -n " ${ARG}"; shift 1; echo -n " \""; escapeDoubleQuote "${1}"; echo -n "\""; SHIFT="false"; }
        { [[ "${ARG}" == "--description" ]]             || [[ "${ARG}" == "-d" ]]; } && { echo -n " ${ARG}"; shift 1; echo -n " \""; escapeDoubleQuote "${1}"; echo -n "\""; SHIFT="false"; }
        { [[ "${ARG}" == "--author" ]]                  || [[ "${ARG}" == "-a" ]]; } && { echo -n " ${ARG}"; shift 1; echo -n " \""; escapeDoubleQuote "${1}"; echo -n "\""; SHIFT="false"; }
        { [[ "${ARG}" == "--required" ]]                || [[ "${ARG}" == "-r" ]]; } && { echo -n " ${ARG}"; shift 1; echo -n " \""; escapeDoubleQuote "${1}"; echo -n "\""; SHIFT="false"; }
        { [[ "${ARG}" == "--optional" ]]                || [[ "${ARG}" == "-o" ]]; } && { echo -n " ${ARG}"; shift 1; echo -n " \""; escapeDoubleQuote "${1}"; echo -n "\""; SHIFT="false"; }
        { [[ "${ARG}" == "--env" ]]                     || [[ "${ARG}" == "-e" ]]; } && { echo -n " ${ARG}"; shift 1; echo -n " \""; escapeDoubleQuote "${1}"; echo -n "\""; SHIFT="false"; }
        { [[ "${ARG}" == "--flag" ]]                    || [[ "${ARG}" == "-f" ]]; } && { echo -n " ${ARG}"; shift 1; echo -n " \""; escapeDoubleQuote "${1}"; echo -n "\""; SHIFT="false"; }
        { [[ "${ARG}" == "--short" ]]                   || [[ "${ARG}" == "-s" ]]; } && { echo -n " ${ARG}"; shift 1; SHIFT="false"; }
        { [[ "${ARG}" == "--keep-starter-parameters" ]] || [[ "${ARG}" == "-k" ]]; } && { echo -n " ${ARG}"; shift 1; SHIFT="false"; }
        { [[ "${SHIFT}" == "true" ]] && [[ "$#" -gt 0 ]]; } && { shift 1; }
    done
    echo
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
        VAR_NAME=$(toVarName "${PARAM_NAME}")
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
        VAR_NAME=$(toVarName "${PARAM_NAME}")
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
        echo '[[ -z "${'"${VAR_NAME}"'+x}" ]] && { printColored yellow "[!] export '"${VAR_NAME}"'='"${SAMPLE}"' is required.\n"; INVALID_STATE="true"; }'
        shift 1
    done
}



function printCheckRequiredArgument() {
    local PARAM_NAME
    local VAR_NAME
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        VAR_NAME=$(toVarName "${PARAM_NAME}")
        echo '[[ -z "${'"${VAR_NAME}"'+x}" ]] && { printColored yellow "[!] --'"${PARAM_NAME}"' is required.\n"; INVALID_STATE="true"; }'
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
        VAR_NAME=$(toVarName "${PARAM_NAME}")
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
        VAR_NAME=$(toVarName "${PARAM_NAME}")
        echo '[[ -z "${'"${VAR_NAME}"'+x}" ]] && { '"${VAR_NAME}"=\"'false'\"'; }'
        shift 1
    done
}


function printDeclareVariableAsReadOnly() {
    local PARAM_NAME
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        VAR_NAME=$(toVarName "${PARAM_NAME}")
        echo "readonly ${VAR_NAME}"
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
    echo
}


function printVariableRequired() {
    local PARAM_NAME
    local VAR_NAME
    echo "[ Required parameters ]"
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        VAR_NAME=$(toVarName "${PARAM_NAME}")
        echo "${PARAM_NAME}"': ${'"${VAR_NAME}"'}'
        shift 1
    done
    echo
}

function printVariableOptional() {
    local PARAM_NAME
    local VAR_NAME
    echo "[ Optional parameters ]"
    for ARG in "$@"
    do
        PARAM_NAME=$(parseValue "${1}" 1)
        VAR_NAME=$(toVarName "${PARAM_NAME}")
        echo "${PARAM_NAME}"': ${'"${VAR_NAME}"'}'
        shift 1
    done
    echo
}






#==========================================
# Main
#==========================================

# Check optional and flag parameter
HAS_ENVIRONMENT="false"
HAS_REQUIRED="false"
HAS_OPTION="false"
HAS_FLAG="false"
HAS_OPTION_OR_FLAG="false"
[[ ${#ARGS_ENVIRONMENT[@]} -gt 0 ]] && { HAS_ENVIRONMENT="true"; }
[[ ${#ARGS_REQUIRED[@]} -gt 0 ]] && { HAS_REQUIRED="true"; }
[[ ${#ARGS_OPTIONAL[@]} -gt 0 ]] && { HAS_OPTION="true"; }
[[ ${#ARGS_FLAG[@]} -gt 0 ]] && { HAS_FLAG="true"; }
{ [[ "${HAS_OPTION}" == "true" ]] || [[ "${HAS_FLAG}" == "true" ]]; } && { HAS_OPTION_OR_FLAG="true"; }


printUsageFunctionTopPart "${NAMING}" "${AUTHOR}"
printScriptDescription

# Print usage line
printUsageExecutionExampleBase
# - [Bash empty array expansion with `set -u` - Stack Overflow](https://stackoverflow.com/questions/7577052/bash-empty-array-expansion-with-set-u)
printUsageExecutionExample ${ARGS_REQUIRED[@]+"${ARGS_REQUIRED[@]}"}
[[ "${HAS_OPTION_OR_FLAG}" == "true" ]] && { echo -n " ["; }
printUsageExecutionExample ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}
printUsageExecutionExampleFlag ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}
[[ "${HAS_OPTION_OR_FLAG}" == "true" ]] && { echo -n " ]"; }
echo

# Print parameter descriptions
if [[ "${HAS_ENVIRONMENT}" == "true" ]]; then
    echo
    echo "${BASE_INDENT}Environment variables: "
    printEnvironmentVariableDescription "${ARGS_ENVIRONMENT[@]}"
fi

if [[ "${HAS_REQUIRED}" == "true" ]]; then
    echo
    echo "${BASE_INDENT}Required:"
    printParameterDescriptionRequired "${ARGS_REQUIRED[@]}"
fi

if [[ "${HAS_OPTION_OR_FLAG}" == "true" ]]; then
    echo
    echo "${BASE_INDENT}Optional:"
    [[ "${HAS_OPTION}" == "true" ]] && { printParameterDescriptionOptional ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}; }
    [[ "${HAS_FLAG}" == "true" ]] && { printParameterDescriptionFlag ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}; }
fi

echo
echo "${BASE_INDENT}Helper options:"
echo "${BASE_INDENT}  --help, --debug"
echo

printUsageFunctionBottomPart
printColoredMessageFunction
[[ "${KEEP_STARTER_PARAMETERS}" == "true" ]] && { printBashScriptStarterCurl "${BASH_SCRIPT_STARTER_ARGS[@]}"; }

cat << "__EOT__"



#------------------------------------------
# Preparation
#------------------------------------------
set -eu

# Parse parameters
readonly ARGS=("$@")
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

if [[ ${PROTECT_ARGUMENTS} == "true" ]]; then
  echo "# To readonly variables"
  printDeclareVariableAsReadOnly ${ARGS_REQUIRED[@]+"${ARGS_REQUIRED[@]}"}
  printDeclareVariableAsReadOnly ${ARGS_OPTIONAL[@]+"${ARGS_OPTIONAL[@]}"}
  printDeclareVariableAsReadOnly ${ARGS_FLAG[@]+"${ARGS_FLAG[@]}"}
  printDeclareVariableAsReadOnly ${ARGS_ENVIRONMENT[@]+"${ARGS_ENVIRONMENT[@]}"}
fi

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


# STARTER_URL=https://raw.githubusercontent.com/xshoji/bash-script-starter/master/ScriptStarter.sh
# curl -sf ${STARTER_URL} |bash -s - \
#   -n ScriptStarter \
#   -a xshoji \
#   -d "This script generates a template of bash script tool." \
#   -r naming,scriptName,"Script name." \
#   -o author,author,"Script author." \
#   -o description,"Description","Description of this script. [ example: --description \"ScriptStarter's description here.\" ]" \
#   -o required,"paramName\,sample\,description","Required parameter setting. [ example: --required id\,1001\,\"Primary id here.\" ]" \
#   -o optional,"paramName\,sample\,description\,defaultValue(omittable)","Optional parameter setting. [ example: --option name\,xshoji\,\"User name here.\"\,defaultUser ]" \
#   -o flag,"flagName\,description","Optional flag setting. [ example: --flag dryRun\,\"Dry run mode.\" ]" \
#   -o env,"variableName\,sample","Required environment variable setting. [ example: --env API_HOST\,example.com ]" \
#   -f short,"Enable short parameter. [ example: --short ]" \
#   -f keep-starter-parameters,"Keep parameter details of bash-script-starter in the generated scprit. [ example: --keep-starter-parameters ]" \
#   -f protect-arguments,"Declare argument variables as readonly. [ example: --protect-arguments ]" \
#   -s -k > /tmp/test.sh; open /tmp/test.sh
