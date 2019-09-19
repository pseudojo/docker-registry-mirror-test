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
docker pull busybox
docker pull sonatype/nexus

# check mirroring
# ex) {"repositories":["library/busybox","sonatype/nexus"]}
curl -k https://registry.localhost/v2/_catalog

#####################################################3
# when it works remote proxy(like mirroring), can't push images

# stop registry
docker rm -f registry

# disable proxy as mirroring registry
export PROXY=0

# start docker registry
./start-registry.sh

# locally docker images like public images
docker tag busybox registry.localhost/library/busybox-localtest
docker push registry.localhost/library/busybox-localtest

# test registry
# ex) {"repositories":["library/busybox","library/busybox-localtest","sonatype/nexus"]}
curl -k https://registry.localhost/v2/_catalog

# remove local images
docker rmi busybox sonatype/nexus registry.localhost/library/busybox-localtest

# disable public network
sudo systemctl stop NetworkManager

# test : retry pull from local registry
docker pull busybox-localtest
docker pull sonatype/nexus
docker pull busybox 

# check local images
# ex)
# REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
# busybox-localtest   latest              19485c79a9bb        2 weeks ago         1.22MB
# busybox             latest              19485c79a9bb        2 weeks ago         1.22MB
# sonatype/nexus      latest              9db1ff0a3c18        5 weeks ago         449MB
# 
docker images

```
