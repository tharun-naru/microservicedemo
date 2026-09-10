#!/bin/bash

set -e

echo "======================================"
echo "Starting SonarQube Analysis"
echo "======================================"

mvn verify sonar:sonar \
  -Dsonar.projectKey=microservicedemo \
  -Dsonar.projectName=microservicedemo

echo "======================================"
echo "SonarQube Analysis Completed"
echo "======================================"
