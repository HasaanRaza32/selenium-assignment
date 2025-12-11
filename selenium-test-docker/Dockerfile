# Use Ubuntu base
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget unzip ca-certificates gnupg2 python3 python3-pip curl xvfb \
    libnss3 libxss1 libasound2 libgbm1 libgtk-3-0 libx11-xcb1 libx11-6 \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome (matching version to chromedriver)
RUN wget -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update && apt-get install -y /tmp/chrome.deb || true \
    && rm -rf /tmp/chrome.deb

# Get Chrome version
RUN CHROME_VER=$(google-chrome --version | awk '{print $3}' | cut -d '.' -f1,2,3) || CHROME_VER=114.0.5735.90 \
    && echo "Chrome version: $CHROME_VER"

# Install Python Selenium and webdriver-manager
RUN python3 -m pip install --no-cache-dir selenium==4.12.0 webdriver-manager pytest

# Set working directory
WORKDIR /tests

# Set environment variable for app URL
ENV APP_URL=http://app:5000

# Copy Selenium tests (make sure the build context includes these)
COPY . /tests

# Default command to run tests
CMD ["pytest", "-q", "selenium_tests"]
