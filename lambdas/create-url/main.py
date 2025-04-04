import os
import json
import boto3
from string import ascii_letters, digits
from random import choice, randint
from time import time, strftime
from urllib import parse

app_url = os.getenv("APP_URL")
min_char = int(os.getenv("MIN_CHAR", 8))
max_char = int(os.getenv("MAX_CHAR", 16))
region_aws = os.getenv("REGION_AWS")
db_tablename = os.getenv("DB_NAME")

string_format = ascii_letters + digits
ddb = boto3.resource("dynamodb", region_name=region_aws).Table(db_tablename)


def generate_timestamp():
    return strftime("%Y-%m-%dT%H:%M:%S")


def expiry_date():
    return int(time()) + 604800


def check_id(short_id):
    response = ddb.get_item(Key={"short_id": short_id})
    if "Item" in response:
        return generate_id()
    return short_id


def generate_id():
    short_id = "".join(
        choice(string_format) for _ in range(randint(min_char, max_char))
    )
    return check_id(short_id)


def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
        long_url = body.get("long_url")

        if not long_url:
            raise ValueError("Missing long_url")

        short_id = generate_id()
        short_url = app_url + short_id
        timestamp = generate_timestamp()
        ttl_value = expiry_date()

        analytics = {
            "user_agent": event.get("headers", {}).get("User-Agent"),
            "source_ip": event.get("headers", {}).get("X-Forwarded-For"),
            "xray_trace_id": event.get("headers", {}).get("X-Amzn-Trace-Id"),
        }

        url_params = parse.parse_qs(parse.urlsplit(long_url).query)
        for k, v in url_params.items():
            analytics[k] = v[0] if v else None

        ddb.put_item(
            Item={
                "short_id": short_id,
                "created_at": timestamp,
                "ttl": ttl_value,
                "short_url": short_url,
                "long_url": long_url,
                "analytics": analytics,
                "hits": 0,
            }
        )

        return {
            "statusCode": 200,
            "body": short_url,
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            "statusCode": 400,
            "body": "Invalid request.",
        }
