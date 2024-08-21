#!/usr/bin/env bash

export http_proxy=http://127.0.0.1:10809
export https_proxy=http://127.0.0.1:10809

VERSION=`jq -r ".version" package.json`
SERIES=${VERSION:0:5}-latest

cat package.json | grep -v electron > server-package.json

sudo docker build --progress=plain -t asokawu/trilium:$VERSION --network host -t asokawu/trilium:$SERIES .

if [[ $VERSION != *"beta"* ]]; then
  sudo docker tag asokawu/trilium:$VERSION asokawu/trilium:latest
fi
