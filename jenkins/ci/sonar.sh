#!/bin/bash

set -e

echo "======================================"
echo "Starting SonarQube Analysis"
echo "======================================"

mvn verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
  -Dsonar.projectKey=microservicedemo \
  -Dsonar.projectName=microservicedemo

echo "======================================"
echo "SonarQube Analysis Completed"
echo "======================================"
