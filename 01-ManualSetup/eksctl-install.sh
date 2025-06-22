#!/bin/bash

touch /tmp/eksctl.log
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp >> /tmp/eksctl.log
sudo mv /tmp/eksctl /usr/local/bin
eksctl version >> /tmp/eksctl.log