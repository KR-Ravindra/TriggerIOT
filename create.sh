#!/bin/sh

apt update
apt install uuid-runtime -y
jobID=$(uuidgen)
echo $jobID
aws configure set default.region us-east-1
aws iot list-jobs
aws iot create-job  \
      --job-id $jobID  \
      --targets arn:aws:iot:us-east-1:524057922460:thing/UV-Arden-001 \
      --document-source https://s3.amazonaws.com/addverb-firmware/UV-Arden-001  \
      --timeout-config inProgressTimeoutInMinutes=100 \
      --job-executions-rollout-config "{ \"exponentialRate\": { \"baseRatePerMinute\": 50, \"incrementFactor\": 2, \"rateIncreaseCriteria\": { \"numberOfSucceededThings\": 1000}}, \"maximumPerMinute\": 1000}" \
      --abort-config "{ \"criteriaList\": [ { \"action\": \"CANCEL\", \"failureType\": \"FAILED\", \"minNumberOfExecutedThings\": 100, \"thresholdPercentage\": 20}, { \"action\": \"CANCEL\", \"failureType\": \"TIMED_OUT\", \"minNumberOfExecutedThings\": 200, \"thresholdPercentage\": 50}]}" 
