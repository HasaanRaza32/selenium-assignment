# Use official Python 3.9 slim image
FROM python:3.9-slim

# Install basic dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    curl \
    xvfb \
    gnupg \
    libnss3 \
    libxss1 \
    libfontconfig1 \
    libx11-xcb1 \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome 142.x
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update \
    && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    || apt-get install -f -y \
    && rm google-chrome-stable_current_amd64.deb

# Verify Chrome version (optional)
RUN google-chrome --version

# Install ChromeDriver matching Chrome 142
RUN wget https://storage.googleapis.com/chrome-for-testing-public/142.0.7444.162/linux64/chromedriver-linux64.zip \
    && unzip chromedriver-linux64.zip \
    && mv chromedriver-linux64 /usr/bin/chromedriver \
    && chown root:root /usr/bin/chromedriver \
    && chmod +x /usr/bin/chromedriver \
    && rm chromedriver-linux64.zip

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY . /app

# Expose port (if running Flask)
EXPOSE 5000

# Default command: run pytest
CMD ["pytest", "-q", "tests"]
