#!/bin/bash
set -e

echo "======================================"
echo "Starting Smoke Test"
echo "======================================"

if [ "${INITIAL_BUILD}" = "true" ]; then

    echo "Initial deployment detected."
    echo "Checking all application services."

    SERVICES=(
        "auth-service:auth"
        "gateway-service:gateway"
        "user-service:user"
        "admin-service:admin"
        "employee-service:employee"
        "customer-service:customer"
        "hr-service:hr"
        "task-service:task"
    )

else

    if [ -z "${CHANGED_SERVICES}" ]; then
        echo "No application services changed."
        echo "Skipping smoke test."
        exit 0
    fi

    SERVICES=()

    for SERVICE in ${CHANGED_SERVICES}
    do

        case "${SERVICE}" in

            auth-service)
                SERVICES+=("auth-service:auth")
                ;;

            gateway-service)
                SERVICES+=("gateway-service:gateway")
                ;;

            user-service)
                SERVICES+=("user-service:user")
                ;;

            admin-service)
                SERVICES+=("admin-service:admin")
                ;;

            employee-service)
                SERVICES+=("employee-service:employee")
                ;;

            customer-service)
                SERVICES+=("customer-service:customer")
                ;;

            hr-service)
                SERVICES+=("hr-service:hr")
                ;;

            task-service)
                SERVICES+=("task-service:task")
                ;;

            *)
                echo "ERROR: Unknown service: ${SERVICE}"
                exit 1
                ;;

        esac

    done

fi

for ITEM in "${SERVICES[@]}"
do

    SERVICE_NAME="${ITEM%%:*}"
    NAMESPACE="${ITEM##*:}"

    echo "======================================"
    echo "Service    : ${SERVICE_NAME}"
    echo "Namespace  : ${NAMESPACE}"
    echo "======================================"

    kubectl get pods \
        -n "${NAMESPACE}" \
        -l app="${SERVICE_NAME}"

    kubectl get service \
        "${SERVICE_NAME}" \
        -n "${NAMESPACE}"

done

echo "======================================"
echo "Gateway Ingress"
echo "======================================"

kubectl get ingress -n gateway

echo "======================================"
echo "Smoke Test Completed"
echo "======================================"
