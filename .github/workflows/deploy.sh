#!/bin/env bash
echo "AID: ${artifact_id}"
echo "Deploy ID: $(cd ${RUNNER_TEMP}/${repo} && git rev-parse HEAD)"

