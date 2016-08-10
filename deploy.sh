#!/bin/bash

aws s3 sync --acl public-read public/ s3://lessthanhero.io/

aws s3 sync --acl public-read public/ s3://www.lessthanhero.io/
