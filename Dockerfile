FROM python:3.9-slim

WORKDIR /app

# Install app dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install testing dependencies
RUN pip install pytest selenium

# Copy entire project into the container
COPY . .

# Make sure Python can import modules from /app
ENV PYTHONPATH="/app"

CMD ["pytest", "-q", "tests"]
