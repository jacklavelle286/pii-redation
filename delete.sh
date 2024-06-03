#!/bin/bash

aws s3 rb s3://eu-west-1-590183835826-destination-bucket --force
aws cloudformation delete-stack --stack-name my-pdf2docx-stack
