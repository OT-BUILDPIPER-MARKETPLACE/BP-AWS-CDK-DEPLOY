#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh

sleep "$SLEEP_DURATION"

##############################################
# Assume Role (SAFE - runtime creds only)
##############################################
if [ "$ASSUME_OTHER_ROLE" == true ]; then
  role_output=$(aws sts assume-role \
    --role-arn "arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME" \
    --role-session-name "$ROLE_SESSION_NAME")

  if [ $? -ne 0 ]; then
    logErrorMessage "Failed to assume role."
    exit 1
  fi

  AWS_ACCESS_KEY_ID=$(echo "$role_output" | jq -r '.Credentials.AccessKeyId')
  AWS_SECRET_ACCESS_KEY=$(echo "$role_output" | jq -r '.Credentials.SecretAccessKey')
  AWS_SESSION_TOKEN=$(echo "$role_output" | jq -r '.Credentials.SessionToken')

  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
  export AWS_SESSION_TOKEN
fi

##############################################
# Debug
##############################################
if [ "$DEBUG" = true ]; then
  set -x
fi

##############################################
# Validations
##############################################
if [ -z "$CODEBASE_DIRS" ]; then
  logErrorMessage "Error: CODEBASE_DIRS is not set"
  exit 1
fi

if [ -z "$INSTRUCTION" ]; then
  logErrorMessage "Error: INSTRUCTION is not set (install/build/test/etc.)"
  exit 1
fi

if [ -z "$VERSION" ]; then
  logErrorMessage "Error: VERSION is not set"
  exit 1
fi

if [ "$SKIP_STEP" = true ]; then
  logInfoMessage "Skipping the step as SKIP_STEP is set to true."
  exit 0
fi

##############################################
# Helpers
##############################################
configure_git_identity() {
  git config user.email "svc_git_devsecopspro@users.noreply.github.com"
  git config user.name "svc_git_devsecopspro"
}

configure_npmrc_for_github_packages() {
  # IMPORTANT:
  # - NO hardcoded token in repo/script
  # - Token must come from masked env var: GITHUB_NPM_TOKEN
  if [ -z "$GITHUB_NPM_TOKEN" ]; then
    logErrorMessage "GITHUB_NPM_TOKEN is not set. Required for @operations packages from npm.github.wm.com"
    exit 1
  fi

  # Create/overwrite ~/.npmrc safely
  cat <<EOF > ~/.npmrc
registry=https://registry.npmjs.org/
@operations:registry=https://npm.github.wm.com
//npm.github.wm.com/:_authToken=${GITHUB_NPM_TOKEN}
always-auth=true
strict-ssl=false
EOF
}

##############################################
# Split CODEBASE_DIRS into array
##############################################
IFS=',' read -ra DIRS <<< "$CODEBASE_DIRS"
logInfoMessage "Codebase dirs: $CODEBASE_DIRS"

