import os
import json
import boto3
from string import ascii_letters, digits
from random import choice, randint
from time import strftime, time
from urllib import parse


app_url = os.getenv('APP_URL')  #Your API Gateway Custom Domain
min_char = int(os.getenv('MIN_CHAR'))  #e.g. 12 (min length of shortid)
max_char = int(os.getenv('MAX_CHAR'))  #e.g. 16 (max length of shortid)
region_aws = os.getenv('REGION_AWS')
db_tablename = os.getenv('DB_NAME')
string_format = ascii_letters + digits

ddb = boto3.resource('dynamodb', region_name = region_aws).Table(db_tablename)

def generate_timestamp():
    response = strftime("%Y-%m-%dT%H:%M:%S")
    return response

def expiry_date():
    response = int(time()) + int(604800)
    return response

def check_id(short_id):
    if 'Item' in ddb.get_item(Key={'short_id': short_id}):
        response = generate_id()
    else:
        return short_id

def generate_id():
    short_id = "".join(choice(string_format) for x in range(randint(min_char, max_char)))
    print(short_id)
    response = check_id(short_id)
    return response

def lambda_handler(event, context):
    analytics = {}
    print(event)
    short_id = generate_id()
    short_url = app_url + short_id
    long_url = json.loads(event.get('body')).get('long_url')
    timestamp = generate_timestamp()
    ttl_value = expiry_date()
