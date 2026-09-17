#!/bin/bash

set -e

echo "======================================"
echo "Starting Trivy Image Scan"
echo "======================================"

IMAGE_TAG="${GIT_COMMIT:0:7}"

echo "Image Tag: ${IMAGE_TAG}"
echo "Changed Services: ${CHANGED_SERVICES}"

if [ -z "${CHANGED_SERVICES}" ]; then
    echo "No application services changed."
    echo "Skipping Trivy scan."
    exit 0
fi

for SERVICE in ${CHANGED_SERVICES}
do

    IMAGE="${SERVICE}:${IMAGE_TAG}"

    echo "======================================"
    echo "Scanning ${IMAGE}"
    echo "======================================"

    trivy image \
        --severity HIGH,CRITICAL \
        --exit-code 1 \
        "${IMAGE}"

    echo "${IMAGE} passed Trivy scan."

done

echo "======================================"
echo "Trivy Image Scan Completed"
echo "======================================"
