#!/usr/bin/env bash

DIR=$(realpath ${0%/*})
cd $DIR
set -ex

if [ -d "$1" ]; then
  echo "$1 EXIST"
  exit 1
fi

cp -R tmpl $1

cd $1

rpl tmpl $1

git add .
