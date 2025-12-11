# Base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# -----------------------------
# Install system dependencies
# -----------------------------
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    xvfb \
    curl \
    gnupg \
    libnss3 \
    libglib2.0-0 \
    libx11-6 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxi6 \
    libxtst6 \
    libxrandr2 \
    libasound2 \
    fonts-liberation \
    lsb-release \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Google Chrome
# -----------------------------
RUN wget -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && apt-get install -y /tmp/google-chrome.deb && \
    rm /tmp/google-chrome.deb

# -----------------------------
# Install ChromeDriver (fixed version)
# -----------------------------
RUN wget -O /tmp/chromedriver.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/143.0.7499.40/linux64/chromedriver-linux64.zip && \
    unzip /tmp/chromedriver.zip -d /tmp/ && \
    mv /tmp/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver && \
    rm -rf /tmp/chromedriver.zip /tmp/chromedriver-linux64

# -----------------------------
# Install Python dependencies
# -----------------------------
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# -----------------------------
# Copy entire project
# -----------------------------
COPY . .

# Make app importable
ENV PYTHONPATH="/app"

# -----------------------------
# Default command: run tests
# -----------------------------
CMD ["pytest", "-q", "tests"]
