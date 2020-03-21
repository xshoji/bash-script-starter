#!/bin/bash

function usage()
{
cat << _EOT_

 ScriptStarterTest
---------------------- author: xshoji

This is ScriptStarterTest.

Usage:
  ./$(basename "$0") --scriptPath /path/to/ScriptStarter.sh

Required:
  -s, --scriptPath /path/to/ScriptStarter.sh : "/path/to/ScriptStarter.sh" means scriptPath.

Helper options:
  --help, --debug

_EOT_
  [[ "${1+x}" != "" ]] && { exit "${1}"; }
  exit 1
}
function printColored() { local B="\033[0;"; local C=""; case "${1}" in "red") C="31m";; "green") C="32m";; "yellow") C="33m";; "blue") C="34m";; esac; printf "%b%b\033[0m" "${B}${C}" "${2}"; }



#------------------------------------------
# Preparation
#------------------------------------------
set -eu

# Parse parameters
for ARG in "$@"
do
    SHIFT="true"
    [[ "${ARG}" == "--debug" ]] && { shift 1; set -eux; SHIFT="false"; }
    { [[ "${ARG}" == "--scriptPath" ]] || [[ "${ARG}" == "-s" ]]; } && { shift 1; SCRIPT_PATH="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--help" ]] || [[ "${ARG}" == "-h" ]]; } && { shift 1; HELP="true"; SHIFT="false"; }
    { [[ "${SHIFT}" == "true" ]] && [[ "$#" -gt 0 ]]; } && { shift 1; }
done
[[ -n "${HELP+x}" ]] && { usage 0; }
# Check required parameters
[[ -z "${SCRIPT_PATH+x}" ]] && { printColored yellow "[!] --scriptPath is required.\n"; INVALID_STATE="true"; }
# Check invalid state and display usage
[[ -n "${INVALID_STATE+x}" ]] && { usage; }



#------------------------------------------
# Main
#------------------------------------------

cat << __EOT__

[ Required parameters ]
scriptPath: ${SCRIPT_PATH}

__EOT__



set +e
COUNT=1
TEST_WORKING_DIR="/tmp"
GENERATED_FILES_PREFIX="test_9b94cb0c47b8_"
GENERATED_SCRIPT_FILE_NAME="${GENERATED_FILES_PREFIX}generated_script.sh"
GENERATED_SCRIPT_FILE_PATH="${TEST_WORKING_DIR}/${GENERATED_SCRIPT_FILE_NAME}"
ACTUAL_OUTPUT_PATH="${TEST_WORKING_DIR}/${GENERATED_FILES_PREFIX}actual_output.txt"
EXPECTED_USAGE_BASE_PATH="${TEST_WORKING_DIR}/${GENERATED_FILES_PREFIX}expected_usage_base.txt"
EXPECTED_OUTPUT_PATH="${TEST_WORKING_DIR}/${GENERATED_FILES_PREFIX}expected_output.txt"
touch ${GENERATED_SCRIPT_FILE_PATH}
chmod +x ${GENERATED_SCRIPT_FILE_PATH}
trap "rm -rf ${TEST_WORKING_DIR}/${GENERATED_FILES_PREFIX}*" EXIT SIGINT
readonly SCRIPT_PATH
readonly GENERATED_SCRIPT_FILE_NAME
readonly GENERATED_SCRIPT_FILE_PATH
readonly ACTUAL_OUTPUT_PATH
readonly EXPECTED_USAGE_BASE_PATH
readonly EXPECTED_OUTPUT_PATH
export SCRIPT_PATH
export ACTUAL_OUTPUT_PATH
export GENERATED_SCRIPT_FILE_NAME
export GENERATED_SCRIPT_FILE_PATH
export EXPECTED_USAGE_BASE_PATH
export EXPECTED_OUTPUT_PATH
export COUNT
export USECOLOR="no"





