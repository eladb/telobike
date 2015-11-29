#!/bin/bash
set -e
docker build -t eladb/telobike-backend .
echo
echo "Successfully built eladb/telobike-backend"
echo 
echo "Some helpful commands:"
echo " - docker push eladb/telobike-backend"
echo " - docker run -it --net=host eladb/telobike-backend"
echo