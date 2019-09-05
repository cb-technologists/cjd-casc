#!/usr/bin/env bash

sed -i 's/cjd.cloudbees.elgin.io/cjd-staging.cloudbees.elgin.io/g' cjd.yaml
sed -i '/cert-manager/d' cjd.yaml
sed -i 's!https://cjd.cloudbees.elgin.io!http://cjd-staging.cloudbees.elgin.io!g' jenkinsCasc.yaml