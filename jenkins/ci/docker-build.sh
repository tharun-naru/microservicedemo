#!/bin/bash

set -e

echo "======================================"
echo "Starting Docker Image Build"
echo "======================================"

IMAGE_TAG="${GIT_COMMIT:0:7}"

echo "Docker Image Tag: ${IMAGE_TAG}"

SERVICES=(
    "auth-service"
    "gateway-service"
    "user-service"
    "admin-service"
    "employee-service"
    "customer-service"
    "hr-service"
    "task-service"
)

for SERVICE in "${SERVICES[@]}"
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
echo "All Docker Images Built Successfully"
echo "======================================"

docker images
