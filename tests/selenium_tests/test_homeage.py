from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time
import os

def get_driver():
    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    # If running inside same Docker network, use host 'app' or actual URL
    driver = webdriver.Chrome(options=options)
    return driver

def test_homepage_title():
    url = os.environ.get('APP_URL','http://app:5000/')
    d = get_driver()
    d.get(url)
    time.sleep(1)
    assert "Simple Flask App" in d.title or "Simple Flask App" in d.page_source
    d.quit()