function main() {
  testCaseError
  testCaseOk
  testCaseRequiredParameterOnly
  testCaseRequiredAndEnvironmentParameter
  testCaseRequiredAndOptionalParameter
  testCaseReqOptFlgWithDescDefault
  testCaseReqOptFlgWithDescDefaultByShortParameter
  testCaseStrangeParameterInjection
  testCaseStrangeShortParameterInjectionWithShortParamGeneration
  testCaseMultiLineDescription
  testCaseHelpExitStatus
  testCaseEscapeComma
  testCaseEnableKeepStarterParameters
  testCaseEnableProtectArguments
}









function assertOutput() {
  local TEST_CASE_NAME="${1}"
  echo -n ${COUNT}". [ "
  COUNT=$(( COUNT + 1 ))
  diff "${ACTUAL_OUTPUT_PATH}" "${EXPECTED_OUTPUT_PATH}"
  local IS_UNEXPECTED_OUTPUT=$?
  if [[ "${IS_UNEXPECTED_OUTPUT}" == "0" ]]; then
    printColored green "OK"
  else
    printColored red "NG"
  fi
  echo " ] : ${TEST_CASE_NAME}"
}





function assertExitStatus() {
  local TEST_CASE_NAME="${1}"
  local EXPECTED_STATUS="${2}"
  local SCRIPT_PARAMETERS="${3}"
  echo -n ${COUNT}". [ "
  COUNT=$(( COUNT + 1 ))
  eval "bash ${GENERATED_SCRIPT_FILE_PATH} ${SCRIPT_PARAMETERS} $> /dev/null"
  local EXIT_STATUS=$?
  if [[ "${EXIT_STATUS}" == "${EXPECTED_STATUS}" ]]; then
    printColored green "OK"
  else
    printColored red "NG"
  fi
  echo " ] : ${TEST_CASE_NAME} ( parameter: ${SCRIPT_PARAMETERS}, actual: ${EXIT_STATUS}, expected: ${EXPECTED_STATUS} )"
}




function testCaseError() {
  bash "${SCRIPT_PATH}" &> "${ACTUAL_OUTPUT_PATH}"
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] --naming is required.
[0m
 ScriptStarter
------------------ author: xshoji

This script generates a template of bash script tool.

Usage:
  ./ScriptStarter.sh --naming scriptName [ --author author --description Description --description ... --required paramName,sample,description --required ... --optional paramName,sample,description,defaultValue(omittable) --optional ... --flag flagName,description --flag ... --env variableName,sample --env ... --short  --keep-starter-parameters --protect-arguments ]

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
  assertOutput "error no required parameter"
}





function testCaseOk() {
  # Case 1
  bash "${SCRIPT_PATH}" --naming test --author user > "${GENERATED_SCRIPT_FILE_PATH}"
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}"
  local SCRIPT_STATUS="$?"
  # FIXME : a generated script that is no arguments becomes error ...
  [[ "${SCRIPT_STATUS}" != "1" ]] && { printColored green "NG (testCaseOk)\n";}

  # Case 2
  bash "${GENERATED_SCRIPT_FILE_PATH}" --help &> "${ACTUAL_OUTPUT_PATH}"
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

 test
--------- author: user

This is test.

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME}

Helper options:
  --help, --debug

_EOT_
  assertOutput "Minimum parameter only ( --help )"
}





function testCaseRequiredParameterOnly() {
  # Case 1
  bash "${SCRIPT_PATH}" --naming test --author user --required aaa,aaa > "${GENERATED_SCRIPT_FILE_PATH}"
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" $> "${ACTUAL_OUTPUT_PATH}"
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] --aaa is required.
[0m
 test
--------- author: user

This is test.

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --aaa aaa

Required:
  --aaa aaa : "aaa" means aaa.

Helper options:
  --help, --debug

_EOT_


  # Case 2
  bash "${GENERATED_SCRIPT_FILE_PATH}" --aaa aaa $> "${ACTUAL_OUTPUT_PATH}"
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Required parameters ]
aaa: aaa

_EOT_
  assertOutput "Required parameter only | ok"
}





