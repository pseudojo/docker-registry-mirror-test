#!/bin/bash

PROXY="${PROXY:-1}"
REGISTRY_OPTIONS="-dt -p 443:5000 --name registry 
    -v $(pwd)/config.yml:/etc/docker/registry/config.yml \
    -v $(pwd)/certs:/etc/docker/registry/certs \
    -v $(pwd)/registry:/var/lib/registry "

#sudo rm -rf $(pwd)/registry
mkdir -p $(pwd)/registry

echo "Proxy : $PROXY"
if [[ $PROXY == 1 ]]; then
  REGISTRY_OPTIONS+=" -e REGISTRY_PROXY_REMOTEURL=http://registry-1.docker.io"
fi

docker run $REGISTRY_OPTIONS registry

