#!/bin/bash

touch /tmp/kuberctl.log
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/amd64/kubectl
 >> /tmp/kuberctl.log
sha256sum -c kubectl.sha256  >> /tmp/kuberctl.log
chmod +x ./kubectl
sudo mv kubectl /usr/local/bin #to access all users
kubectl version --client  >> /tmp/kuberctl.log