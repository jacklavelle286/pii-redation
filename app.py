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
