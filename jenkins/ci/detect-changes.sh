#!/bin/bash

set -e

echo "======================================"
echo "Detecting Changes"
echo "======================================"

echo "Current Commit:"
echo "${GIT_COMMIT}"

echo "Previous Commit:"
echo "${GIT_PREVIOUS_COMMIT}"

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

# ======================================
# Initial Build
# ======================================

if [ "${INITIAL_BUILD}" = "true" ]; then

    echo "======================================"
    echo "Initial Build Requested"
    echo "======================================"

    echo "No existing application images are assumed."
    echo "Treating all services as changed."

    CHANGED_SERVICES="${SERVICES[*]}"

else

    # ======================================
    # Normal Change Detection
    # ======================================

    if [ -z "${GIT_PREVIOUS_COMMIT}" ]; then

        echo "======================================"
        echo "No Previous Commit Found"
        echo "======================================"

        echo "Treating all services as changed."

        CHANGED_SERVICES="${SERVICES[*]}"

    else

        CHANGED_FILES=$(git diff --name-only \
            "${GIT_PREVIOUS_COMMIT}" \
            "${GIT_COMMIT}")

        echo "======================================"
        echo "Changed Files"
        echo "======================================"

        echo "${CHANGED_FILES}"

        CHANGED_SERVICES=""

        for SERVICE in "${SERVICES[@]}"
        do
            if echo "${CHANGED_FILES}" | grep -q "^${SERVICE}/"; then

                CHANGED_SERVICES="${CHANGED_SERVICES} ${SERVICE}"

            fi
        done

    fi

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

echo "CHANGED_SERVICES=${CHANGED_SERVICES}" > changed-services.properties
