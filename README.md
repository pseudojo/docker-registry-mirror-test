## test mirror using docker-registry

```
# in CentOS 7

# add url in /etc/hosts
echo -e "127.0.0.1    registry.localhost \n" | sudo tee -a /etc/hosts

# update docker.service config
sudo mv /usr/lib/systemd/system/docker.service /usr/lib/systemd/system/docker.service.bak
sudo cp ./docker.service /usr/lib/systemd/system/docker.service
sudo systemctl daemon-reload

# restart docker
sudo systemctl restart docker

# create self-signed certificate
./create-selfsigned-certificate.sh

# remove 'registry' container
docker rm -f registry

# start docker registry
./start-registry.sh

# check registry
# ex) 938c04d6c3c1        registry               "/entrypoint.sh /etc…"   2 hours ago         Up 2 hours               0.0.0.0:443->5000/tcp   registry
docker ps -a | egrep 'Up .+ registry'

# test registry
# ex) {"repositories":[]}
curl -k https://registry.localhost/v2/_catalog

# test mirroring docker images
docker pull busybox sonatype/nexus

# check mirroring
curl -k https://registry.localhost/v2/_catalog

# remove local images
docker rmi busybox sonatype/nexus

# disable public network
sudo systemctl stop NetworkManager

# retry pull from local registry
docker pull busybox sonatype/nexus

# check local images
docker images | egrep 'busybox|sonatype/nexus'

```
