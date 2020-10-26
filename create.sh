#!/bin/bash

apt update
apt install uuid-runtime -y
jobID=$(uuidgen)

aws configure set default.region us-east-1
aws iot create-job  \
      --job-id $jobID  \
      --targets arn:aws:iot:us-east-1:629707839273:thing/UV-ARDEN-001 \
      --document-source https://s3.amazonaws.com/ota-addverb/download-files.json  \
      --timeout-config inProgressTimeoutInMinutes=100 \
      --job-executions-rollout-config "{ \"exponentialRate\": { \"baseRatePerMinute\": 50, \"incrementFactor\": 2, \"rateIncreaseCriteria\": { \"numberOfSucceededThings\": 1000}}, \"maximumPerMinute\": 1000}" \
      --abort-config "{ \"criteriaList\": [ { \"action\": \"CANCEL\", \"failureType\": \"FAILED\", \"minNumberOfExecutedThings\": 100, \"thresholdPercentage\": 20}, { \"action\": \"CANCEL\", \"failureType\": \"TIMED_OUT\", \"minNumberOfExecutedThings\": 200, \"thresholdPercentage\": 50}]}" 
