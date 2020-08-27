#!/bin/sh

set -e
set -u

PROJECT_NAME="zint"
DIR="$(dirname "$(readlink -f "$0")")"
TAG_BASE="cifuzz/builders"
TAG="${TAG_BASE}:${PROJECT_NAME}"

export DOCKER_BUILDKIT=1
docker build --build-arg BUILDKIT_INLINE_CACHE=1 -t "${TAG}" "${DIR}"

# Automatically push the built docker image if we're in the CI
if [ -n "${CI:-}" ]; then
  docker push "${TAG}"
fi
