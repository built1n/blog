#!/bin/bash

# Usage: ./extract_field.sh DBNAME KEY FIELDIDX

awk 'BEGIN { FS = ":" } $1 == "'"$2"'" { print $'"$3"'}' < $1
