import oracledb

def get_connection():
    connection = oracledb.connect(
        user = 'SYSTEM',
        password = 'password123',
        dsn = 'localhost:1521/XEPDB1'
    )
    cursor = connection.cursor()
    cursor.execute("ALTER SESSION SET CURRENT_SCHEMA = brightway_admin")
    return connection