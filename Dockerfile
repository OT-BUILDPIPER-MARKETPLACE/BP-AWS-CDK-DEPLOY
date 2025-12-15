FROM node:20.11.1

RUN apt update -y && apt install -y \
    jq \
    awscli \
    curl \
    git && \
    npm install -g aws-cdk@2.115.0 && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Set environment variables for the Node.js versions you want to use
ENV NODE_VERSION_12="12.18.2"
ENV NODE_VERSION_14="14.17.0"
ENV NODE_VERSION_16="16.15.1"
ENV NODE_VERSION_17="17.7.2"
ENV NODE_VERSION_20_10="20.10.0"
ENV NODE_VERSION_20_11="20.11.1"
ENV NODE_VERSION_20_13="20.13.1"
ENV NODE_VERSION_22="22.9.0"
ENV NODE_VERSION_22_16="22.16.0"

ENV SLEEP_DURATION 5s
ENV INSTRUCTION ""


ADD BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/

ENV ACTIVITY_SUB_TASK_CODE NPM_STEP 

# Install Node.js versions using NVM
RUN echo "source $HOME/.nvm/nvm.sh" >> ~/.bashrc && \
    /bin/bash -c "source $HOME/.nvm/nvm.sh && nvm install $NODE_VERSION_12 && nvm install $NODE_VERSION_14 && nvm install $NODE_VERSION_16 && nvm install $NODE_VERSION_17 && nvm install $NODE_VERSION_20_10 && nvm install $NODE_VERSION_20_11 && nvm install $NODE_VERSION_20_13 && nvm install $NODE_VERSION_22 && nvm install $NODE_VERSION_22_16"

COPY build-ift.sh .    
RUN chmod 777 build-ift.sh
ENTRYPOINT [ "./build-ift.sh" ]
