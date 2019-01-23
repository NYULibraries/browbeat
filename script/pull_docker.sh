#!/bin/sh

docker pull quay.io/nyulibraries/browbeat:${CIRCLE_BRANCH//\//_} || docker pull quay.io/nyulibraries/browbeat:latest
