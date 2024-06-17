#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh

TASK_STATUS=0

CODEBASE_LOCATION="${WORKSPACE}"/"${CODEBASE_DIR}"
logInfoMessage "Executing at [$CODEBASE_LOCATION]"
sleep  $SLEEP_DURATION
cd  "${CODEBASE_LOCATION}"

TASK_STATUS=0

cdk --version

echo ""

npm run $INSTRUCTION

if [ $? -eq 0 ]; then
    logErrorMessage "Success"
else
    TASK_STATUS=1
    logErrorMessage "Failed"

fi
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}