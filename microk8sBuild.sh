#!/usr/bin/env bash
set -e
# release=v0.1.0
release=latest
sudo docker build --tag localhost:32000/my/gitrepo-todir-sync:$release .
sudo docker push localhost:32000/my/gitrepo-todir-sync:$release
