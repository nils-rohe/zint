pipeline {
  agent any
  stages {
    stage ('Prepare fuzz test') {
      environment {
        // Name of the project to fuzz
        PROJECT_NAME = 'projects/organizations_98ca903996ebf78e_zint-6fcab85e'
        // Address of the fuzzing service
        FUZZING_SERVER_URL = 'nightly.code-intelligence.com:6773'
        // Address of the fuzzing web interface
        WEB_APP_ADDRESS =  'https://nightly.code-intelligence.com'

        // Credentials for accessing the fuzzing service
        CI_FUZZ_API_TOKEN = credentials('CI_FUZZ_API_TOKEN_NIGHTLY')
        CICTL = "${WORKSPACE}/cictl-3.12.0-linux";
        CICTL_VERSION = '3.12.0';
        CICTL_URL = 'https://s3.eu-central-1.amazonaws.com/public.code-intelligence.com/cictl/cictl-3.12.0-linux';
        FINDINGS_TYPE = 'CRASH';
        TIMEOUT = '900'
  
      }

      stages {
        stage ('Download cictl') {
          steps {
            sh '''
              set -eu

              # Download cictl if it doesn't exist already
              if [ ! -f "${CICTL}" ]; then
                curl -L "${CICTL_URL}" -o "${CICTL}"
              fi
              # Make it executable
              chmod +x "${CICTL}"
            '''
          }
        }

        stage ('Build fuzz test') {
          steps {
            sh '''
              set -eu

              # Switch to build directory
              mkdir -p "${BUILD_TAG}"
              cd "${BUILD_TAG}"

              # Log in
              echo "${CI_FUZZ_API_TOKEN}" | $CICTL --server="${FUZZING_SERVER_URL}" login --quiet

              # $CI_COMMIT_SHA may be specified in the Jenkins pipeline,
              # or, if using the Git plugin, $GIT_COMMIT could be used.
              if [ -z "${CI_COMMIT_SHA:-}" ]; then
                CI_COMMIT_SHA=${GIT_COMMIT:-}
              fi
              
              # In a Jenkins multibranch pipeline run for a pull request,
              # $CHANGE_BRANCH contains the actual branch name. If not set,
              # we fall back to $GIT_BRANCH, which is set by the Git plugin.
              CI_GIT_BRANCH=${CHANGE_BRANCH:-${GIT_BRANCH:-}}

              # Start fuzzing.
              CAMPAIGN_RUN=$(${CICTL} start \\
                --server="${FUZZING_SERVER_URL}" \\
                --report-email="${REPORT_EMAIL:-}" \\
                --git-branch="${CI_GIT_BRANCH:-}" \\
                --commit-sha="${CI_COMMIT_SHA:-}" \\
                "${PROJECT_NAME}")

              # Store the campaign run name for the next stage
              OUTFILE="campaign-run"
              echo "${CAMPAIGN_RUN}" > "${OUTFILE}"
            '''
          }
        }

        stage ('Start fuzz test') {
          steps {
            sh '''
              set -eu

              # Switch to build directory
              cd "${BUILD_TAG}"

              # Get the name of the started campaign run
              INFILE="campaign-run"
              CAMPAIGN_RUN=$(cat ${INFILE})

              # Log in
              echo "${CI_FUZZ_API_TOKEN}" | ${CICTL} --server="${FUZZING_SERVER_URL}" login --quiet

              # Monitor Fuzzing
              ${CICTL} monitor_campaign_run \\
                --server="${FUZZING_SERVER_URL}" \\
                --dashboard_address="${WEB_APP_ADDRESS}" \\
                --duration="${TIMEOUT}" \\
                --findings_type="${FINDINGS_TYPE}" \\
                "${CAMPAIGN_RUN}"
            '''
          }
        }
      }
    }
  }

  post {
    always {
        sh '''
        set -eu

        # Switch to build directory
        cd "${BUILD_TAG}"

        # Check if there are any findings
        if ! stat -t finding-*.json > /dev/null 2>&1; then
          # There are no findings, so there's nothing to do
          exit
        fi

        JQ="${WORKSPACE}/jq"
        JQ_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
        JQ_CHECKSUM=af986793a515d500ab2d35f8d2aecd656e764504b789b66d7e1a0b727a124c44

        # Check if jq already exists
        if [ -f "${JQ}" ]; then
          # The file already exists. Verify the checksum.
          if ! echo "${JQ_CHECKSUM}" "${JQ}" | sha256sum --check; then
            # The checksum of the existing file doesn't match. Download
            # it again.
            curl -L "${JQ_URL}" -o "${JQ}"
          fi
        else
        # The file doesn't exist yet, download it
          curl -L "${JQ_URL}" -o "${JQ}"
        fi

        # Verify the checksum
        echo "${JQ_CHECKSUM}" "${JQ}" | sha256sum --check

        # Make it executable
        chmod +x "${JQ}"

        # Merge findings into one file
        "${JQ}" --slurp '.' finding-*.json > cifuzz_findings.json
        '''

        archiveArtifacts artifacts: "${BUILD_TAG}/cifuzz_findings.json", fingerprint: true
    }
  }
}
