#!/usr/bin/env bash

yarn run tsc -p .
echo "Current errors are:"
yarn run tsc -p . | cut -d":" -f2 | grep 'error' | sort | uniq -c | sort