function testCaseRequiredAndEnvironmentParameter() {
  # Case 1
  bash "${SCRIPT_PATH}" --naming test --author user --required aaa,aaa --env TEST,test > "${GENERATED_SCRIPT_FILE_PATH}"
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" $> "${ACTUAL_OUTPUT_PATH}"
  cat << _EOT_ > ${EXPECTED_USAGE_BASE_PATH}
 test
--------- author: user

This is test.

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --aaa aaa

Environment variables:
  export TEST=test

Required:
  --aaa aaa : "aaa" means aaa.

Helper options:
  --help, --debug

_EOT_

  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] export TEST=test is required.
[0m[0;33m[!] --aaa is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  assertOutput "Required parameter and Environment parameter | validation error"


  # Case 2
  export TEST=test
  bash "${GENERATED_SCRIPT_FILE_PATH}" $> "${ACTUAL_OUTPUT_PATH}"
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] --aaa is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  assertOutput "Required parameter and Environment parameter | validation error (environment is ok)"


  # Case 3
  bash "${GENERATED_SCRIPT_FILE_PATH}" --aaa aaa $> "${ACTUAL_OUTPUT_PATH}"
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Environment variables ]
TEST: test

[ Required parameters ]
aaa: aaa

_EOT_
  assertOutput "Required parameter and Environment parameter | ok"
}





function testCaseRequiredAndOptionalParameter() {
  # Case 1
  bash "${SCRIPT_PATH}" --naming test --author user --required aaa,aaa --optional bbb,bbb > "${GENERATED_SCRIPT_FILE_PATH}"
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  cat << _EOT_ > ${EXPECTED_USAGE_BASE_PATH}
 test
--------- author: user

This is test.

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --aaa aaa [ --bbb bbb ]

Required:
  --aaa aaa : "aaa" means aaa.

Optional:
  --bbb bbb : "bbb" means bbb.

Helper options:
  --help, --debug

_EOT_
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] --aaa is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Required parameter and Optional parameter | validation error"


  # Case 2
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] --aaa is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" --bbb bbb $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Required parameter and Optional parameter | validation error (optional is specified)"


  # Case 3
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Required parameters ]
aaa: aaa

[ Optional parameters ]
bbb: 

_EOT_
  bash "${GENERATED_SCRIPT_FILE_PATH}" --aaa aaa $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Required parameter and Optional parameter | ok"
}





function testCaseReqOptFlgWithDescDefault() {
  # Case 1
  bash "${SCRIPT_PATH}" --naming test \
    --author user \
    --required aaa,aaa,"aaa param is here." \
    --optional bbb,bbb,"bbb param is here." \
    --optional ccc,ccc,"ccc param is here.",default_ccc \
    --flag ddd,"ddd flag is here." \
    > "${GENERATED_SCRIPT_FILE_PATH}"
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  cat << _EOT_ > ${EXPECTED_USAGE_BASE_PATH}
 test
--------- author: user

This is test.

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --aaa aaa [ --bbb bbb --ccc ccc --ddd ]

Required:
  --aaa aaa : aaa param is here.

Optional:
  --bbb bbb : bbb param is here.
  --ccc ccc : ccc param is here. [ default: default_ccc ]
  --ddd : ddd flag is here.

Helper options:
  --help, --debug

_EOT_

  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] --aaa is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Required, Optional, Flag parameter ( description is specified ) | validation error"


  # Case 2
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] --aaa is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" --bbb bbb --ddd $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Required, Optional, Flag parameter ( description is specified ) | validation error (optional is specified)"


  # Case 3
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Required parameters ]
aaa: aaa

[ Optional parameters ]
bbb: bbb
ccc: ccc
ddd: true

_EOT_
  bash "${GENERATED_SCRIPT_FILE_PATH}" --aaa aaa --bbb bbb --ccc ccc --ddd $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Required, Optional, Flag parameter ( description is specified ) | ok"


  # Case 4
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Required parameters ]
aaa: aaa

[ Optional parameters ]
bbb: 
ccc: default_ccc
ddd: false

