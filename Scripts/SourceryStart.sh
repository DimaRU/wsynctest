#!/bin/sh

cd "$(dirname "$0")"
cd ..
sourcery --config .sourcery.yml --watch
