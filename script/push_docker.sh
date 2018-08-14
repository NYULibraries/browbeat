#!/bin/sh

docker tag browbeat nyulibraries/browbeat:latest
docker tag browbeat nyulibraries/browbeat:${CIRCLE_BRANCH//\//_}
docker tag browbeat nyulibraries/browbeat:${CIRCLE_BRANCH//\//_}-${CIRCLE_SHA1}

docker push nyulibraries/browbeat:latest
docker push nyulibraries/browbeat:${CIRCLE_BRANCH//\//_}
docker push nyulibraries/browbeat:${CIRCLE_BRANCH//\//_}-${CIRCLE_SHA1}
