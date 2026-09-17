#!/bin/bash
set -e

echo "======================================"
echo "Starting Helm Deployment"
echo "======================================"

CHART_PATH="${WORKSPACE}/helm/crm"
IMAGE_TAG="${GIT_COMMIT:0:7}"

NEXUS_SERVER="speshway-test-shared-alb-971436964.ap-south-1.elb.amazonaws.com:8081"

echo "Chart Path    : ${CHART_PATH}"
echo "Image Tag     : ${IMAGE_TAG}"
echo "Initial Build : ${INITIAL_BUILD}"
echo "Changed       : ${CHANGED_SERVICES}"

echo "======================================"
echo "Helm Lint"
echo "======================================"

helm lint "${CHART_PATH}"

echo "======================================"
echo "Creating Application Namespaces"
echo "======================================"

NAMESPACES=(
    "auth"
    "gateway"
    "user"
    "admin"
    "employee"
    "customer"
    "hr"
    "task"
)

for NAMESPACE in "${NAMESPACES[@]}"
do
    echo "Creating namespace: ${NAMESPACE}"

    kubectl create namespace "${NAMESPACE}" \
        --dry-run=client \
        -o yaml | kubectl apply -f -
done

echo "======================================"
echo "Creating Nexus Image Pull Secrets"
echo "======================================"

NEXUS_NAMESPACES=(
    "auth"
    "gateway"
    "user"
    "admin"
    "employee"
    "customer"
)

for NAMESPACE in "${NEXUS_NAMESPACES[@]}"
do
    echo "Creating/updating Nexus secret in namespace: ${NAMESPACE}"

    kubectl create secret docker-registry nexus-registry-secret \
        --namespace "${NAMESPACE}" \
        --docker-server="${NEXUS_SERVER}" \
        --docker-username="${NEXUS_USERNAME}" \
        --docker-password="${NEXUS_PASSWORD}" \
        --dry-run=client \
        -o yaml | kubectl apply -f -
done

echo "======================================"
echo "Nexus Image Pull Secrets Ready"
echo "======================================"

echo "======================================"
echo "Preparing Helm Deployment"
echo "======================================"

if [ "${INITIAL_BUILD}" = "true" ]; then

    echo "Initial deployment detected."
    echo "Deploying all services."

    helm upgrade --install crm "${CHART_PATH}" \
        --set services.auth.tag="${IMAGE_TAG}" \
        --set services.gateway.tag="${IMAGE_TAG}" \
        --set services.user.tag="${IMAGE_TAG}" \
        --set services.admin.tag="${IMAGE_TAG}" \
        --set services.employee.tag="${IMAGE_TAG}" \
        --set services.customer.tag="${IMAGE_TAG}" \
        --set services.hr.tag="${IMAGE_TAG}" \
        --set services.task.tag="${IMAGE_TAG}"

else

    if [ -z "${CHANGED_SERVICES}" ]; then
        echo "No application services changed."
        echo "Skipping Helm deployment."
        exit 0
    fi

    echo "Existing deployment detected."
    echo "Deploying only changed services."

    HELM_ARGS=()

    for SERVICE in ${CHANGED_SERVICES}
    do
        case "${SERVICE}" in

            auth-service)
                HELM_ARGS+=(--set services.auth.tag="${IMAGE_TAG}")
                ;;

            gateway-service)
                HELM_ARGS+=(--set services.gateway.tag="${IMAGE_TAG}")
                ;;

            user-service)
                HELM_ARGS+=(--set services.user.tag="${IMAGE_TAG}")
                ;;

            admin-service)
                HELM_ARGS+=(--set services.admin.tag="${IMAGE_TAG}")
                ;;

            employee-service)
                HELM_ARGS+=(--set services.employee.tag="${IMAGE_TAG}")
                ;;

            customer-service)
                HELM_ARGS+=(--set services.customer.tag="${IMAGE_TAG}")
                ;;

            hr-service)
                HELM_ARGS+=(--set services.hr.tag="${IMAGE_TAG}")
                ;;

            task-service)
                HELM_ARGS+=(--set services.task.tag="${IMAGE_TAG}")
                ;;

            *)
                echo "ERROR: Unknown service: ${SERVICE}"
                exit 1
                ;;
        esac
    done

    echo "Helm arguments prepared."

    helm upgrade crm "${CHART_PATH}" \
        --reuse-values \
        "${HELM_ARGS[@]}"
fi

echo "======================================"
echo "Helm Deployment Completed"
echo "======================================"

echo "======================================"
echo "Helm Release Status"
echo "======================================"

helm list -A

echo "======================================"
echo "Helm Deployment Finished"
echo "======================================"
