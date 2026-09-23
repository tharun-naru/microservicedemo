#!/bin/bash

set -e

echo "======================================"
echo "Starting Image Push"
echo "======================================"

IMAGE_TAG="${GIT_COMMIT:0:7}"

AWS_REGION="ap-south-1"
AWS_ACCOUNT_ID="179897609830"

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_REPOSITORY="speshway-test-images"

echo "Image Tag: ${IMAGE_TAG}"
echo "Changed Services: ${CHANGED_SERVICES}"

if [ -z "${CHANGED_SERVICES}" ]; then

    echo "======================================"
    echo "No application services changed."
    echo "Skipping image push."
    echo "======================================"

    exit 0
fi


echo "======================================"
echo "Logging in to Amazon ECR"
echo "======================================"

aws ecr get-login-password \
    --region "${AWS_REGION}" | \
docker login \
    --username AWS \
    --password-stdin "${ECR_REGISTRY}"

echo "ECR login successful."


echo "======================================"
echo "Pushing Images"
echo "======================================"


for SERVICE in ${CHANGED_SERVICES}
do

    echo "======================================"
    echo "Processing ${SERVICE}"
    echo "======================================"

    SOURCE_IMAGE="${SERVICE}:${IMAGE_TAG}"

    TARGET_IMAGE="${ECR_REGISTRY}/${ECR_REPOSITORY}:${SERVICE}-${IMAGE_TAG}"

    echo "Source Image:"
    echo "${SOURCE_IMAGE}"

    echo "Target Image:"
    echo "${TARGET_IMAGE}"

    docker tag \
        "${SOURCE_IMAGE}" \
        "${TARGET_IMAGE}"

    docker push \
        "${TARGET_IMAGE}"

    echo "${SERVICE} pushed successfully."

done


echo "======================================"
echo "Image Push Completed Successfully"
echo "======================================"
