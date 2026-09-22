#!/bin/bash

set -e

echo "======================================"
echo "Detecting Changed Services"
echo "======================================"

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

CHANGED_SERVICES=""

# ======================================
# Initial Build
# ======================================

if [ "${INITIAL_BUILD}" = "true" ]; then

    echo "Initial build requested."
    echo "All services will be built."

    CHANGED_SERVICES="${SERVICES[*]}"

else

    # ======================================
    # Read Changed Files
    # ======================================

    if [ ! -f changed-files.txt ]; then

        echo "ERROR: changed-files.txt not found."
        exit 1

    fi

    echo "======================================"
    echo "Changed Files"
    echo "======================================"

    cat changed-files.txt

    # ======================================
    # Check Common Files
    # ======================================

    if grep -q '^pom.xml$' changed-files.txt ||
       grep -q '^common-library/' changed-files.txt; then

        echo "Common Maven files changed."
        echo "All services must be rebuilt."

        CHANGED_SERVICES="${SERVICES[*]}"

    else

        # ======================================
        # Check Individual Services
        # ======================================

        for SERVICE in "${SERVICES[@]}"
        do

            if grep -q "^${SERVICE}/" changed-files.txt; then

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

    echo "No application services changed."

else

    echo "${CHANGED_SERVICES}"

fi

echo "======================================"
echo "Detect Changes Completed"
echo "======================================"

echo "CHANGED_SERVICES=${CHANGED_SERVICES}" \
    > changed-services.properties
