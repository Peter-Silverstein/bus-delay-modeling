import os
import pandas as pd
import json
import psycopg

# Setting up PostgreSQL connection
try:
    conn = psycopg.connect(
        dbname="sea-gtfs-data",
        user="postgres",
        host="localhost",
        password="Parkour",
        port=5432
    )
    print("Connection successful")
except Exception as e:
    print(f"Connection failed: {e}")