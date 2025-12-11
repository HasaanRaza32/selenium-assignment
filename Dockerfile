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
    && mv chromedriver-linux64/chromedriver /usr/bin/chromedriver \
    && chmod +x /usr/bin/chromedriver \
    && rm -rf chromedriver-linux64.zip chromedriver-linux64

# Set working directory
WORKDIR /app

# Copy requirements first (for Docker layer caching)
COPY app/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app
COPY . .

# Set environment variables
ENV PYTHONPATH=/app
ENV FLASK_APP=app/app.py

# Expose Flask app port
EXPOSE 5000

# Create startup script that runs Flask in background, waits for it to be ready, then runs tests
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "========================================="\n\
echo "Starting Flask Application..."\n\
echo "========================================="\n\
\n\
# Start Flask in background\n\
python -m flask run --host=0.0.0.0 --port=5000 &\n\
FLASK_PID=$!\n\
echo "Flask started with PID: $FLASK_PID"\n\
\n\
# Wait for Flask to be ready\n\
echo "Waiting for Flask to be ready..."\n\
MAX_RETRIES=30\n\
RETRY_COUNT=0\n\
\n\
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do\n\
  if curl -s http://localhost:5000/ > /dev/null 2>&1; then\n\
    echo "✓ Flask is ready and responding!"\n\
    break\n\
  fi\n\
  RETRY_COUNT=$((RETRY_COUNT + 1))\n\
  echo "Waiting for Flask... ($RETRY_COUNT/$MAX_RETRIES)"\n\
  sleep 1\n\
done\n\
\n\
if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then\n\
  echo "✗ Flask failed to start within 30 seconds"\n\
  kill $FLASK_PID 2>/dev/null || true\n\
  exit 1\n\
fi\n\
\n\
echo ""\n\
echo "========================================="\n\
echo "Running Selenium Tests..."\n\
echo "========================================="\n\
\n\
# Run tests\n\
pytest -v tests/\n\
TEST_EXIT_CODE=$?\n\
\n\
echo ""\n\
echo "========================================="\n\
echo "Cleaning up..."\n\
echo "========================================="\n\
\n\
# Stop Flask\n\
echo "Stopping Flask (PID: $FLASK_PID)..."\n\
kill $FLASK_PID 2>/dev/null || true\n\
wait $FLASK_PID 2>/dev/null || true\n\
echo "✓ Flask stopped"\n\
\n\
echo ""\n\
if [ $TEST_EXIT_CODE -eq 0 ]; then\n\
  echo "========================================="\n\
  echo "✓ ALL TESTS PASSED!"\n\
  echo "========================================="\n\
else\n\
  echo "========================================="\n\
  echo "✗ TESTS FAILED!"\n\
  echo "========================================="\n\
fi\n\
\n\
exit $TEST_EXIT_CODE\n\
' > /app/run_tests.sh && chmod +x /app/run_tests.sh

# Run the startup script
CMD ["/app/run_tests.sh"]
