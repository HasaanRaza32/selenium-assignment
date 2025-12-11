# Use official Python 3.9 slim image
FROM python:3.9-slim

# Install dependencies for Chrome and Selenium
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

# Install Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-linux-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/google-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable && rm -rf /var/lib/apt/lists/*

# Set Chrome options environment
ENV CHROME_BIN=/usr/bin/google-chrome

# Install Python dependencies
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY . /app

# Install ChromeDriver matching the installed Chrome version
RUN CHROME_VERSION=$(google-chrome --version | awk '{print $3}' | cut -d '.' -f1) && \
    DRIVER_VERSION=$(curl -s "https://googlechromelabs.github.io/chrome-for-testing/latest-linux64.json" | grep -oP '"version": "\K[0-9.]+' | head -1) && \
    wget -O /tmp/chromedriver.zip "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${DRIVER_VERSION}/linux64/chromedriver-linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    mv /usr/local/bin/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver && \
    rm -rf /tmp/chromedriver.zip /usr/local/bin/chromedriver-linux64

# Expose port for Flask app
EXPOSE 5000

# Default command to run tests
CMD ["pytest", "-q", "tests"]
