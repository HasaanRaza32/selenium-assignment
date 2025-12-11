from flask import Flask, render_template, request, redirect
import os
import mysql.connector

app = Flask(__name__)

def get_db_conn():
    return mysql.connector.connect(
        host=os.environ.get('MYSQL_HOST','mysql'),
        user=os.environ.get('MYSQL_USER','wordpress'),
        password=os.environ.get('MYSQL_PASSWORD','password'),
        database=os.environ.get('MYSQL_DATABASE','appdb')
    )

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/add', methods=['POST'])
def add():
    name = request.form.get('name')
    if not name:
        return "Name required", 400
    db = get_db_conn()
    cur = db.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS people (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255))")
    cur.execute("INSERT INTO people (name) VALUES (%s)", (name,))
    db.commit()
    cur.close()
    db.close()
    return redirect('/')

@app.route('/list')
def list_people():
    db = get_db_conn()
    cur = db.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS people (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255))")
    cur.execute("SELECT id, name FROM people")
    rows = cur.fetchall()
    cur.close()
    db.close()
    return {'people': [{'id': r[0], 'name': r[1]} for r in rows]}

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000,debug=False)
