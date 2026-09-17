#!/bin/bash
set -e

echo "======================================"
echo "Checking Deployment Rollout"
echo "======================================"

if [ "${INITIAL_BUILD}" = "true" ]; then

    echo "Initial deployment detected."
    echo "Checking all services."

    DEPLOYMENTS=(
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
        echo "Skipping rollout check."
        exit 0
    fi

    DEPLOYMENTS=()

    for SERVICE in ${CHANGED_SERVICES}
    do
        case "${SERVICE}" in

            auth-service)
                DEPLOYMENTS+=("auth-service:auth")
                ;;

            gateway-service)
                DEPLOYMENTS+=("gateway-service:gateway")
                ;;

            user-service)
                DEPLOYMENTS+=("user-service:user")
                ;;

            admin-service)
                DEPLOYMENTS+=("admin-service:admin")
                ;;

            employee-service)
                DEPLOYMENTS+=("employee-service:employee")
                ;;

            customer-service)
                DEPLOYMENTS+=("customer-service:customer")
                ;;

            hr-service)
                DEPLOYMENTS+=("hr-service:hr")
                ;;

            task-service)
                DEPLOYMENTS+=("task-service:task")
                ;;

            *)
                echo "ERROR: Unknown service: ${SERVICE}"
                exit 1
                ;;

        esac
    done

fi

for ITEM in "${DEPLOYMENTS[@]}"
do

    DEPLOYMENT="${ITEM%%:*}"
    NAMESPACE="${ITEM##*:}"

    echo "======================================"
    echo "Deployment : ${DEPLOYMENT}"
    echo "Namespace  : ${NAMESPACE}"
    echo "======================================"

    kubectl rollout status \
        deployment/"${DEPLOYMENT}" \
        -n "${NAMESPACE}" \
        --timeout=5m

done

echo "======================================"
echo "Rollout Completed Successfully"
echo "======================================"
