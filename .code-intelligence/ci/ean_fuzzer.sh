#!/bin/sh
export LC_ALL=C
# Display name of the project.
PROJECT='zint'
# Display name of the campaign to be run.
CAMPAIGN='ean_fuzzer'
# Address of the fuzzing service
FUZZING_SERVICE_URL='grpc-api.code-intelligence.com:443'
# Address of the fuzzing web interface
WEB_APP_URL='app.code-intelligence.com'

CICTL='cictl-2.18.1-linux';
CICTL_VERSION='2.18.1';
CICTL_SHA256SUM='2591a7f61632ad4c04d1a5476fec6ff75ced8bd2b92ac61ad2634abe45297787';
CICTL_URL='https://s3.eu-central-1.amazonaws.com/public.code-intelligence.com/cictl/cictl-2.18.1-linux';
FINDINGS_TYPE='CRASH';
TIMEOUT='180'
#Email that will receive reports if any finding is encountered.
#CI_FUZZING_REPORT_EMAIL_RECIPIENT='user@example.com'
GIT_BRANCH='master'

export PROJECT
export CAMPAIGN
export FUZZING_SERVICE_URL
export ICTL
export CICTL_VERSION
export CICTL_SHA256SUM
export CICTL_URL
export FINDINGS_TYPE
export TIMEOUT
export GIT_BRANCH


set -eu
# Download cictl if it doesn't exist already
if [ ! -f "${CICTL}" ]; then
 wget "${CICTL_URL}" -O "${CICTL}"
fi
# Verify the checksum
echo "${CICTL_SHA256SUM} ${CICTL}" | sha256sum --check

# Make it executable
chmod +x "${CICTL}"


set -eu
# Log in
#CIFUZZ_TOKEN is set as "encrypted value" in the travis
./${CICTL} login -t "${CIFUZZ_TOKEN}"
# Start Fuzzing
LOG_FILE="start-$(basename "ean_fuzzer").logs"

./${CICTL} start_fuzzing --daemon_listen_address="${FUZZING_SERVICE_URL}" --project_name="${PROJECT}" --campaign_name="${CAMPAIGN}" --git_branch="${GIT_BRANCH#*/}" | tee "${LOG_FILE}"

set -eu
# Get the name of the started campaign run from the logs
LOG_FILE="start-$(basename "ean_fuzzer").logs"
LINE=$(grep "display_name:" "${LOG_FILE}")
CAMPAIGN_RUN=${LINE#*"display_name: "}

#sleep 10

# Monitor Fuzzing
./${CICTL} monitor_campaign_run \
--daemon_listen_address="${FUZZING_SERVICE_URL}" \
--dashboard_address="${WEB_APP_URL}" \
--project_name="${PROJECT}" \
--campaign_run_name="${CAMPAIGN_RUN}" \
--duration="${TIMEOUT}" \
--findings_type="${FINDINGS_TYPE}"
