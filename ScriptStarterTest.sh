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
function printColored() { C=""; case "${1}" in "Yellow") C="\033[0;33m";; "Green") C="\033[0;32m";; esac; printf "%s%s\033[0m\n" "${C}" "${2}"; }




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
[[ -z "${SCRIPT_PATH+x}" ]] && { printColored Yellow "[!] --scriptPath is required."; INVALID_STATE="true"; }
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
GENERATED_SCRIPT_FILE_PATH=/tmp/test.sh
trap "rm -rf ${GENERATED_SCRIPT_FILE_PATH}" EXIT SIGINT

echo;echo;echo;
echo "================="
echo ${COUNT}". error."
COUNT=$(( COUNT + 1 ))
bash ${SCRIPT_PATH}

echo;echo;echo;
echo "================="
echo ${COUNT}". ok."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}

echo;echo;echo;
echo "================="
echo ${COUNT}". Required parameter only."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user --required aaa,aaa > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa

echo;echo;echo;
echo "================="
echo ${COUNT}". Required parameter and Environment parameter are specified."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user --required aaa,aaa --env TEST,test > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa
export TEST=test
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa
unset TEST

echo;echo;echo;
echo "================="
echo ${COUNT}". Required parameter and Optional parameter are specified."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user --required aaa,aaa --option bbb,bbb > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa --bbb bbb

echo;echo;echo;
echo "================="
echo ${COUNT}". Required, Optional, Flag parameter are specified. Optional parameter has description."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user --required aaa,aaa,"aaa param is here." --option bbb,bbb,"bbb param is here." --flag ccc,"ccc flag is here." > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa --bbb bbb
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa --bbb bbb --ccc

echo;echo;echo;
echo "================="
echo ${COUNT}". Required, Optional, Flag parameter are specified. Optional parameter has description and default value."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user --required aaa,aaa,"aaa param is here." --option bbb,bbb,"bbb param is here.","DefaultB" --flag ccc,"ccc flag is here." > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa --bbb bbb
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa --bbb bbb --ccc

echo;echo;echo;
echo "================="
echo ${COUNT}". Required, Optional, Flag and Environment parameter are specified with a shorten option. Optional parameter has description and default value. ( a lot of parameters )"
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} -n test -a user -r a111,a111,"a111 param is here." -r a2222,a222222,"a2222 param is here." -r a3,a3,"a3 param is here." -o b1,b11,"b1 param is here.","DefaultB1" -o b22,b2222,"b22 param is here.","DefaultB22" -o b333,b33333,"b333 param is here.","DefaultB333" -f c11111,"c11111 flag is here." -f c222,"c222 flag is here." -f c3,"c3 flag is here." -e T1,t111,"Test" -e T222,t22222,"Test" -e T3,t3,"t3" > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa --bbb bbb
${GENERATED_SCRIPT_FILE_PATH} --aaa aaa --bbb bbb --ccc

echo;echo;echo;
echo "================="
echo ${COUNT}". Optional and Flag parameter are specified. "
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user --option bbb,bbb --flag ccc > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH} --bbb bbb
${GENERATED_SCRIPT_FILE_PATH} --bbb bbb --ccc

echo;echo;echo;
echo "================="
echo ${COUNT}". Strange parameters are specified by free order."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --xxx --flag ccc --yyy --option bbb,bbb --required xxx,xxx --naming test --author user > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH} --xxx xxx
${GENERATED_SCRIPT_FILE_PATH} --bbb bbb --xxx xxx
${GENERATED_SCRIPT_FILE_PATH} --bbb bbb --ccc --xxx xxx
${GENERATED_SCRIPT_FILE_PATH} --debug 
${GENERATED_SCRIPT_FILE_PATH} --debug --xxx xxx

echo;echo;echo;
echo "================="
echo ${COUNT}". Strange parameters are specified with a shorten option by free order."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} -x -f ccc -y -o bbb,bbb -r xxx,xxx -n test -a user > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH} --xxx xxx
${GENERATED_SCRIPT_FILE_PATH} --bbb bbb --xxx xxx
${GENERATED_SCRIPT_FILE_PATH} --bbb bbb --ccc --xxx xxx
${GENERATED_SCRIPT_FILE_PATH} --debug 
${GENERATED_SCRIPT_FILE_PATH} --debug --xxx xxx

echo;echo;echo;
echo "================="
echo ${COUNT}". Strange parameters are specified with a shorten option by free order. Additonaly, generated script supports shorten options too because -s option is specified."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} -x -f ccc -y -o bbb,bbb -r xxx,xxx -n test -a user -s > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH} --xxx xxx
${GENERATED_SCRIPT_FILE_PATH} -b bbb -x xxx
${GENERATED_SCRIPT_FILE_PATH} -b bbb -c -x x
${GENERATED_SCRIPT_FILE_PATH} --debug
${GENERATED_SCRIPT_FILE_PATH} --debug -x xxx

