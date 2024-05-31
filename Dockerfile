# Use an official AWS Lambda base image
FROM public.ecr.aws/lambda/python:3.12

# Install dependencies
RUN pip install pdf2docx

# Copy function code
COPY app.py ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (filename.function_name)
CMD ["app.handler"]
