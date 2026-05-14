# Use Python 3.6 or later as a base image
FROM python:3.6-slim

# Copy contents into image
COPY . /app
 
# Install pip dependencies from requirements
RUN pip install -r /app/requirements.txt

# Set YOUR_NAME environment variable
ENV YOUR_NAME=yaqubu

# Expose the correct port
EXPOSE 80

# Create an entrypoint
ENTRYPOINT ["python", "/app/app.py"]
