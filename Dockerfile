# -----------------------------
# Base image
# -----------------------------
FROM python:3.9-slim

# -----------------------------
# Environment variables
# -----------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV APP_URL=http://127.0.0.1:5000/

# -----------------------------
# Install dependencies
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    curl \
    xvfb \
    gnupg \
    unzip \
    libnss3 \
    libxss1 \
    libgconf-2-4 \
    libfontconfig1 \
    libx11-xcb1 \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Chrome
# -----------------------------
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb

# -----------------------------
# Install ChromeDriver
# -----------------------------
RUN CHROME_VERSION=$(google-chrome --version | awk '{print $3}' | cut -d '.' -f1) && \
    DRIVER_VERSION=$(curl -s "https://googlechromelabs.github.io/chrome-for-testing/latest-linux64.json" \
        | grep -oP '"version": "\K[0-9.]+' | head -1) && \
    wget -q -O /tmp/chromedriver.zip "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${DRIVER_VERSION}/linux64/chromedriver-linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    mv /usr/local/bin/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver && \
    rm -rf /tmp/chromedriver.zip /usr/local/bin/chromedriver-linux64

# -----------------------------
# Copy application code
# -----------------------------
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# -----------------------------
# Expose port
# -----------------------------
EXPOSE 5000

# -----------------------------
# Start Flask and run Selenium tests
# -----------------------------
CMD flask --app app/app.py run --host=0.0.0.0 & \
    sleep 5 && \
    pytest -q tests