_EOT_
  bash "${GENERATED_SCRIPT_FILE_PATH}" --aaa aaa $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Required, Optional, Flag parameter ( description is specified ) | ok 2"
}





function testCaseReqOptFlgWithDescDefaultByShortParameter() {
  # Case 1
  bash "${SCRIPT_PATH}" -n test \
    -a user \
    -r a111,a111,"a111 param is here." \
    -r a2222,a222222,"a2222 param is here." \
    -r a3,a3,"a3 param is here." \
    -o b1,b11,"b1 param is here.","DefaultB1" \
    -o b22,b2222,"b22 param is here.","DefaultB22" \
    -o b333,b33333,"b333 param is here.","DefaultB333" \
    -f c11111,"c11111 flag is here." \
    -f c222,"c222 flag is here." \
    -f c3,"c3 flag is here." \
    -e T1,t111,"Test" \
    -e T222,t22222,"Test" \
    -e T3,t3,"t3" \
    > "${GENERATED_SCRIPT_FILE_PATH}"
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  cat << _EOT_ > ${EXPECTED_USAGE_BASE_PATH}
 test
--------- author: user

This is test.

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --a111 a111 --a2222 a222222 --a3 a3 [ --b1 b11 --b22 b2222 --b333 b33333 --c11111 --c222 --c3 ]

Environment variables:
  export T1=t111
  export T222=t22222
  export T3=t3

Required:
  --a111 a111     : a111 param is here.
  --a2222 a222222 : a2222 param is here.
  --a3 a3         : a3 param is here.

Optional:
  --b1 b11      : b1 param is here. [ default: DefaultB1 ]
  --b22 b2222   : b22 param is here. [ default: DefaultB22 ]
  --b333 b33333 : b333 param is here. [ default: DefaultB333 ]
  --c11111 : c11111 flag is here.
  --c222   : c222 flag is here.
  --c3     : c3 flag is here.

Helper options:
  --help, --debug

_EOT_

  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] export T1=t111 is required.
