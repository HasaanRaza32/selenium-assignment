import os
from main import app

def test_index():
    client = app.test_client()
    res = client.get('/')
    assert res.status_code == 200
    assert b"Simple Flask App" in res.data
