#!/bin/bash

# Variables
REGION="eu-west-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPOSITORY_NAME="my-lambda-repo"
IMAGE_NAME="my-lambda-image"
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY_NAME}:latest"

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

    sudo systemctl start docker
    sudo systemctl enable docker

    sudo docker run hello-world
    echo "Docker installed successfully."
}

# Check if Docker is installed
if ! [ -x "$(command -v docker)" ]; then
  install_docker
else
  echo "Docker is already installed."
fi

# Create Dockerfile
cat << 'EOF' > Dockerfile
# Use an official AWS Lambda base image
FROM public.ecr.aws/lambda/python:3.12

# Install dependencies
RUN pip install pdf2docx

# Copy function code
COPY app.py ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (filename.function_name)
CMD ["app.handler"]
EOF

# Create app.py
cat << 'EOF' > app.py
import json
import boto3
import os
from pdf2docx import Converter

s3 = boto3.client('s3')

def handler(event, context):
    destination_bucket = os.environ['DESTINATION_BUCKET']
    docx_bucket = os.environ['DOCX_BUCKET']

    # Parse S3 event
    for record in event['Records']:
        source_bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        # Download the PDF file from the source bucket
        download_path = f'/tmp/{key}'
        s3.download_file(source_bucket, key, download_path)

        # Convert PDF to DOCX
        docx_path = f'/tmp/{key}.docx'
        cv = Converter(download_path)
        cv.convert(docx_path, start=0, end=None)
        cv.close()

        # Upload the DOCX file to the docx bucket
        s3.upload_file(docx_path, docx_bucket, f'{key}.docx')

    return {
        'statusCode': 200,
        'body': json.dumps('File converted successfully!')
    }
EOF

# Build Docker image
sudo docker build -t ${IMAGE_NAME} .

# Create ECR repository
aws ecr create-repository --repository-name ${REPOSITORY_NAME} --region ${REGION}

# Authenticate Docker to ECR
aws ecr get-login-password --region ${REGION} | sudo docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# Tag the Docker image
sudo docker tag ${IMAGE_NAME}:latest ${ECR_URI}

# Push the Docker image to ECR
sudo docker push ${ECR_URI}

# Output the ECR image URI
echo "ECR Image URI: ${ECR_URI}"
