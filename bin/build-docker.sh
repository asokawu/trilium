#!/usr/bin/env bash

VERSION=`jq -r ".version" package.json`
SERIES=${VERSION:0:4}-latest

cat package.json | grep -v electron > server-package.json

sudo docker build -t asokawu/trilium:$VERSION --network host -t asokawu/trilium:$SERIES .

if [[ $VERSION != *"beta"* ]]; then
  sudo docker tag asokawu/trilium:$VERSION asokawu/trilium:latest
fi
