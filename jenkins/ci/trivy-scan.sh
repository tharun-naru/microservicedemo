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

echo "======================================"
echo "Pulling Trivy Image"
echo "======================================"

docker pull aquasec/trivy:latest

echo "Trivy image pulled successfully."

for SERVICE in ${CHANGED_SERVICES}
do

    IMAGE="${SERVICE}:${IMAGE_TAG}"

    echo "======================================"
    echo "Scanning ${IMAGE}"
    echo "======================================"

    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy:latest \
        image \
        --severity HIGH,CRITICAL \
        --exit-code 0 \
        "${IMAGE}"

    echo "${IMAGE} passed Trivy scan."

done

echo "======================================"
echo "Trivy Image Scan Completed"
echo "======================================"
