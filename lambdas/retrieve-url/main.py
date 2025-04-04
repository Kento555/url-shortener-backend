import os
import boto3

region_aws = os.getenv("REGION_AWS")
db_tablename = os.getenv("DB_NAME")

ddb = boto3.resource("dynamodb", region_name=region_aws).Table(db_tablename)


def lambda_handler(event, context):
    short_id = event.get("short_id")

    if not short_id:
        return {
            "statusCode": 400,
            "body": "Missing short_id in request.",
        }

    try:
        item = ddb.get_item(Key={"short_id": short_id})
        long_url = item.get("Item", {}).get("long_url")

        if not long_url:
            raise ValueError("short_id not found or no long_url")

        ddb.update_item(
            Key={"short_id": short_id},
            UpdateExpression="SET hits = hits + :val",
            ExpressionAttributeValues={":val": 1},
        )

        return {
            "statusCode": 302,
            "headers": {"Location": long_url},
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            "statusCode": 400,
            "body": "short_id or URL invalid in request.",
        }
