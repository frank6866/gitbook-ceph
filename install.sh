#!/usr/bin/env bash

scriptPath=`dirname $0`

cd ${scriptPath}

# install gitbook
npm install gitbook-cli -g

# install plugin
# npm install -g gitbook-plugin-toggle-chapters
npm install gitbook-plugin-disqus -g

# install gitbook plugins in book.json
gitbook install

