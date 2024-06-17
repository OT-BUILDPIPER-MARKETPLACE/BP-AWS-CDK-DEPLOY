FROM node:20

RUN apt-get update && \
    apt-get install -y awscli jq curl && \
    npm install -g aws-cdk@2.115.0

RUN apt-get install -y git

COPY build.sh .

ADD BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/

ENV INSTRUCTION ""
ENV SLEEP_DURATION 5s
ENV VALIDATION_FAILURE_ACTION WARNING

ENTRYPOINT [ "./build.sh" ]