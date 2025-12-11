from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time, os

def get_driver():
    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    return webdriver.Chrome(options=options)

def test_submit_form():
    url = os.environ.get('APP_URL','http://app:5000/')
    d = get_driver()
    d.get(url)
    elem = d.find_element('name', 'name')
    elem.send_keys('Alice')
    elem.submit()
    time.sleep(1)
    d.get(url + 'list')
    assert 'Alice' in d.page_source or 'Alice' in d.find_element('tag name','body').text
    d.quit()
