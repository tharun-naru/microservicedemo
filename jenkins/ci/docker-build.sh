#!/bin/bash

set -e

echo "======================================"
echo "Starting Docker Image Build"
echo "======================================"

IMAGE_TAG="${GIT_COMMIT:0:7}"

echo "Docker Image Tag: ${IMAGE_TAG}"
echo "Changed Services: ${CHANGED_SERVICES}"

if [ -z "${CHANGED_SERVICES}" ]; then

    echo "No application services changed."
    echo "Skipping Docker image build."

    exit 0
fi

for SERVICE in ${CHANGED_SERVICES}
do

    echo "======================================"
    echo "Building ${SERVICE}"
    echo "======================================"

    docker build \
        -t "${SERVICE}:${IMAGE_TAG}" \
        -f "${SERVICE}/Dockerfile" \
        .

    echo "${SERVICE}:${IMAGE_TAG} built successfully."

done

echo "======================================"
echo "Docker Image Build Completed"
echo "======================================"
