Project 6 CPSC 449-01: Full-text Search Microservice for Microblog Bottle Application using Redis
Author: James Samawi (jsamawi@csu.fullerton.edu) 893474445


Install Redis for command line:
$ sudo apt install --yes redis

Install Redis-py for Python:
$ sudo apt install --yes python3-hiredis

Run the textSearch microservice:
(cd to project directory)
$ foreman start

Start a new terminal. Assure Redis is up and running (response: PONG):
(any directory)
$ redis-cli -p 6379 ping


Example usage...

Populate the Redis database with Microblog user's text and postId:
$ http --verbose POST http://localhost:8080/index text="My microservice for my back-end engineering class is finally finished!" postId=0
$ http --verbose POST http://localhost:8080/index text="The microservice for my class is about an inverted index implement." postId=1
$ http --verbose POST http://localhost:8080/index text="After my class I am going to have a wonderful summer!" postId=2

	Output:
	POST /index HTTP/1.1
	Accept: application/json, */*
	Accept-Encoding: gzip, deflate
	Connection: keep-alive
	Content-Length: 80
	Content-Type: application/json
	Host: localhost:8080
	User-Agent: HTTPie/0.9.8
	
	{
	    "postId": "2",
	    "text": "After my class I am going to have a wonderful summer!"
	}
	
	HTTP/1.0 201 Created
	Content-Type: application/json
	Date: Wed, 05 May 2021 00:41:18 GMT
	Server: WSGIServer/0.2 CPython/3.6.9
	
	Successfully created keyword(s).


Test Search endpoint:
$ http --verbose GET http://localhost:8080/index/wonderful

	Output:
	GET /index/wonderful HTTP/1.1
	Accept: */*
	Accept-Encoding: gzip, deflate
	Connection: keep-alive
	Host: localhost:8080
	User-Agent: HTTPie/0.9.8
	
	
	
	HTTP/1.0 200 OK
	Content-Type: application/json
	Date: Wed, 05 May 2021 00:47:39 GMT
	Server: WSGIServer/0.2 CPython/3.6.9
	
	[
	    "2"
	]


Test Any endpoint:
$ http --verbose GET http://localhost:8080/index/any keywordList:='["class","microservice"]'

	Output:
	GET /index/any HTTP/1.1
	Accept: application/json, */*
	Accept-Encoding: gzip, deflate
	Connection: keep-alive
	Content-Length: 42
	Content-Type: application/json
	Host: localhost:8080
	User-Agent: HTTPie/0.9.8
	
	{
	    "keywordList": [
	        "class",
	        "microservice"
	    ]
	}
	
	HTTP/1.0 200 OK
	Content-Type: application/json
	Date: Wed, 05 May 2021 00:50:36 GMT
	Server: WSGIServer/0.2 CPython/3.6.9
	
	[
	    "0",
	    "1",
	    "2"
	]


Test All endpoint:
$ http --verbose GET http://localhost:8080/index/all keywordList:='["class","microservice"]'

	Output:
	GET /index/all HTTP/1.1
	Accept: application/json, */*
	Accept-Encoding: gzip, deflate
	Connection: keep-alive
	Content-Length: 42
	Content-Type: application/json
	Host: localhost:8080
	User-Agent: HTTPie/0.9.8
	
	{
	    "keywordList": [
	        "class",
	        "microservice"
	    ]
	}
	
	HTTP/1.0 200 OK
	Content-Type: application/json
	Date: Wed, 05 May 2021 00:50:46 GMT
	Server: WSGIServer/0.2 CPython/3.6.9
	
	[
	    "0",
	    "1"
	]


Test Exclude endpoint:
$ http --verbose GET http://localhost:8080/index/exclude includeList:='["class"]' excludeList:='["microservice"]'

	Output:
	GET /index/exclude HTTP/1.1
	Accept: application/json, */*
	Accept-Encoding: gzip, deflate
	Connection: keep-alive
	Content-Length: 59
	Content-Type: application/json
	Host: localhost:8080
	User-Agent: HTTPie/0.9.8
	
	{
	    "excludeList": [
	        "microservice"
	    ],
	    "includeList": [
	        "class"
	    ]
	}
	
	HTTP/1.0 200 OK
	Content-Type: application/json
	Date: Wed, 05 May 2021 00:54:10 GMT
	Server: WSGIServer/0.2 CPython/3.6.9
	
	[
	    "2"
	]


Other redis-cli commands...

Find value of a single key:
$ redis-cli get <key>

Return all keys in a non-blocking manner:
$ redis-cli --scan --pattern '*'

Flush all keys:
$ redis-cli flushdb

Delete specific key:
$ redis-cli del <key>