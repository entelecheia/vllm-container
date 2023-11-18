# Sets the base image for subsequent instructions
ARG ARG_BUILD_FROM="ghcr.io/entelecheia/vllm:latest-base"
FROM $ARG_BUILD_FROM

# Copies scripts from host into the image
COPY ./.docker/scripts/ ./scripts/

RUN pip3 install -v --no-cache-dir -r ./scripts/requirements.txt

# Setting ARGs and ENVs for user creation and workspace setup
ARG ARG_USERNAME="app"
ARG ARG_USER_UID=9001
ARG ARG_USER_GID=$ARG_USER_UID
ARG ARG_WORKSPACE_ROOT="/workspace"
ENV USERNAME $ARG_USERNAME
ENV USER_UID $ARG_USER_UID
ENV USER_GID $ARG_USER_GID
ENV WORKSPACE_ROOT $ARG_WORKSPACE_ROOT

# Creates a non-root user with sudo privileges
# check if user exists and if not, create user
RUN if id -u $USERNAME >/dev/null 2>&1; then \
    echo "User exists"; \
    else \
    groupadd --gid $USER_GID $USERNAME && \
    adduser --uid $USER_UID --gid $USER_GID --force-badname --disabled-password --gecos "" $USERNAME && \
    echo "$USERNAME:$USERNAME" | chpasswd && \
    adduser $USERNAME sudo && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME; \
    fi

ENV HF_HOME=$APP_INSTALL_ROOT/.cache/huggingface
RUN mkdir -p $HF_HOME

# Changes ownership of the workspace to the non-root user
RUN chown -R $USERNAME:$USERNAME $APP_INSTALL_ROOT
RUN chmod +x "$APP_INSTALL_ROOT/scripts/entrypoint.sh"

ENTRYPOINT ["$APP_INSTALL_ROOT/scripts/entrypoint.sh"]