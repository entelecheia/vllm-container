#!/bin/bash
# Print out the environment variables
export

# add your custom commands here that should be executed every time the docker container starts
echo "Starting docker container..."

### Set the USER_UID envvar to match your user.
# Ensures files created in the container are owned by you:
#   docker run --rm -it -v /some/path:/invokeai -e USER_UID=$(id -u) <this image>
# Default UID: 1000 chosen due to popularity on Linux systems. Possibly 501 on MacOS.

echo "Fixing permissions..."
USER_UID=${USER_UID:-1000}
USER=${USERNAME:-app}
usermod -u "${USER_UID}" "${USER}"
groupmod -g "${USER_UID}" "${USER}"
# chown -R "$USER_UID:$USER_UID" "$WORKSPACE_ROOT"

if [[ -n "${HF_TOKEN}" ]]; then
    echo "The HF_TOKEN environment variable set, logging to Hugging Face."
    python3 -c "import huggingface_hub; huggingface_hub.login('${HF_TOKEN}')"
else
    echo "The HF_TOKEN environment variable is not set or empty, not logging to Hugging Face."
fi

# Run the provided command
exec gosu "${USER}" python3 -u -m vllm.entrypoints.openai.api_server "$@"
