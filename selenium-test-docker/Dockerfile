FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y wget unzip ca-certificates gnupg2 python3 python3-pip curl xvfb \
    libnss3 libxss1 libasound2 libgbm1 libgtk-3-0 libx11-xcb1 libx11-6 libxss1 \
 && rm -rf /var/lib/apt/lists/*

# Install Chrome (match version to chromedriver)
RUN wget -q -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
 && apt-get update && apt-get install -y /tmp/chrome.deb || true \
 && rm -f /tmp/chrome.deb

# Install chromedriver from chromefor testing location (latest appropriate)
RUN CHROME_VER=$(google-chrome --version | awk '{print $3}' | cut -d'.' -f1,2,3) || CHROME_VER=114.0.5735.90 \
 && echo "Chrome version: $CHROME_VER" \
 || true

# Simplest: install ChromeDriver via pip selenium-manager (requires selenium>=4.10)
RUN python3 -m pip install --no-cache-dir selenium==4.12.0 webdriver-manager pytest

# Copy tests
WORKDIR /tests
COPY ../tests ./tests
ENV APP_URL=http://app:5000

CMD ["pytest", "-q", "tests/selenium_tests"]