echo;echo;echo;
echo "================="
echo ${COUNT}". Multi line description is specified."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --xxx -f ccc --yyy -o bbb,bbb -r xxx,xxx -n test -a user -s -d "Test script" -d "Second description" -d "Third description" > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH} --xxx xxx
${GENERATED_SCRIPT_FILE_PATH} -b bbb -x xxx
${GENERATED_SCRIPT_FILE_PATH} -b bbb -c -x x
${GENERATED_SCRIPT_FILE_PATH} --debug
${GENERATED_SCRIPT_FILE_PATH} --debug -x xxx
${GENERATED_SCRIPT_FILE_PATH} -x xxx -h
${GENERATED_SCRIPT_FILE_PATH} -x xxx --help

echo;echo;echo;
echo "================="
echo ${COUNT}". Check code of exit status that help is shown."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --xxx -f ccc --yyy -o bbb,bbb -r xxx,xxx -n test -a user -s -d "Test script" -d "Second description" -d "Third description" > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
if [[ "$?" != "1" ]]; then
  echo "==================="
  echo "====== ERROR : Script status != 1 ======"
  echo "==================="
fi
${GENERATED_SCRIPT_FILE_PATH} -x xxx --help
if [[ "$?" != "0" ]]; then
  echo "==================="
  echo "====== ERROR : Script --help status != 0 ======"
  echo "==================="
fi

echo;echo;echo;
echo "================="
echo ${COUNT}". Check help short parameter."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} -n test -a user -s -r aaa,aaa -o bbb,bbb > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
if [[ "$?" != "1" ]]; then
  echo "==================="
  echo "====== ERROR : Script status != 1 ======"
  echo "==================="
fi
${GENERATED_SCRIPT_FILE_PATH} -h
if [[ "$?" != "0" ]]; then
  echo "==================="
  echo "====== ERROR : Script --help status != 0 ======"
  echo "==================="
fi
${GENERATED_SCRIPT_FILE_PATH} --help
if [[ "$?" != "0" ]]; then
  echo "==================="
  echo "====== ERROR : Script --help status != 0 ======"
  echo "==================="
fi
./${SCRIPT_PATH} -n test -a user -s -r aaa,aaa -o bbb,bbb -r hello,hello > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
if [[ "$?" != "1" ]]; then
  echo "==================="
  echo "====== ERROR : Script status != 1 ======"
  echo "==================="
fi
${GENERATED_SCRIPT_FILE_PATH} -a aaa -h hhh
${GENERATED_SCRIPT_FILE_PATH} --help
if [[ "$?" != "0" ]]; then
  echo "==================="
  echo "====== ERROR : Script --help status != 0 ======"
  echo "==================="
fi
./${SCRIPT_PATH} -n test -a user -s -r aaa,aaa -o bbb,bbb -f hello,hello > ${GENERATED_SCRIPT_FILE_PATH}
chmod 777 ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH}
if [[ "$?" != "1" ]]; then
  echo "==================="
  echo "====== ERROR : Script status != 1 ======"
  echo "==================="
fi
${GENERATED_SCRIPT_FILE_PATH} -a aaa -h
${GENERATED_SCRIPT_FILE_PATH} --help
if [[ "$?" != "0" ]]; then
  echo "==================="
  echo "====== ERROR : Script --help status != 0 ======"
  echo "==================="
fi

echo;echo;echo;
echo "================="
echo ${COUNT}". Check ',' handling."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} -n test -a user -d aaa\,bbb\,ccc\,ddd -d eee\,fff\,ggg -s -r aaa,"aaa\,aaa","aaa\,aaaa" -o bbb,bbb\\,bbb,bbb\\,bbb,bbb\\,bbb -f c3,"c3 flag\, is here." -o ddd,"\"ddd\,ddd\\,ddd\""  -e T1,t111\\,t111," Test\,Test" > ${GENERATED_SCRIPT_FILE_PATH}
${GENERATED_SCRIPT_FILE_PATH} --help
${GENERATED_SCRIPT_FILE_PATH}
export T1=aaa
${GENERATED_SCRIPT_FILE_PATH} -a a -o b -d ddd

# STARTER_URL=https://raw.githubusercontent.com/xshoji/bash-script-starter/master/ScriptStarter.sh
# curl -sf ${STARTER_URL} |bash -s - \
#   -n ScriptStarterTest \
#   -a xshoji \
#   -r scriptPath,"/path/to/ScriptStarter.sh" \
#   -s > /tmp/test.sh
