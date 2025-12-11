import pytest
from unittest.mock import MagicMock, patch

# In-memory storage for mock database
mock_people_data = []

def mock_mysql_connect(*args, **kwargs):
    """Mock MySQL connector that stores data in memory"""
    
    mock_conn = MagicMock()
    mock_cursor = MagicMock()
    
    def mock_execute(query, params=None):
        """Mock SQL execution"""
        global mock_people_data
        
        query_upper = query.upper()
        
        # Handle CREATE TABLE
        if 'CREATE TABLE' in query_upper:
            pass  # Table already exists in memory
        
        # Handle INSERT
        elif 'INSERT' in query_upper:
            if params:
                # Store the person's name
                person_id = len(mock_people_data) + 1
                mock_people_data.append({'id': person_id, 'name': params[0]})
        
        # Handle SELECT
        elif 'SELECT' in query_upper:
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
    """Automatically mock the MySQL database for all tests"""
    global mock_people_data
    
    # Reset data before tests
    mock_people_data = []
    
    # Patch mysql.connector.connect directly
    with patch('mysql.connector.connect', side_effect=mock_mysql_connect):
        yield
    
    # Clean up after tests
    mock_people_data = []
