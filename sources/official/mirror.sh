#!/bin/bash

cd $(dirname $0)

rm -rf mirror
mkdir mirror

CURLOPTS='-L -c /tmp/cookies -A eps/1.2'

curl $CURLOPTS -o mirror/index $(jq -r .source.url meta.json)

for url in $(nokogiri -e "puts @doc.css('#menu-item-7 a/@href').map(&:text)" mirror/index); do
  echo $url
  curl $CURLOPTS -o mirror/$(basename $url).html $url
done

cd ~-
