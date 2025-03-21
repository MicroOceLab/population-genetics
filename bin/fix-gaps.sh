#!/usr/bin/env bash

argv=("$@");

cp "${argv[0]}" "${argv[1]}"
sed -i '/^[^>]/s/-//g' "${argv[1]}"