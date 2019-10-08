#!/bin/bash

rm -rf out
mkdir -p out

cd posts

for f in *.md
do
    pandoc --email-obfuscation=javascript -s -t html --css=/style.css -B ../header.inc -A ../footer.inc --metadata pagetitle="FWEI.TK | ""$(../extract_field.sh ../index.csv $f 2)" -o ../out/${f%.md}.html $f
done

cd -

cp files/* out/
