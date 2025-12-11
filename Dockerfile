FROM python:3.9-slim

WORKDIR /app

# Copy requirements first (if you have it)
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copy the tests folder into container
COPY tests ./tests

# Copy the rest of the project (optional)
COPY . .

# Run the tests when container starts
CMD ["pytest", "-q", "tests"]
