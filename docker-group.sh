#!/bin/bash

if [ -z "$DOCKER_GROUP_ID" ]; then
    echo "DOCKER_GROUP_ID not set"
    exit 1
fi

groupadd -for -g "$DOCKER_GROUP_ID" docker
usermod -aG docker docker

exec "$@"
