#!/bin/bash

PROJECT_NAME="mistral"

# load environment variables and print them
set -a
DOCKER_PROJECT_ENV_FILENAME="llmsvc/${PROJECT_NAME}/docker.env"
if [ -e "${DOCKER_PROJECT_ENV_FILENAME}" ]; then
    echo "Loading environment variables from ${DOCKER_PROJECT_ENV_FILENAME}"
    set -x # print commands and thier arguments
    # shellcheck disable=SC1091,SC1090
    source "${DOCKER_PROJECT_ENV_FILENAME}"
    set +x # disable printing of environment variables
fi
set +a

MODEL_FILE_ARCHIVE=mistral-7B-v0.1.tar        # The name of the model archive file

if [ -d "${HOST_MODEL_DIR}" ]; then
    echo "Model directory ${HOST_MODEL_DIR} already exists."
    exit 0
fi

# Download model archive file from URL to specified path
if [ ! -e "${MODEL_FILE_ARCHIVE}" ]; then
    echo "Downloading model archive file from URL..."
    wget https://files.mistral-7b-v0-1.mistral.ai/mistral-7B-v0.1.tar -O "${MODEL_FILE_ARCHIVE}"
else
    echo "Model archive file ${MODEL_FILE_ARCHIVE} already exists."
fi
# Unpack model archive file to HOST_MODEL_DIR
mkdir -p "${HOST_MODEL_DIR}"
tar -xvf "${MODEL_FILE_ARCHIVE}" -C "${HOST_MODEL_DIR}"
