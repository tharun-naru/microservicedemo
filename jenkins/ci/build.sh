#!/bin/bash

set -e

echo "======================================"
echo "Starting Maven Build"
echo "======================================"

mvn clean package -DskipTests

echo "======================================"
echo "Maven Build Completed Successfully"
echo "======================================"
