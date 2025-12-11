from flask import Flask, render_template, request, redirect, jsonify
import os
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

def get_db_conn():
    """Get database connection using environment variables with fallback defaults"""
    try:
        return mysql.connector.connect(
            host=os.environ.get('MYSQL_HOST', 'mysql'),
            user=os.environ.get('MYSQL_USER', 'wordpress'),
            password=os.environ.get('MYSQL_PASSWORD', 'password'),
            database=os.environ.get('MYSQL_DATABASE', 'appdb')
        )
    except Error as e:
        app.logger.error(f"Database connection error: {e}")
        raise

def init_db():
    """Initialize database table if it doesn't exist"""
    try:
        db = get_db_conn()
        cur = db.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS people (
                id INT AUTO_INCREMENT PRIMARY KEY, 
                name VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        db.commit()
        cur.close()
        db.close()
    except Error as e:
        app.logger.error(f"Database initialization error: {e}")

@app.route('/')
def index():
    """Homepage route"""
    return render_template('index.html')

@app.route('/add', methods=['POST'])
def add():
    """Add a new person to the database"""
    try:
        name = request.form.get('name')
        
        if not name:
            return jsonify({'success': False, 'error': 'Name required'}), 400
        
        # Initialize table if needed
        db = get_db_conn()
        cur = db.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS people (
                id INT AUTO_INCREMENT PRIMARY KEY, 
                name VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Insert new person
        cur.execute("INSERT INTO people (name) VALUES (%s)", (name,))
        db.commit()
        cur.close()
        db.close()
        
        app.logger.info(f"Added person: {name}")
        return redirect('/')
        
    except Error as e:
        app.logger.error(f"Error adding person: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/list')
def list_people():
    """List all people from the database"""
    try:
        db = get_db_conn()
        cur = db.cursor()
        
        # Ensure table exists
        cur.execute("""
            CREATE TABLE IF NOT EXISTS people (
                id INT AUTO_INCREMENT PRIMARY KEY, 
                name VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Fetch all people
        cur.execute("SELECT id, name FROM people ORDER BY id DESC")
        rows = cur.fetchall()
        cur.close()
        db.close()
        
        people_list = [{'id': r[0], 'name': r[1]} for r in rows]
        app.logger.info(f"Retrieved {len(people_list)} people")
        
        return jsonify({'success': True, 'people': people_list})
        
    except Error as e:
        app.logger.error(f"Error listing people: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/health')
def health():
    """Health check endpoint"""
    try:
        db = get_db_conn()
        db.close()
        return jsonify({'status': 'healthy', 'database': 'connected'}), 200
    except:
        return jsonify({'status': 'unhealthy', 'database': 'disconnected'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
