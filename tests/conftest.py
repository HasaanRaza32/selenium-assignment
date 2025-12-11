import pytest
from unittest.mock import MagicMock, patch

# In-memory storage for mock database
mock_people_data = []

def mock_get_db_conn():
    """Mock database connection that stores data in memory"""
    
    mock_conn = MagicMock()
    mock_cursor = MagicMock()
    
    def mock_execute(query, params=None):
        """Mock SQL execution"""
        global mock_people_data
        
        # Handle CREATE TABLE
        if 'CREATE TABLE' in query.upper():
            pass  # Table already exists in memory
        
        # Handle INSERT
        elif 'INSERT' in query.upper():
            if params:
                # Store the person's name
                person_id = len(mock_people_data) + 1
                mock_people_data.append({'id': person_id, 'name': params[0]})
        
        # Handle SELECT
        elif 'SELECT' in query.upper():
            # Return all people as tuples (id, name)
            mock_cursor.fetchall.return_value = [
                (person['id'], person['name']) for person in mock_people_data
            ]
    
    mock_cursor.execute = mock_execute
    mock_cursor.fetchall = MagicMock(return_value=[])
    mock_cursor.close = MagicMock()
    
    mock_conn.cursor.return_value = mock_cursor
    mock_conn.commit = MagicMock()
    mock_conn.close = MagicMock()
    
    return mock_conn

@pytest.fixture(scope='session', autouse=True)
def mock_database():
    """Automatically mock the database for all tests"""
    global mock_people_data
    
    # Reset data before tests
    mock_people_data = []
    
    # Patch the database connection
    with patch('app.app.get_db_conn', side_effect=mock_get_db_conn):
        yield
    
    # Clean up after tests
    mock_people_data = []
