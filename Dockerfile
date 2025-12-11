# Use official Python slim image
FROM python:3.9-slim

# Set environment variables for Chrome
ENV CHROME_VERSION="142.0.7444.162"
ENV CHROMEDRIVER_VERSION="142.0.7444.162"

# Install dependencies for Chrome, Selenium, and unzip
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    unzip \
    xvfb \
    libnss3 \
    libxss1 \
    libfontconfig1 \
    libx11-xcb1 \
    libglib2.0-0 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install ChromeDriver matching Chrome version
RUN wget -q https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chromedriver-linux64.zip \
    && unzip chromedriver-linux64.zip \
    && mv chromedriver-linux64 /usr/bin/chromedriver \
    && chmod +x /usr/bin/chromedriver \
    && rm chromedriver-linux64.zip

# Set working directory
WORKDIR /app

# Copy requirements first (for Docker layer caching)
COPY app/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app
COPY . .

# Expose Flask app port
EXPOSE 5000

# Default command: run pytest tests
CMD ["pytest", "-q", "tests"]
