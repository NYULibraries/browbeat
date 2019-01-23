#!/bin/sh

docker tag browbeat quay.io/nyulibraries/browbeat:latest
docker tag browbeat quay.io/nyulibraries/browbeat:${CIRCLE_BRANCH//\//_}
docker tag browbeat quay.io/nyulibraries/browbeat:${CIRCLE_BRANCH//\//_}-${CIRCLE_SHA1}

docker push quay.io/nyulibraries/browbeat:latest
docker push quay.io/nyulibraries/browbeat:${CIRCLE_BRANCH//\//_}
docker push quay.io/nyulibraries/browbeat:${CIRCLE_BRANCH//\//_}-${CIRCLE_SHA1}
