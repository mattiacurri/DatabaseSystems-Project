import oracledb  # Sostituisci cx_Oracle

def get_connection():
    return oracledb.connect(
        user = 'SYSTEM',
        password = 'password123',
        dsn = 'localhost:1521/XEPDB1',
    )