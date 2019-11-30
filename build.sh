#!/bin/bash

rm -rf blog-staging
mkdir -p blog-staging

cd posts

for f in *.md
do
    pandoc --email-obfuscation=javascript --mathjax -s -t html --css=/style.css -B ../header.inc -A ../footer.inc --metadata pagetitle="FWEI.TK | ""$(../extract_field.sh ../index.csv $f 2)" -o ../blog-staging/${f%.md}.html $f
done

cd -

cp files/* blog-staging/
