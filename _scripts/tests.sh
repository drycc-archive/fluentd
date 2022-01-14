#!/usr/bin/env bash

DEV_ENV_IMAGE=$2

function start-test-redis() {
  docker run --name test-fluentd-redis -d redis:latest
}

function stop-test-redis() {
  docker kill test-fluentd-redis
  docker rm test-fluentd-redis
}

function test-unit() {
  start-test-redis test --cover --race -v
  REDIS_IP=$(docker inspect --format "{{ .NetworkSettings.IPAddress }}" test-fluentd-redis)
  echo "redis ip: $REDIS_IP"
  docker run --rm \
    -e DRYCC_REDIS_ADDRS=${REDIS_IP}:6379 \
    -it \
    ${DEV_ENV_IMAGE} \
    /bin/bash -c "cd /fluentd/drycc-output && rake test"
  stop-test-redis
}

"$@"