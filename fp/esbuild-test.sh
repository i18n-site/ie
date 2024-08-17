#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

./build.sh
esbuild lib/index.js --bundle --outfile=test.js --format=esm
cat test.js