[0m[0;33m[!] export T222=t22222 is required.
[0m[0;33m[!] export T3=t3 is required.
[0m[0;33m[!] --a111 is required.
[0m[0;33m[!] --a2222 is required.
[0m[0;33m[!] --a3 is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Required, Optional, Flag parameter ( description is specified ) | validation error"

  # Case 2
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] export T1=t111 is required.
[0m[0;33m[!] export T222=t22222 is required.
[0m[0;33m[!] export T3=t3 is required.
[0m[0;33m[!] --a2222 is required.
[0m[0;33m[!] --a3 is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" --a111 aaa1 $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Required, Optional, Flag parameter ( description is specified ) | validation error (--a111 only)"


  # Case 3
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] export T1=t111 is required.
[0m[0;33m[!] export T222=t22222 is required.
[0m[0;33m[!] export T3=t3 is required.
[0m[0;33m[!] --a3 is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" --a111 aaa1 --a2222 aaa2 $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Required, Optional, Flag parameter ( description is specified ) | validation error (--a111, --a2222)"


  # Case 4
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] export T1=t111 is required.
[0m[0;33m[!] export T222=t22222 is required.
[0m[0;33m[!] export T3=t3 is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" --a111 aaa1 --a2222 aaa2 --a3 aaa3 $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Required, Optional, Flag parameter ( description is specified ) | validation error (--a111, --a2222, --a3)"

  # Case 4
  export T1="TTTT1";
  export T222="TTTT2";
  export T3="TTTT3";
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Environment variables ]
T1: TTTT1
T222: TTTT2
T3: TTTT3

[ Required parameters ]
a111: aaa1
a2222: aaa2
a3: aaa3

[ Optional parameters ]
b1: DefaultB1
b22: DefaultB22
b333: DefaultB333
c11111: false
c222: false
c3: false

_EOT_
  bash "${GENERATED_SCRIPT_FILE_PATH}" --a111 aaa1 --a2222 aaa2 --a3 aaa3 $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Required, Optional, Flag parameter ( description is specified ) | ok"
}







function testCaseStrangeParameterInjection() {
  # Case 1
  bash "${SCRIPT_PATH}" \
    --xxx \
    --flag ccc \
    --yyy \
    --optional bbb,bbb \
    --required zzz,zzz \
    --naming test \
    --author user \
    > "${GENERATED_SCRIPT_FILE_PATH}"
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  cat << _EOT_ > ${EXPECTED_USAGE_BASE_PATH}
 test
--------- author: user

This is test.

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --zzz zzz [ --bbb bbb --ccc ]

Required:
  --zzz zzz : "zzz" means zzz.

Optional:
  --bbb bbb : "bbb" means bbb.
  --ccc : Enable ccc flag.

Helper options:
  --help, --debug

_EOT_

  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] --zzz is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Strange parameters by free order | validation error"


  # Case 2
  bash "${GENERATED_SCRIPT_FILE_PATH}" --xxx --yyy $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Strange parameters by free order | validation error 2"


  # Case 3
  bash "${GENERATED_SCRIPT_FILE_PATH}" --bbb bbb $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Strange parameters by free order | validation error 2"


  # Case 3
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Required parameters ]
zzz: zzz

[ Optional parameters ]
bbb: bbb
ccc: false

_EOT_
  bash "${GENERATED_SCRIPT_FILE_PATH}" --zzz zzz --bbb bbb $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Strange parameters by free order | ok"
}




function testCaseStrangeShortParameterInjectionWithShortParamGeneration() {
  # Case 1
  bash "${SCRIPT_PATH}" \
    -x \
    -f ccc \
    -y \
    -o bbb,bbb \
    -r zzz,zzz \
    -n test \
    -a user \
    -s \
    > "${GENERATED_SCRIPT_FILE_PATH}"
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  cat << _EOT_ > ${EXPECTED_USAGE_BASE_PATH}
 test
--------- author: user

This is test.

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --zzz zzz [ --bbb bbb --ccc ]

Required:
  -z, --zzz zzz : "zzz" means zzz.

Optional:
  -b, --bbb bbb : "bbb" means bbb.
  -c, --ccc : Enable ccc flag.

Helper options:
  --help, --debug

_EOT_
  echo "" > "${EXPECTED_OUTPUT_PATH}"
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" -h $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Strange short parameters by free order | help (short parameter)"

  # Case 2
  echo "" > "${EXPECTED_OUTPUT_PATH}"
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" --help $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Strange short parameters by free order | help (long parameter)"

  # Case 3
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] --zzz is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Strange short parameters by free order | validation error"


  # Case 4
  bash "${GENERATED_SCRIPT_FILE_PATH}" -x -y $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Strange short parameters by free order | validation error 2"


  # Case 5
  bash "${GENERATED_SCRIPT_FILE_PATH}" -b bbb $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Strange short parameters by free order | validation error 2"


  # Case 6
  echo "" > "${EXPECTED_OUTPUT_PATH}"
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" -b bbb -h $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Strange short parameters by free order | ok (display help)"
  

  # Case 7
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Required parameters ]
zzz: zzz

[ Optional parameters ]
bbb: bbb
ccc: false

_EOT_
  bash "${GENERATED_SCRIPT_FILE_PATH}" -z zzz -b bbb $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Strange short parameters by free order | ok (by short parameter)"


  # Case 8
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Required parameters ]
zzz: zzz2

[ Optional parameters ]
bbb: bbb2
ccc: true

_EOT_
  bash "${GENERATED_SCRIPT_FILE_PATH}" --zzz zzz2 --bbb bbb2 -c $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Strange short parameters by free order | ok (by long parameter)"


  # Case 9
  echo "" > "${EXPECTED_OUTPUT_PATH}"
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" --zzz zzz2 --bbb bbb2 -c --help $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Strange short parameters by free order | ok (display help2)"
}





function testCaseMultiLineDescription() {
  # Case 1
  bash "${SCRIPT_PATH}" \
    --xxx \
    -f ccc \
    --yyy \
    -o bbb,bbb \
    -r zzz,zzz \
    -n test \
    -a user \
    -s \
    -d "Test script" \
    -d "Second description" \
    -d "Third description" \
    > "${GENERATED_SCRIPT_FILE_PATH}"
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  cat << _EOT_ > ${EXPECTED_USAGE_BASE_PATH}
 test
--------- author: user

Test script
Second description
Third description

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --zzz zzz [ --bbb bbb --ccc ]

Required:
  -z, --zzz zzz : "zzz" means zzz.

Optional:
  -b, --bbb bbb : "bbb" means bbb.
  -c, --ccc : Enable ccc flag.

Helper options:
  --help, --debug

_EOT_
  echo "" > "${EXPECTED_OUTPUT_PATH}"
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" -h $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Multi line description | help (short parameter)"


  # Case 2
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] --zzz is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Multi line description | validation error"


  # Case 3
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Required parameters ]
zzz: zzz

[ Optional parameters ]
bbb: bbb
ccc: false

_EOT_
  bash "${GENERATED_SCRIPT_FILE_PATH}" -z zzz -b bbb $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Multi line description | ok (by short parameter)"


  # Case 8
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Required parameters ]
zzz: zzz2

[ Optional parameters ]
bbb: bbb2
ccc: true

_EOT_
  bash "${GENERATED_SCRIPT_FILE_PATH}" --zzz zzz2 --bbb bbb2 -c $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Multi line description | ok (by long parameter)"
}




function testCaseHelpExitStatus() {
  # Case 1
  bash "${SCRIPT_PATH}" \
    -r zzz,zzz \
    -n test \
    -a user \
    -s \
    > "${GENERATED_SCRIPT_FILE_PATH}"
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  cat << _EOT_ > ${EXPECTED_USAGE_BASE_PATH}
 test
--------- author: user

This is test.

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --zzz zzz

Required:
  -z, --zzz zzz : "zzz" means zzz.

Helper options:
  --help, --debug

_EOT_
  assertExitStatus "Help exit status | ok" "0" "-h"
  assertExitStatus "Help exit status | ok" "0" "--help"
  echo "" > "${EXPECTED_OUTPUT_PATH}"
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" -h $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Help exit status | ok (output)"


  # Case 2
  assertExitStatus "Help exit status | invalid argument" "1" ""
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] --zzz is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Help exit status | invalid argument (output)"
  
  
  # Case 3
  bash "${SCRIPT_PATH}" \
    -r hhh,hhh \
    -n test \
    -a user \
    -s \
    > "${GENERATED_SCRIPT_FILE_PATH}"
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  cat << _EOT_ > ${EXPECTED_USAGE_BASE_PATH}
 test
--------- author: user

This is test.

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --hhh hhh

Required:
  -h, --hhh hhh : "hhh" means hhh.

Helper options:
  --help, --debug

_EOT_
  assertExitStatus "Help exit status | specified as required parameter" "0" "-h hhh"
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Required parameters ]
hhh: h1

_EOT_
  bash "${GENERATED_SCRIPT_FILE_PATH}" -h h1 $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Help exit status | specified as required parameter (output)"  

  
  # Case 4
  assertExitStatus "Help exit status | specified as help parameter" "0" "--help"
  echo "" > "${EXPECTED_OUTPUT_PATH}"
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" --help $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Help exit status | specified as help parameter (output)"

  
  # Case 5
  bash "${SCRIPT_PATH}" \
    -r zzz,zzz \
    -f hhh \
    -n test \
    -a user \
    -s \
    > "${GENERATED_SCRIPT_FILE_PATH}"
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  cat << _EOT_ > ${EXPECTED_USAGE_BASE_PATH}
 test
--------- author: user

This is test.

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --zzz zzz [ --hhh ]

Required:
  -z, --zzz zzz : "zzz" means zzz.

Optional:
  -h, --hhh : Enable hhh flag.

Helper options:
  --help, --debug

_EOT_
  assertExitStatus "Help exit status | specified as flag parameter" "1" "-h"
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] --zzz is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" -h $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Help exit status | specified as flag parameter (output)"
  
  
  # Case 6
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Required parameters ]
zzz: zzz

[ Optional parameters ]
hhh: true

_EOT_
  bash "${GENERATED_SCRIPT_FILE_PATH}" -z zzz -h $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Help exit status | specified as flag parameter (output)"  

  
  # Case 7
  assertExitStatus "Help exit status | specified as help parameter 2" "0" "--help"
  echo "" > "${EXPECTED_OUTPUT_PATH}"
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" --help $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Help exit status | specified as help parameter 2 (output)"
}





function testCaseEscapeComma() {
  # Case 1
  bash "${SCRIPT_PATH}" \
    -n test \
    -a user \
    -d aaa\,bbb\,ccc\,ddd \
    -d eee\,fff\,ggg \
    -s \
    -r aaa,"aaa\,aaa","aaa\,aaaa" \
    -o bbb,bbb\\,bbb,bbb\\,bbb,bbb\\,bbb \
    -f c3,"c3 flag\, is here." \
    -o ddd,"\"ddd\,ddd\\,ddd\"" \
    -e T2,t222\\,t222," Test\,Test" \
    > ${GENERATED_SCRIPT_FILE_PATH}
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  cat << _EOT_ > ${EXPECTED_USAGE_BASE_PATH}
 test
--------- author: user

aaa,bbb,ccc,ddd
eee,fff,ggg

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --aaa aaa,aaa [ --bbb bbb,bbb --ddd "ddd,ddd,ddd" --c3 ]

Environment variables:
  export T2=t222,t222

Required:
  -a, --aaa aaa,aaa : aaa,aaaa

Optional:
  -b, --bbb bbb,bbb       : bbb,bbb [ default: bbb,bbb ]
  -d, --ddd "ddd,ddd,ddd" : ""ddd,ddd,ddd"" means ddd.
  -c, --c3 : c3 flag, is here.

Helper options:
  --help, --debug

_EOT_
  echo "" > "${EXPECTED_OUTPUT_PATH}"
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" -h $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Escape comma | display help"

  # Case 2
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"
[0;33m[!] export T2=t222,t222 is required.
[0m[0;33m[!] --aaa is required.
[0m
_EOT_
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Escape comma | invalid parameter"

  
  # Case 3
  export T2=aaa
  cat << _EOT_ > "${EXPECTED_OUTPUT_PATH}"

[ Environment variables ]
T2: aaa

[ Required parameters ]
aaa: a

[ Optional parameters ]
bbb: bbb,bbb
ddd: ddd
c3: false

_EOT_
  bash "${GENERATED_SCRIPT_FILE_PATH}" -a a -o b -d ddd $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Escape comma | ok"  
}




function testCaseEnableKeepStarterParameters() {
  # Case 1
  bash "${SCRIPT_PATH}" \
    -n test \
    -a user \
    -d aaa\,bbb\,ccc\,ddd \
    -d eee\,fff\,ggg \
    -s \
    -r aaa,"aaa\,aaa","aaa\,aaaa" \
    -o bbb,bbb\\,bbb,bbb\\,bbb,bbb\\,bbb \
    -f c3,"c3 flag\, is here." \
    -o ddd,"\"ddd\,ddd\\,ddd\"" \
    -e T2,t222\\,t222," Test\,Test" \
    -k \
    > ${GENERATED_SCRIPT_FILE_PATH}
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  cat << _EOT_ > ${EXPECTED_USAGE_BASE_PATH}
 test
--------- author: user

aaa,bbb,ccc,ddd
eee,fff,ggg

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --aaa aaa,aaa [ --bbb bbb,bbb --ddd "ddd,ddd,ddd" --c3 ]

Environment variables:
  export T2=t222,t222

Required:
  -a, --aaa aaa,aaa : aaa,aaaa

Optional:
  -b, --bbb bbb,bbb       : bbb,bbb [ default: bbb,bbb ]
  -d, --ddd "ddd,ddd,ddd" : ""ddd,ddd,ddd"" means ddd.
  -c, --c3 : c3 flag, is here.

Helper options:
  --help, --debug

_EOT_
  echo "" > "${EXPECTED_OUTPUT_PATH}"
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" -h $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Enable --keep-starter-parameters | display help"


  # Case 2
  grep "keep-starter-parameters" "${GENERATED_SCRIPT_FILE_PATH}" > "${ACTUAL_OUTPUT_PATH}"
  cat << _EOT_ > ${EXPECTED_OUTPUT_PATH}
# [ keep-starter-parameters ] : curl -sf https://raw.githubusercontent.com/xshoji/bash-script-starter/master/ScriptStarter.sh |bash -s -  -n "test" -a "user" -d "aaa,bbb,ccc,ddd" -d "eee,fff,ggg" -s -r "aaa,aaa\,aaa,aaa\,aaaa" -o "bbb,bbb\,bbb,bbb\,bbb,bbb\,bbb" -f "c3,c3 flag\, is here." -o "ddd,\"ddd\,ddd\,ddd\"" -e "T2,t222\,t222, Test\,Test" -k
_EOT_
  assertOutput "Enable --keep-starter-parameters | check curl command"
}




function testCaseEnableProtectArguments() {
  # Case 1
  bash "${SCRIPT_PATH}" \
    -n test \
    -a user \
    -d aaa\,bbb\,ccc\,ddd \
    -d eee\,fff\,ggg \
    -s \
    -r aaa,"aaa\,aaa","aaa\,aaaa" \
    -o bbb,bbb\\,bbb,bbb\\,bbb,bbb\\,bbb \
    -f c3,"c3 flag\, is here." \
    -o ddd,"\"ddd\,ddd\\,ddd\"" \
    -e T2,t222\\,t222," Test\,Test" \
    -k \
    -p \
    > ${GENERATED_SCRIPT_FILE_PATH}
  chmod 777 "${GENERATED_SCRIPT_FILE_PATH}"
  cat << _EOT_ > ${EXPECTED_USAGE_BASE_PATH}
 test
--------- author: user

aaa,bbb,ccc,ddd
eee,fff,ggg

Usage:
  ./${GENERATED_SCRIPT_FILE_NAME} --aaa aaa,aaa [ --bbb bbb,bbb --ddd "ddd,ddd,ddd" --c3 ]

Environment variables:
  export T2=t222,t222

Required:
  -a, --aaa aaa,aaa : aaa,aaaa

Optional:
  -b, --bbb bbb,bbb       : bbb,bbb [ default: bbb,bbb ]
  -d, --ddd "ddd,ddd,ddd" : ""ddd,ddd,ddd"" means ddd.
  -c, --c3 : c3 flag, is here.

Helper options:
  --help, --debug

_EOT_
  echo "" > "${EXPECTED_OUTPUT_PATH}"
  cat ${EXPECTED_USAGE_BASE_PATH} >> "${EXPECTED_OUTPUT_PATH}"
  bash "${GENERATED_SCRIPT_FILE_PATH}" -h $> "${ACTUAL_OUTPUT_PATH}"
  assertOutput "Enable --protect-arguments | display help"


  # Case 2
  grep "readonly" "${GENERATED_SCRIPT_FILE_PATH}" > "${ACTUAL_OUTPUT_PATH}"
  cat << _EOT_ > ${EXPECTED_OUTPUT_PATH}
readonly ARGS=("\$@")
# To readonly variables
readonly AAA
readonly BBB
readonly DDD
readonly C3
readonly T2
_EOT_
  assertOutput "Enable --protect-arguments | check curl command"
}


# Execute tests.
main


# STARTER_URL=https://raw.githubusercontent.com/xshoji/bash-script-starter/master/ScriptStarter.sh
# curl -sf ${STARTER_URL} |bash -s - \
#   -n ScriptStarterTest \
#   -a xshoji \
#   -r scriptPath,"/path/to/ScriptStarter.sh" \
#   -s > /tmp/test.sh; open /tmp/test.sh
