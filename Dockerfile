# Use official Python 3.9 slim image
FROM python:3.9-slim

# Install dependencies for Chrome and Selenium
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    curl \
    xvfb \
    gnupg \
    ca-certificates \
    libnss3 \
    libxss1 \
    libfontconfig1 \
    libx11-xcb1 \
    && rm -rf /var/lib/apt/lists/*

# Add Google signing key and repository (new way)
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-linux-signing-key.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-key.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Install ChromeDriver matching Chrome version
RUN CHROME_VERSION=$(google-chrome --version | awk '{print $3}') \
    && CHROME_MAJOR=$(echo $CHROME_VERSION | cut -d '.' -f1) \
    && DRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_MAJOR") \
    && wget -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/${DRIVER_VERSION}/chromedriver_linux64.zip" \
    && unzip /tmp/chromedriver.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/chromedriver \
    && rm /tmp/chromedriver.zip

# Set working directory
WORKDIR /app

# Copy Python requirements and install
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY . /app

# Expose Flask port
EXPOSE 5000

# Default command to run tests
CMD ["pytest", "-q", "tests"]
