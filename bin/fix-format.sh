#!/usr/bin/env sh

argv=("$@");

cp "${argv[0]}" "${argv[1]}"
sed -i -e 's/;/_/g' "${argv[1]}"
sed -i -e 's/:/_/g' "${argv[1]}"
sed -i -e 's/(//g' "${argv[1]}"
sed -i -e 's/)//g' "${argv[1]}"
sed -i -e 's/,/_/g' "${argv[1]}"
sed -i -e 's/ /_/g' "${argv[1]}"
sed -i -e "s/\'//g" "${argv[1]}"

