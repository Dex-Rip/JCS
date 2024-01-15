import sqlite3

def create_database():
    conn = sqlite3.connect('check_service.db')
    cursor = conn.cursor()

    # Create table for recipients
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS recipients (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            address TEXT NOT NULL
        )
    ''')

    # Create table for contracts
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS contracts (
            id INTEGER PRIMARY KEY,
            hash TEXT NOT NULL,
            description TEXT
        )
    ''')

    conn.commit()
    conn.close()

if __name__ == "__main__":
    create_database()
    print("Database and tables created successfully.")