##############################################
# Loop through dirs
##############################################
for dir in "${DIRS[@]}"; do
  FULL_DIR="${WORKSPACE}/${dir}"

  logInfoMessage "Processing directory: $FULL_DIR"
  sleep "$SLEEP_DURATION"
  cd "$FULL_DIR" || { logErrorMessage "Failed to cd into directory $FULL_DIR"; exit 1; }

  ##############################################
  # Load NVM
  ##############################################
  source "$HOME/.nvm/nvm.sh"

  if [ "$LIST" = true ]; then
    ls -al
  fi

  ##############################################
  # Switch Node + run per-version logic
  ##############################################
  if [ "$VERSION" == "12.18.2" ]; then
    echo "Switching to Node.js 12.18.2"
    nvm use "$VERSION" || exit 1
    npm install -g rimraf
    npm install -g typescript
    npm install -g jest
    npm install -g ts-node
    npm install -g ts-jest
    npm install aws-sdk
    npm install uuid
    npm install aws-lambda
    npm "$INSTRUCTION"

  elif [ "$VERSION" == "14.17.0" ]; then
    echo "Switching to Node.js 14.17.0"
    nvm use "$VERSION" || exit 1
    npm install -g rimraf
    npm install -g typescript
    npm install -g jest
    npm install -g ts-node
    npm install -g ts-jest
    npm install aws-sdk
    npm install uuid
    npm install aws-lambda
    npm "$INSTRUCTION"

  elif [ "$VERSION" == "16.15.1" ]; then
    echo "Switching to Node.js 16.15.1"
    nvm use "$VERSION" || exit 1
    npm install -g rimraf
    npm install -g typescript
    npm install -g jest
    npm install -g ts-node
    npm install -g ts-jest
    npm install aws-sdk
    npm install uuid
    npm install aws-lambda
    npm "$INSTRUCTION"

  elif [ "$VERSION" == "17.7.2" ]; then
    echo "Switching to Node.js 17.7.2"
    nvm use "$VERSION" || exit 1
    npm install -g rimraf
    npm install -g typescript
    npm install -g jest
    npm install -g ts-node
    npm install -g ts-jest
    npm install aws-sdk
    npm install uuid
    npm install aws-lambda
    npm "$INSTRUCTION"

  elif [ "$VERSION" == "20.10.0" ]; then
    echo "Switching to Node.js 20.10.0"
    nvm use "$VERSION" || exit 1

    # Original behavior: set git identity + configure GitHub packages auth in ~/.npmrc
    configure_git_identity
    configure_npmrc_for_github_packages

    npm install -g rimraf
    npm install -g typescript
    npm install -g jest
    npm install -g ts-node
    npm install -g ts-jest

    npm install
    npm "$INSTRUCTION"

  elif [ "$VERSION" == "20.11.1" ]; then
    echo "Switching to Node.js 20.11.1"
    nvm use "$VERSION" || exit 1
    npm install -g rimraf
    npm install -g typescript
    npm install -g jest
    npm install -g ts-node
    npm install -g ts-jest
    npm install aws-sdk
    npm install uuid
    npm install aws-lambda
    npm "$INSTRUCTION"

  elif [ "$VERSION" == "20.13.1" ]; then
    echo "Switching to Node.js 20.13.1"
    nvm use "$VERSION" || exit 1

    npm install -g rimraf --loglevel error
    npm install -g typescript --loglevel error
    npm install -g jest --loglevel error
    npm install -g ts-node --loglevel error
    npm install -g ts-jest --loglevel error
    npm install -g aws-cdk --loglevel error

    # Original behavior: configure git + npmrc for GitHub packages
    configure_git_identity
    configure_npmrc_for_github_packages

    # Original had npm install commented; keeping as-is (do not force install)
    npm "$INSTRUCTION"

  elif [ "$VERSION" == "20.13.1-sdk" ]; then
    echo "Switching to Node.js 20.13.1 (sdk)"
    nvm use "20.13.1" || exit 1

    npm install -g rimraf
    npm install -g typescript
    npm install -g jest
    npm install -g ts-node
    npm install -g ts-jest

    # Install aws-sdk and aws-sdk clients locally in your project
    npm install aws-sdk
    npm install --save-dev @types/aws-sdk
    npm install @aws-sdk/client-dynamodb @aws-sdk/client-sns

    # Original behavior: configure git + npmrc for GitHub packages
    configure_git_identity
    configure_npmrc_for_github_packages

    npm install
    npm "$INSTRUCTION"

  elif [ "$VERSION" == "22.9.0" ]; then
    echo "Switching to Node.js 22.9.0"
    nvm use "$VERSION" || exit 1
    npm install -g rimraf
    npm install -g typescript
    npm install -g jest
    npm install -g ts-node
    npm install -g ts-jest
    npm install aws-sdk
    npm install uuid
    npm install aws-lambda
    npm "$INSTRUCTION"

  elif [ "$VERSION" == "22.15.0" ]; then
    echo "Switching to Node.js 22.15.0"
    nvm use "$VERSION" || exit 1

    npm install -g rimraf
    npm install -g typescript
    npm install -g jest
    npm install -g ts-node
    npm install -g ts-jest

    # Original behavior: configure git + npmrc for GitHub packages
    configure_git_identity
    configure_npmrc_for_github_packages

    npm install
    npm "$INSTRUCTION"

  else
    logErrorMessage "Node.js version $VERSION is not supported"
    exit 1
  fi

  TASK_STATUS=$?
done

saveTaskStatus "${TASK_STATUS}" "${ACTIVITY_SUB_TASK_CODE}"
