#!/bin/bash

set -e

echo "======================================"
echo "Starting Image Push"
echo "======================================"

IMAGE_TAG="${GIT_COMMIT:0:7}"

AWS_REGION="ap-south-1"
AWS_ACCOUNT_ID="179897609830"

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

NEXUS_HOST="speshway-test-shared-alb-971436964.ap-south-1.elb.amazonaws.com:8081"
NEXUS_IMAGE_REGISTRY="${NEXUS_HOST}/docker-hosted"

echo "Image Tag: ${IMAGE_TAG}"
echo "Changed Services: ${CHANGED_SERVICES}"

if [ -z "${CHANGED_SERVICES}" ]; then
    echo "No application services changed."
    echo "Skipping image push."
    exit 0
fi

echo "======================================"
echo "Logging in to ECR"
echo "======================================"

aws ecr get-login-password \
    --region "${AWS_REGION}" | \
docker login \
    --username AWS \
    --password-stdin "${ECR_REGISTRY}"

echo "ECR login successful."

echo "======================================"
echo "Logging in to Nexus"
echo "======================================"

echo "${NEXUS_PASSWORD}" | \
docker login \
    "${NEXUS_HOST}" \
    --username "${NEXUS_USERNAME}" \
    --password-stdin

echo "Nexus login successful."

for SERVICE in ${CHANGED_SERVICES}
do

    SOURCE_IMAGE="${SERVICE}:${IMAGE_TAG}"

    echo "======================================"
    echo "Processing ${SERVICE}"
    echo "======================================"

    case "${SERVICE}" in

        auth-service|gateway-service|user-service|admin-service|employee-service|customer-service)

            TARGET_IMAGE="${NEXUS_IMAGE_REGISTRY}/${SERVICE}:${IMAGE_TAG}"

            echo "Registry: Nexus"
            echo "Source Image: ${SOURCE_IMAGE}"
            echo "Target Image: ${TARGET_IMAGE}"

            docker tag \
                "${SOURCE_IMAGE}" \
                "${TARGET_IMAGE}"

            docker push "${TARGET_IMAGE}"

            echo "${SERVICE} pushed successfully to Nexus."

            ;;

        hr-service)

            TARGET_IMAGE="${ECR_REGISTRY}/speshway-test-hr:${IMAGE_TAG}"

            echo "Registry: ECR"
            echo "Source Image: ${SOURCE_IMAGE}"
            echo "Target Image: ${TARGET_IMAGE}"

            docker tag \
                "${SOURCE_IMAGE}" \
                "${TARGET_IMAGE}"

            docker push "${TARGET_IMAGE}"

            echo "${SERVICE} pushed successfully to ECR."

            ;;

        task-service)

            TARGET_IMAGE="${ECR_REGISTRY}/speshway-test-task:${IMAGE_TAG}"

            echo "Registry: ECR"
            echo "Source Image: ${SOURCE_IMAGE}"
            echo "Target Image: ${TARGET_IMAGE}"

            docker tag \
                "${SOURCE_IMAGE}" \
                "${TARGET_IMAGE}"

            docker push "${TARGET_IMAGE}"

            echo "${SERVICE} pushed successfully to ECR."

            ;;

        *)

            echo "ERROR: Unknown service: ${SERVICE}"
            exit 1

            ;;

    esac

done

echo "======================================"
echo "Image Push Completed Successfully"
echo "======================================"
