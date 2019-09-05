#!/usr/bin/env bash

sed -i 's/cjd.cloudbees.elgin.io/cjd-staging.cloudbees.elgin.io/g' cjd.yaml
sed -i '73,75d' cjd.yaml
sed -i '77,80d' cjd.yaml
sed -i 's!https://cjd.cloudbees.elgin.io!http://cjd-staging.cloudbees.elgin.io!g' jenkinsCasc.yaml