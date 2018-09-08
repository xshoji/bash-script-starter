#!/bin/bash

function usage()
{
cat << _EOT_

   FunctionStarterTest   
  ---------------------- author: xshoji

  Usage:
    ./$(basename "$0") --scriptPath FunctionStarter.sh
 
  Description:
    This is FunctionStarterTest
 
  Required parameters:
    --scriptPath FunctionStarter.sh : FunctionStarter.sh is specified as scriptPath
 
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
FUNCTION_NAME="getUserData"
#trap "rm -rf ${TEST_FILE}" EXIT

echo ""
echo "================="
echo ${COUNT}". error no parameter"
COUNT=$(( COUNT + 1 ))
bash ${SCRIPT_PATH}

echo ""
echo "================="
echo ${COUNT}". ok"
COUNT=$(( COUNT + 1 ))
bash ${SCRIPT_PATH} -n ${FUNCTION_NAME} |tee ${TEST_FILE}
echo ${FUNCTION_NAME} >> ${TEST_FILE}
sh ${TEST_FILE}

echo ""
echo "================="
echo ${COUNT}". ok with description one line"
COUNT=$(( COUNT + 1 ))
bash ${SCRIPT_PATH} -n ${FUNCTION_NAME} -d "A function description." |tee ${TEST_FILE}
echo ${FUNCTION_NAME} >> ${TEST_FILE}
sh ${TEST_FILE}

echo ""
echo "================="
echo ${COUNT}". ok with description multiple lines"
COUNT=$(( COUNT + 1 ))
bash ${SCRIPT_PATH} -n ${FUNCTION_NAME} -d "A function description." -d "line 2." -d "line 3." |tee ${TEST_FILE}
echo ${FUNCTION_NAME} >> ${TEST_FILE}
sh ${TEST_FILE}

echo ""
echo "================="
echo ${COUNT}". one required argument"
COUNT=$(( COUNT + 1 ))
bash ${SCRIPT_PATH} -n ${FUNCTION_NAME} -r name,Taro,"A user name" |tee ${TEST_FILE}
echo ${FUNCTION_NAME} >> ${TEST_FILE}
sh ${TEST_FILE}
sed -i '' "s/^${FUNCTION_NAME}/${FUNCTION_NAME} --name Taro/g" ${TEST_FILE}
sh ${TEST_FILE}

echo ""
echo "================="
echo ${COUNT}". multiple required arguments"
COUNT=$(( COUNT + 1 ))
bash ${SCRIPT_PATH} -n ${FUNCTION_NAME} -r name,Taro,"A user name" -r country,Japan,"A country" |tee ${TEST_FILE}
echo ${FUNCTION_NAME} >> ${TEST_FILE}
sh ${TEST_FILE}
sed -i '' "s/^${FUNCTION_NAME}/${FUNCTION_NAME} --name Taro/g" ${TEST_FILE}
sh ${TEST_FILE}
sed -i '' "s/^${FUNCTION_NAME}/${FUNCTION_NAME} --name Taro --country Japan   /g" ${TEST_FILE}
sh ${TEST_FILE}

echo ""
echo "================="
echo ${COUNT}". multiple required arguments and one optional argument"
COUNT=$(( COUNT + 1 ))
bash ${SCRIPT_PATH} -n ${FUNCTION_NAME} -r name,Taro,"A user name" -r country,Japan,"A country" -o language,Japanese,"A user language" |tee ${TEST_FILE}
echo ${FUNCTION_NAME} >> ${TEST_FILE}
sed -i '' "s/^${FUNCTION_NAME}/${FUNCTION_NAME} --name Taro --country Japan /g" ${TEST_FILE}
sh ${TEST_FILE}
sed -i '' "s/^${FUNCTION_NAME}/${FUNCTION_NAME} --name Taro --country Japan --language English/g" ${TEST_FILE}
sh ${TEST_FILE}

echo ""
echo "================="
echo ${COUNT}". multiple required arguments and multiple optional argument"
COUNT=$(( COUNT + 1 ))
bash ${SCRIPT_PATH} -n ${FUNCTION_NAME} -r name,Taro,"A user name" -r country,Japan,"A country" -o language,Japanese,"A user language" -o age,30,"age" |tee ${TEST_FILE}
echo ${FUNCTION_NAME} >> ${TEST_FILE}
sed -i '' "s/^${FUNCTION_NAME}/${FUNCTION_NAME} --name Taro --country Japan --language English/g" ${TEST_FILE}
sh ${TEST_FILE}
sed -i '' "s/^${FUNCTION_NAME}/${FUNCTION_NAME} --name Taro --country Japan --language English --age 30/g" ${TEST_FILE}
sh ${TEST_FILE}

echo ""
echo "================="
echo ${COUNT}". multiple required arguments and multiple optional argument and one flag arugment"
COUNT=$(( COUNT + 1 ))
bash ${SCRIPT_PATH} -n ${FUNCTION_NAME} -r name,Taro,"A user name" -r country,Japan,"A country" -o language,Japanese,"A user language" -o age,30,"age" -f isBrother,"Enable brother flag" |tee ${TEST_FILE}
echo ${FUNCTION_NAME} >> ${TEST_FILE}
sed -i '' "s/^${FUNCTION_NAME}/${FUNCTION_NAME} --name Taro --country Japan --language English --age 30/g" ${TEST_FILE}
sh ${TEST_FILE}
sed -i '' "s/^${FUNCTION_NAME}/${FUNCTION_NAME} --name Taro --country Japan --language English --age 30 --isBrother/g" ${TEST_FILE}
sh ${TEST_FILE}

echo ""
echo "================="
echo ${COUNT}". multiple required arguments and multiple optional argument and multiple flag arugment"
COUNT=$(( COUNT + 1 ))
bash ${SCRIPT_PATH} -n ${FUNCTION_NAME} -r name,Taro,"A user name" -r country,Japan,"A country" -o language,Japanese,"A user language" -o age,30,"age" -f isBrother,"Enable brother flag" -f isDryRun,"Enable dryrun mode" |tee ${TEST_FILE}
echo ${FUNCTION_NAME} >> ${TEST_FILE}
sed -i '' "s/^${FUNCTION_NAME}/${FUNCTION_NAME} --name Taro --country Japan --language English --age 30/g" ${TEST_FILE}
sh ${TEST_FILE}
sed -i '' "s/^${FUNCTION_NAME}/${FUNCTION_NAME} --name Taro --country Japan --language English --age 30  --isBrother --isDryRun/g" ${TEST_FILE}
sh ${TEST_FILE}

echo ""
echo "================="
echo ${COUNT}". random order argument"
COUNT=$(( COUNT + 1 ))
bash ${SCRIPT_PATH} -n ${FUNCTION_NAME} -f isDryRun,"Enable dryrun mode" -r name,Taro,"A user name" -o language,Japanese,"A user language" -r country,Japan,"A country" -o age,30,"age" -f isBrother,"Enable brother flag" |tee ${TEST_FILE}
echo ${FUNCTION_NAME} >> ${TEST_FILE}
sed -i '' "s/^${FUNCTION_NAME}/${FUNCTION_NAME} --name Taro --country Japan --language English --age 30/g" ${TEST_FILE}
sh ${TEST_FILE}
sed -i '' "s/^${FUNCTION_NAME}/${FUNCTION_NAME} --name Taro --country Japan --language English --age 30  --isBrother --isDryRun/g" ${TEST_FILE}
sh ${TEST_FILE}
