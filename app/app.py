from flask import Flask, render_template, request, redirect, jsonify
import os
import sqlite3

app = Flask(__name__)

# Use SQLite for testing, MySQL for production
USE_SQLITE = os.environ.get('USE_SQLITE', 'true').lower() == 'true'
SQLITE_DB = '/tmp/test.db'

def get_db_conn():
    """Get database connection - SQLite or MySQL based on environment"""
    if USE_SQLITE:
        # Use SQLite (no external database needed)
        conn = sqlite3.connect(SQLITE_DB)
        conn.row_factory = sqlite3.Row
        return conn
    else:
        # Use MySQL (for production)
        import mysql.connector
        from mysql.connector import Error
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
        
        if USE_SQLITE:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS people (
                    id INTEGER PRIMARY KEY AUTOINCREMENT, 
                    name TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
        else:
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
    except Exception as e:
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
        
        if USE_SQLITE:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS people (
                    id INTEGER PRIMARY KEY AUTOINCREMENT, 
                    name TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
        else:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS people (
                    id INT AUTO_INCREMENT PRIMARY KEY, 
                    name VARCHAR(255) NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
        
        # Insert new person
        cur.execute("INSERT INTO people (name) VALUES (?)" if USE_SQLITE else "INSERT INTO people (name) VALUES (%s)", (name,))
        db.commit()
        cur.close()
        db.close()
        
        app.logger.info(f"Added person: {name}")
        return redirect('/')
        
    except Exception as e:
        app.logger.error(f"Error adding person: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/list')
def list_people():
    """List all people from the database"""
    try:
        db = get_db_conn()
        cur = db.cursor()
        
        # Ensure table exists
        if USE_SQLITE:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS people (
                    id INTEGER PRIMARY KEY AUTOINCREMENT, 
                    name TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
        else:
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
        
        if USE_SQLITE:
            people_list = [{'id': row[0], 'name': row[1]} for row in rows]
        else:
            people_list = [{'id': r[0], 'name': r[1]} for r in rows]
        
        app.logger.info(f"Retrieved {len(people_list)} people")
        
        return jsonify({'success': True, 'people': people_list})
        
    except Exception as e:
        app.logger.error(f"Error listing people: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/health')
def health():
    """Health check endpoint"""
    try:
        db = get_db_conn()
        db.close()
        db_type = 'sqlite' if USE_SQLITE else 'mysql'
        return jsonify({'status': 'healthy', 'database': f'{db_type} connected'}), 200
    except Exception as e:
        return jsonify({'status': 'unhealthy', 'database': 'disconnected', 'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
