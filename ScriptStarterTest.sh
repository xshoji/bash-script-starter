#!/bin/bash

function usage()
{
cat << _EOT_

   ScriptStarterTest   
  ---------------------- author: xshoji

  Usage:
    ./$(basename "$0") --scriptPath ScriptStarter.sh
 
  Description:
    This is ScriptStarterTest
 
  Required parameters:
    --scriptPath ScriptStarter.sh : ScriptStarter.sh is specified as scriptPath
 
  Optional parameters:
    --debug,-d : Enable debug mode

_EOT_
exit 1
}




#------------------------------------------
# Preparation
#------------------------------------------

# Parse parameters
for ARG in "$@"
do
    SHIFT="true"
    ([ "${ARG}" == "--debug" ] || [ "${ARG}" == "-d" ]) && { shift 1; set -x; SHIFT="false"; }
    ([ "${ARG}" == "--scriptPath" ] || [ "${ARG}" == "-s" ]) && { shift 1; SCRIPT_PATH=${1}; SHIFT="false"; }
    ([ "${SHIFT}" == "true" ] && [ "$#" -gt 0 ]) && { shift 1; }
done
# Check required parameters
[ -z "${SCRIPT_PATH+x}" ] && { echo "[!] --scriptPath is required. "; INVALID_STATE="true"; }
[ ! -z "${INVALID_STATE+x}" ] && { usage; exit 1; }



#------------------------------------------
# Main
#------------------------------------------
COUNT=1
TEST_FILE=/tmp/test.sh
#trap "rm -rf ${TEST_FILE}" EXIT


echo ""
echo "================="
echo ${COUNT}". error."
COUNT=$(( COUNT + 1 ))
bash ${SCRIPT_PATH}

echo ""
echo "================="
echo ${COUNT}". ok."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user > ${TEST_FILE}
chmod 777 ${TEST_FILE}
${TEST_FILE}

echo ""
echo "================="
echo ${COUNT}". Required parameter only."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user --required aaa,aaa > ${TEST_FILE}
chmod 777 ${TEST_FILE}
${TEST_FILE}
${TEST_FILE} --aaa aaa

echo ""
echo "================="
echo ${COUNT}". Required parameter and Environment parameter are specified."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user --required aaa,aaa --env TEST,test > ${TEST_FILE}
chmod 777 ${TEST_FILE}
${TEST_FILE}
${TEST_FILE} --aaa aaa
export TEST=test
${TEST_FILE} --aaa aaa
unset TEST

echo ""
echo "================="
echo ${COUNT}". Required parameter and Optional parameter are specified."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user --required aaa,aaa --option bbb,bbb > ${TEST_FILE}
chmod 777 ${TEST_FILE}
${TEST_FILE}
${TEST_FILE} --aaa aaa
${TEST_FILE} --aaa aaa --bbb bbb

echo ""
echo "================="
echo ${COUNT}". Required, Optional, Flag parameter are specified. Optional parameter has description."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user --required aaa,aaa,"aaa param is here." --option bbb,bbb,"bbb param is here." --flag ccc,"ccc flag is here." > ${TEST_FILE}
chmod 777 ${TEST_FILE}
${TEST_FILE}
${TEST_FILE} --aaa aaa
${TEST_FILE} --aaa aaa --bbb bbb
${TEST_FILE} --aaa aaa --bbb bbb --ccc

echo ""
echo "================="
echo ${COUNT}". Required, Optional, Flag parameter are specified. Optional parameter has description and default value."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user --required aaa,aaa,"aaa param is here." --option bbb,bbb,"bbb param is here.","DefaultB" --flag ccc,"ccc flag is here." > ${TEST_FILE}
chmod 777 ${TEST_FILE}
${TEST_FILE}
${TEST_FILE} --aaa aaa
${TEST_FILE} --aaa aaa --bbb bbb
${TEST_FILE} --aaa aaa --bbb bbb --ccc

echo ""
echo "================="
echo ${COUNT}". Required, Optional and Flag parameter are specified with a shorten option. Optional parameter has description and default value. ( a lot of parameters )"
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} -n test -a user -r a111,a111,"a111 param is here." -r a2222,a222222,"a2222 param is here." -r a3,a3,"a3 param is here." -o b1,b11,"b1 param is here.","DefaultB1" -o b22,b2222,"b22 param is here.","DefaultB22" -o b333,b33333,"b333 param is here.","DefaultB333" -f c11111,"c11111 flag is here." -f c222,"c222 flag is here." -f c3,"c3 flag is here." > ${TEST_FILE}
chmod 777 ${TEST_FILE}
${TEST_FILE}
${TEST_FILE} --aaa aaa
${TEST_FILE} --aaa aaa --bbb bbb
${TEST_FILE} --aaa aaa --bbb bbb --ccc

echo ""
echo "================="
echo ${COUNT}". Optional and Flag parameter are specified. "
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --naming test --author user --option bbb,bbb --flag ccc > ${TEST_FILE}
chmod 777 ${TEST_FILE}
${TEST_FILE}
${TEST_FILE} --bbb bbb
${TEST_FILE} --bbb bbb --ccc

echo ""
echo "================="
echo ${COUNT}". Strange parameters are specified by free order."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --xxx --flag ccc --yyy --option bbb,bbb --required xxx,xxx --naming test --author user > ${TEST_FILE}
chmod 777 ${TEST_FILE}
${TEST_FILE}
${TEST_FILE} --xxx xxx
${TEST_FILE} --bbb bbb --xxx xxx
${TEST_FILE} --bbb bbb --ccc --xxx xxx
${TEST_FILE} --debug 
${TEST_FILE} --debug --xxx xxx

echo ""
echo "================="
echo ${COUNT}". Strange parameters are specified with a shorten option by free order."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} -x -f ccc -y -o bbb,bbb -r xxx,xxx -n test -a user > ${TEST_FILE}
chmod 777 ${TEST_FILE}
${TEST_FILE}
${TEST_FILE} --xxx xxx
${TEST_FILE} --bbb bbb --xxx xxx
${TEST_FILE} --bbb bbb --ccc --xxx xxx
${TEST_FILE} --debug 
${TEST_FILE} --debug --xxx xxx

echo ""
echo "================="
echo ${COUNT}". Strange parameters are specified with a shorten option by free order. Additonaly, generated script supports shorten options too because -s option is specified."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} -x -f ccc -y -o bbb,bbb -r xxx,xxx -n test -a user -s > ${TEST_FILE}
chmod 777 ${TEST_FILE}
${TEST_FILE}
${TEST_FILE} --xxx xxx
${TEST_FILE} -b bbb -x xxx
${TEST_FILE} -b bbb -c -x x
${TEST_FILE} --debug
${TEST_FILE} --debug -x xxx

echo ""
echo "================="
echo ${COUNT}". Multi line description is specified."
COUNT=$(( COUNT + 1 ))
./${SCRIPT_PATH} --xxx -f ccc --yyy -o bbb,bbb -r xxx,xxx -n test -a user -s -d "Test script" -d "Second description" -d "Third description" > ${TEST_FILE}
chmod 777 ${TEST_FILE}
${TEST_FILE}
${TEST_FILE} --xxx xxx
${TEST_FILE} -b bbb -x xxx
${TEST_FILE} -b bbb -c -x x
${TEST_FILE} --debug
${TEST_FILE} --debug -x xxx
${TEST_FILE} -x xxx -h
${TEST_FILE} -x xxx --help
