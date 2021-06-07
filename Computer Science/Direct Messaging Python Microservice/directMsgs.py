#!/usr/bin/env python3

import sys
import json
import boto3
from boto3.dynamodb.conditions import Key, Attr
from uuid import uuid4
from datetime import datetime, timezone

import bottle
import logging.config
from bottle import get, post, delete, error, abort, request, response, HTTPResponse

app = bottle.default_app()
app.config.load_config('./etc/directMsg.ini')
logging.config.fileConfig(app.config['logging.config'])

# Return errors in JSON
#
# Adapted from # <https://stackoverflow.com/a/39818780>
#
def json_error_handler(res):
    if res.content_type == 'application/json':
        return res.body
    res.content_type = 'application/json'
    if res.body == 'Unknown Error.':
        res.body = bottle.HTTP_CODES[res.status_code]
    return bottle.json_dumps({'error': res.body})

app.default_error_handler = json_error_handler

# Disable warnings produced by Bottle 0.12.19.
#
#  1. Deprecation warnings for bottle_sqlite
#  2. Resource warnings when reloader=True
#
# See
#  <https://docs.python.org/3/library/warnings.html#overriding-the-default-filter>
#
if not sys.warnoptions:
    import warnings
    for warning in [DeprecationWarning, ResourceWarning]:
        warnings.simplefilter('ignore', warning)

def get_dynamodb_client():
    dynamodb = boto3.client("dynamodb", endpoint_url="http://localhost:8000")
    return dynamodb

def get_dynamodb_resource():
    dynamodb = boto3.resource('dynamodb', endpoint_url='http://localhost:8000')
    return dynamodb

#check a key of a dictionary
def checkKey(dict, key):
    if key in dict.keys():
        return True
    else:
        return False


# http --verbose POST http://localhost:8080/users/Foo/directMessages/ from=Bar message="Hello World!" quickReplies:='["Hi", "Hello", "(:"]'
@post('/users/<username>/directMessages/')
def sendDirectMessage(username):
    user = request.json
    if not user:
        abort(400)
    posted_fields = user.keys()
    required_fields = {'from', 'message'}

    if not required_fields <= posted_fields:
        abort(400, f"Missing fields: {required_fields - posted_fields}")

    quickReplies = checkKey(user, "quickReplies")

    if quickReplies:
        itemResponse = get_dynamodb_resource().Table("DirectMessages").put_item(
            Item={
                'to': username,
                'messageId': str(uuid4()),
                'from': user['from'],
                'message': user['message'],                                            
                'quickReplies': user['quickReplies'],
                'timestamp': datetime.utcnow().replace(tzinfo=timezone.utc).isoformat()
            }
        )
    else:
        itemResponse = get_dynamodb_resource().Table("DirectMessages").put_item(
            Item={
                'to': username,
                'messageId': str(uuid4()),
                'from': user['from'],
                'message': user['message'],
                'timestamp': datetime.utcnow().replace(tzinfo=timezone.utc).isoformat()
            }
        )

    response.status = 201
    
    return f"{user['from']} sent a DM to {username}."  # Bar sent a DM to Foo.


# http --verbose POST http://localhost:8080/users/Bar/directMessages/54d407bb-2daf-48ad-96a8-2149477dcafd/ message=1
@post('/users/<username>/directMessages/<messageId>/') 
def replyToDirectMessage(username, messageId):
    message = request.json
    if not message:
        abort(400)
    posted_fields = message.keys()
    required_fields = {'message'}
    if not required_fields <= posted_fields:
        abort(400, f'Missing fields: {required_fields - posted_fields}')

    try:
        respList = get_dynamodb_resource().Table("DirectMessages").get_item(
            Key={
                'to':username,
                'messageId':messageId
            }
        )
    except Exception as e:
        abort(400, str(e))
    else:
        if checkKey(respList, 'Item'):
            item = respList['Item']
            if message['message'].isnumeric():  # for numeric DM reply, send number and in-reply-to:
                get_dynamodb_resource().Table("DirectMessages").put_item(
                    Item = {
                        'to': item['from'],
                        'messageId': str(uuid4()),
                        'from': username,
                        'message': message['message'],
                        'in-reply-to': messageId, 
                        'timestamp': datetime.utcnow().replace(tzinfo=timezone.utc).isoformat()
                    }
                ) 
            else:  # for non-numeric DM reply, send string message:
                get_dynamodb_resource().Table("DirectMessages").put_item(
                    Item = {
                        'to': item['from'],
                        'messageId': str(uuid4()),
                        'from': username,
                        'message': message['message'],
                        'timestamp': datetime.utcnow().replace(tzinfo=timezone.utc).isoformat()
                    }
                )
        else:
            abort(500)    

    response.status = 201
    return f"{username} replied to {item['from']}'s DM."  # Bar replied to Foo's DM.


# http --verbose GET http://localhost:8080/users/Foo/directMessages/
@get('/users/<username>/directMessages/')
def listDirectMessagesFor(username):
    user = get_dynamodb_resource().Table("DirectMessages").query(
            KeyConditionExpression = Key('to').eq(username)
    )

    if not user['Items']:
            abort(400)
    else:
        response.status = 200
        return {'user': user['Items']}    


# http --verbose GET http://localhost:8080/users/Foo/directMessages/54d407bb-2daf-48ad-96a8-2149477dcafd/
@get('/users/<username>/directMessages/<messageId>/')
def listRepliesTo(username, messageId):
    try:
        reply = get_dynamodb_resource().Table("DirectMessages").query(
            KeyConditionExpression = Key('to').eq(username)
        )
        replyList = []
        replies = reply['Items']
        
        for item in replies:
            itemReplied = checkKey(item, 'in-reply-to')
            if itemReplied:
                if item['in-reply-to'] == messageId:
                    replyList.append(item)
        
        for item in replyList:
            if item['message'].isnumeric():
                try:
                    resp = get_dynamodb_resource().Table("DirectMessages").get_item(
                        Key={
                            'to' : item['from'],
                            'messageId' : messageId
                            }
                        )
                    quickReplies = resp['Item']['quickReplies']
                    item['message'] = quickReplies[int(item['message'])]
                except Exception as e:
                    abort(500, str(e))
                
    except Exception as e:
        abort(500, str(e))
    if not replyList:
        abort(400)
    else:
        response.status = 200
        return {username: replyList}
