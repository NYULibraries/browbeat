#!/bin/sh

docker pull nyulibraries/browbeat:${CIRCLE_BRANCH//\//_} || docker pull nyulibraries/browbeat:latest
