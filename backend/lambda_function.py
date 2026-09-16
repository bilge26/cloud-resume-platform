import json
import os

import boto3


def get_table():
    dynamodb = boto3.resource("dynamodb")
    return dynamodb.Table(os.environ["TABLE_NAME"])


def lambda_handler(event, context):
    table = get_table()

    response = table.update_item(
        Key={"id": "visitor-count"},
        UpdateExpression="ADD #count :increment",
        ExpressionAttributeNames={
            "#count": "count",
        },
        ExpressionAttributeValues={
            ":increment": 1,
        },
        ReturnValues="UPDATED_NEW",
    )

    count = int(response["Attributes"]["count"])

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "count": count,
        }),
    }