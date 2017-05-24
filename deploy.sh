#!/bin/bash

if [[ -n ${EC2_PROFILE} ]]; then
  profile="--profile ${EC2_PROFILE}"
fi

aws s3 ${profile} sync --acl public-read public/ s3://lessthanhero.io/

aws s3 ${profile} sync --acl public-read public/ s3://www.lessthanhero.io/
