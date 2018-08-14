#!/bin/sh

function docker_tag_exists() {
  curl --silent -f -lSL https://index.docker.io/v1/repositories/$1/tags/$2 > /dev/null
}

if docker_tag_exists nyulibraries/browbeat ${CIRCLE_BRANCH//\//_}; then
  docker pull nyulibraries/browbeat:${CIRCLE_BRANCH//\//_}
else
  docker pull nyulibraries/browbeat:latest
fi
