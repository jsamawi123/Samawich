# Full-text Search Microservice for Microblog Bottle Application using Redis
# James Samawi 5/4/2021
import re
import redis
import json
import bottle
from bottle import get, post, request, response, abort


# Set up Bottle app
app = bottle.default_app()

# Start Redis K-V store with default port and initialize object
r = redis.StrictRedis(host='localhost',port=6379,db=0)

# Stop words from https://www.geeksforgeeks.org/removing-stop-words-nltk-python/
stopWords = ['ourselves', 'hers', 'between', 'yourself', 'but', 'again', 'there', 'about', 'once', 'during', 'out', 
			'very', 'having', 'with', 'they', 'own', 'an', 'be', 'some', 'for', 'do', 'its', 'yours', 'such', 'into', 
			'of', 'most', 'itself', 'other', 'off', 'is', 's', 'am', 'or', 'who', 'as', 'from', 'him', 'each', 'the', 
			'themselves', 'until', 'below', 'are', 'we', 'these', 'your', 'his', 'through', 'don', 'nor', 'me', 'were', 
			'her', 'more', 'himself', 'this', 'down', 'should', 'our', 'their', 'while', 'above', 'both', 'up', 'to', 
			'ours', 'had', 'she', 'all', 'no', 'when', 'at', 'any', 'before', 'them', 'same', 'and', 'been', 'have', 
			'in', 'will', 'on', 'does', 'yourselves', 'then', 'that', 'because', 'what', 'over', 'why', 'so', 'can', 
			'did', 'not', 'now', 'under', 'he', 'you', 'herself', 'has', 'just', 'where', 'too', 'only', 'myself', 
			'which', 'those', 'i', 'after', 'few', 'whom', 't', 'being', 'if', 'theirs', 'my', 'against', 'a', 'by', 
			'doing', 'it', 'how', 'further', 'was', 'here', 'than']

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


# 1. Endpoint adds the text of a post identified by postId to the inverted index.
# http --verbose POST http://localhost:8080/index text="Hello.World" postId=1
@post('/index')
def index():
	req = request.json
	if not req:
		abort(400)
	
	posted_fields = req.keys()
	required_fields = {'postId', 'text'}
	if required_fields > posted_fields:
		abort(400, f'Missing fields: {required_fields - posted_fields}')
	elif posted_fields > required_fields:
		abort(400, f'Extra field(s): {posted_fields - required_fields}')

	index = request.json['postId']
	text  = request.json['text']
	
	# Strip punctuation (from python string module)
	text = re.sub("[!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~]", " ", text)
	text = text.lower()
	
	# Split on whitespace
	keywords = text.split(' ')
	
	# Fold Cases
	keywords = [word for word in keywords if word != ""]
	
	# Remove stop words
	keywords = [word for word in keywords if word not in stopWords]

	for word in keywords:
		try:
			r.sadd(word, index)
		except:
			abort(500, "Could not insert keyword or index.")
	
	response.body = "Successfully created keyword(s)."
	response.status = 201
	response.content_type = 'application/json'
	return response


# 2. Endpoint returns a list of postIds whose text contains keyword.
# http --verbose GET http://localhost:8080/index/hello
@get('/index/<keyword>')
def search(keyword):
	try:
		indexList = r.smembers(keyword)
	except: 
		abort(400, f'Keyword {keyword} not found.')
	response.body = indexList
	response.status = 200
	response.content_type = 'application/json'
	return response


# 3. Endpoint returns a list of postIds whose text contains any of the words in keywordList.
# http --verbose GET http://localhost:8080/index/any keywordList:='["hello","world"]'
@get('/index/any')
def any():
	req = request.json
	if not req:
		abort(400)
	
	posted_fields = req.keys()
	required_fields = {'keywordList'}
	if required_fields > posted_fields:
		abort(400, f'Missing fields: {required_fields - posted_fields}')
	elif posted_fields > required_fields: 
		abort(400, f'Extra field(s): {posted_fields - required_fields}')

	Indexes = []
	for keyword in request.json['keywordList']:
		try:
			indexList = r.smembers(keyword)
			for index in indexList:
				if index not in Indexes:
					Indexes.append(index)
		except:
			abort(400, f'Keyword {keyword} not found.')

	response.body = Indexes
	response.status = 200
	response.content_type = 'application/json'
	return response


# 4. Endpoint returns a list of postIds whose text contains all of the words in keywordList.
# http --verbose GET http://localhost:8080/index/all keywordList:='["hello","world"]' 
@get('/index/all')
def all():
	req = request.json
	if not req:
		abort(400)
	
	posted_fields = req.keys()
	required_fields = {'keywordList'}
	if required_fields > posted_fields:
		abort(400, f'Missing fields: {required_fields - posted_fields}')
	elif posted_fields > required_fields:
		abort(400, f'Extra field(s): {posted_fields - required_fields}')

	Indexes = []
	isEmpty = True
	for keyword in request.json['keywordList']:
		try:
			indexList = r.smembers(keyword)
			if(isEmpty):
				Indexes = indexList
				isEmpty = False
			else:
				Indexes = list(set(Indexes) & set(indexList))
		except: 
			abort(400, f'Keyword {keyword} not found.')
		
	response.body = Indexes
	response.status = 200
	response.content_type = 'application/json'
	return response


# 5. Endpoint returns a list of postIds whose text contains any of the words in keywordList unless they also contain a word in excludeList.
# http --verbose GET http://localhost:8080/index/exclude includeList:='["hello"]' excludeList:='["world"]'
@get('/index/exclude')
def exclude():
	req = request.json
	if not req:
		abort(400)
	
	posted_fields = req.keys()
	required_fields = {'includeList', 'excludeList'}
	if required_fields > posted_fields:
		abort(400, f'Missing fields: {required_fields - posted_fields}')
	elif posted_fields > required_fields:
		abort(400, f'Extra field(s): {posted_fields - required_fields}')

	Includes = []
	Excludes = []
	for keyword in request.json['includeList']:
		try:
			indexList = r.smembers(keyword)
			for index in indexList:
				if index not in Includes:
					Includes.append(index)
		except:
			abort(400, f'Keyword {keyword} not found.')

	for keyword in request.json['excludeList']:
		try:
			indexList = r.smembers(keyword)
			for index in indexList:
				if index not in Excludes:
					Excludes.append(index)
		except:
			abort(400, f'Keyword {keyword} not found.')

	response.body = list(set(Includes) - set(Excludes))
	response.status = 200
	response.content_type = 'application/json'
	return response
