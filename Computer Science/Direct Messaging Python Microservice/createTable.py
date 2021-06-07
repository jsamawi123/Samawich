#!/usr/bin/env python3

import json
import boto3
from boto3.dynamodb.conditions import Key, Attr
from datetime import datetime, timezone


def get_dynamodb_client():
    dynamodb = boto3.client("dynamodb", endpoint_url="http://localhost:8000")
    return dynamodb

def get_dynamodb_resource():
    dynamodb = boto3.resource('dynamodb', endpoint_url='http://localhost:8000')
    return dynamodb

def create_table():
    old_table = get_dynamodb_resource().Table("DirectMessages")
    old_table.delete()

    table_name = "DirectMessages"

    attribute_definitions = [
        {
            'AttributeName': 'to',
            'AttributeType': 'S',  # S = String           
        },
        {
            'AttributeName': 'messageId',
            'AttributeType': 'S'  # S = String
        }
    ]

    key_schema = [
        {
            'AttributeName': 'to',
            'KeyType':'HASH'  # Partition key
        },
        {
            'AttributeName':'messageId',
            'KeyType':'RANGE'  # Sort key
        }
    ]
    
    provisioned_throughput = {
        'ReadCapacityUnits': 10,
        'WriteCapacityUnits': 10
    }
    
    table_response = get_dynamodb_client().create_table(
        AttributeDefinitions = attribute_definitions,
        TableName = table_name,
        KeySchema = key_schema,
        ProvisionedThroughput = provisioned_throughput      
    )
    
    print("Created DirectMessages table")


def insert_into_table():
    table_name = get_dynamodb_resource().Table("DirectMessages")
    
    with table_name.batch_writer() as batch:
        batch.put_item(
            Item={
                'to': 'Bar',
                'messageId': 'a909fc63-659c-4824-9357-d6209fe761ed',
                'from': 'Foo',
                'message':'Hey Mr. Bar! I have a question.',
                'timestamp': datetime.utcnow().replace(tzinfo=timezone.utc).isoformat()
            }           
        )
        batch.put_item(
            Item={
                'to': 'Foo',
                'messageId': '85d58177-4113-4fe3-942e-e193016fb345',
                'from': 'Bar',
                'message': "Hello Foo! What's on your mind?",               
                'timestamp': datetime.utcnow().replace(tzinfo=timezone.utc).isoformat()
            }
        )
        batch.put_item(
            Item={
                'to': 'Bar',
                'messageId': '54d407bb-2daf-48ad-96a8-2149477dcafd',
                'from': 'Foo',
                'message':'By any chance, are you free for lunch tomorrow?',
                'quickReplies': ["Yes", "No", "Call me"],
                'timestamp': datetime.utcnow().replace(tzinfo=timezone.utc).isoformat()
            }           
        )
        batch.put_item(
            Item={
                'to': 'Foo',
                'messageId': 'b81e200d-0ef0-4e26-848b-5f59086eda65',
                'from': 'Bar',
                'message': "1",
                'in-reply-to': '54d407bb-2daf-48ad-96a8-2149477dcafd',
                'timestamp': datetime.utcnow().replace(tzinfo=timezone.utc).isoformat()
            }
        )
        batch.put_item(
            Item={
                'to': 'Bar',
                'messageId': '3f1d6f48-46ee-4284-a542-5e090810a94a',
                'from': 'Foo',
                'message': "Oh... Well that is okay, maybe next time!",
                'timestamp': datetime.utcnow().replace(tzinfo=timezone.utc).isoformat()
            }
        )
        batch.put_item(
            Item={
                'to': 'Foo',
                'messageId': 'dbdfb045-8f3c-45e9-98d3-a7b82a2898ff',
                'from': 'Bar',
                'message': "Totally! Maybe after my midterm tomorrow we can try.",
                'timestamp': datetime.utcnow().replace(tzinfo=timezone.utc).isoformat()
            }
        )
        
    print("Inserted values into DirectMessages table")


if __name__ == '__main__':
    create_table()
    insert_into_table()  # comment this to start with empty table.
