FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y wget unzip ca-certificates gnupg2 python3 python3-pip curl xvfb \
    libnss3 libxss1 libasound2 libgbm1 libgtk-3-0 libx11-xcb1 libx11-6 \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN wget -q -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update && apt-get install -y /tmp/chrome.deb || true \
    && rm -f /tmp/chrome.deb

# Install Python packages
RUN python3 -m pip install --no-cache-dir selenium==4.12.0 webdriver-manager pytest

# Set working directory for tests
WORKDIR /app

# Copy application code and tests
COPY app /app/app
COPY tests /app/tests

# Set environment variable for app URL
ENV APP_URL=http://app:5000

# Default command
CMD ["pytest", "-q", "tests"]
