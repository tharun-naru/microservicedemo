#!/bin/bash

set -e

echo "======================================"
echo "Detecting Changes"
echo "======================================"

echo "Current Commit:"
echo "${GIT_COMMIT}"

echo "Previous Commit:"
echo "${GIT_PREVIOUS_COMMIT}"

if [ -z "${GIT_PREVIOUS_COMMIT}" ]; then
    echo "No previous commit found."
    echo "This may be the first build."
    echo "Treating all services as changed."

    CHANGED_SERVICES="auth-service gateway-service user-service admin-service employee-service customer-service hr-service task-service"

else

    CHANGED_FILES=$(git diff --name-only "${GIT_PREVIOUS_COMMIT}" "${GIT_COMMIT}")

    echo "======================================"
    echo "Changed Files"
    echo "======================================"

    echo "${CHANGED_FILES}"

    CHANGED_SERVICES=""

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
        if echo "${CHANGED_FILES}" | grep -q "^${SERVICE}/"; then
            CHANGED_SERVICES="${CHANGED_SERVICES} ${SERVICE}"
        fi
    done
fi

CHANGED_SERVICES=$(echo "${CHANGED_SERVICES}" | xargs)

echo "======================================"
echo "Changed Services"
echo "======================================"

if [ -z "${CHANGED_SERVICES}" ]; then
    echo "No application service changes detected."
else
    echo "${CHANGED_SERVICES}"
fi

echo "======================================"
echo "Detect Changes Completed"
echo "======================================"

# Jenkins environment variable
echo "CHANGED_SERVICES=${CHANGED_SERVICES}" > changed-services.properties
