import datetime
import subprocess
import socket
import os
from dotenv import load_dotenv
import json
from google.cloud import bigquery
from google.oauth2 import service_account
from google.cloud.exceptions import NotFound

load_dotenv()

# The list of IP-Adresses from .env
host_list = json.loads(os.getenv("HOST_LIST"))

# BigQuery-Dataset and Table
dataset_id = "latency_test_dataset"
table_id = "latency_test"

#Service Accout credentials
path_to_sa_key = os.getenv("PATH_TO_SA_KEY")
creds = service_account.Credentials.from_service_account_file(path_to_sa_key, scopes=['https://www.googleapis.com/auth/cloud-platform'])

# Create BigQuery-Client
client = bigquery.Client(credentials=creds)

# Define the schema for the table
schema = [
    bigquery.SchemaField("date", "DATETIME"),
    bigquery.SchemaField("host_name", "STRING"),
    bigquery.SchemaField("ip_address", "STRING"),
    bigquery.SchemaField("description", "STRING"),
    bigquery.SchemaField("result", "STRING"),
    bigquery.SchemaField("latency_ms", "FLOAT"),
]

# Create table (if it does not exist yet)
table_ref = client.dataset(dataset_id).table(table_id)
table = bigquery.Table(table_ref, schema=schema)
try:
    client.get_table(table)
    print(f'Table {table_id} already exists.')
except NotFound:
    table = client.create_table(table)
    print(f'Table {table_id} created.')

num_pings = 5

for ping in range(num_pings):
    # Perform pings and save results
    for host_name in host_list:
        host = list(host_name.keys())[0]
        ip = socket.gethostbyname(host)
        description = host_name[host]
        try:
            # Ping perform
            output = subprocess.check_output(["ping", "-c", "1", host])
            result = "Success"
        except subprocess.CalledProcessError as e:
            output = e.output
            result = "Failure"
        # Format outputs
        date = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        output_str = output.decode("utf-8")
        output_time = [line for line in output_str.split('\n') if "time=" in line][0]
        latency_str = output_time.split("time=")[1]
        latency = float(latency_str.split(" ")[0])
        # Save results in BigQuery
        rows_to_insert = [
            ({'date': date, 'host_name': host, 'ip_address': ip, 'description': description, 'result': result, 'latency_ms': latency})
        ]
        errors = client.insert_rows(table, rows_to_insert)
        if errors == []:
            print(f"Results for {host} successfully stored in BigQuery.")
        else:
            print(f"Error saving results for {host} in BigQuery: {errors}")