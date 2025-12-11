FROM python:3.9-slim

WORKDIR /app

# -----------------------------
# Install system dependencies
# -----------------------------
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    xvfb \
    gnupg \
    curl

# -----------------------------
# Install Google Chrome
# -----------------------------
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list

RUN apt-get update && apt-get install -y google-chrome-stable

# -----------------------------
# Install matching ChromeDriver
# -----------------------------
RUN CHROME_VERSION=$(google-chrome --version | awk '{print $3}' | cut -d '.' -f1) && \
    DRIVER_VERSION=$(curl -s "https://googlechromelabs.github.io/chrome-for-testing/latest-linux64.json" \
                     | grep -oP '"version": "\K[0-9.]+' | head -1) && \
    wget -q -O /tmp/chromedriver.zip \
        "https://storage.googleapis.com/chrome-for-testing-public/${DRIVER_VERSION}/linux64/chromedriver-linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    mv /usr/local/bin/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver

# -----------------------------
# Install Python dependencies
# -----------------------------
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# -----------------------------
# Copy entire project
# -----------------------------
COPY . .

# Make app/ importable
ENV PYTHONPATH="/app"

# -----------------------------
# Run tests
# -----------------------------
CMD ["pytest", "-q", "tests"]
