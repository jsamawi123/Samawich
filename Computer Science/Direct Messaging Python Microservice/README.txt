Project 5 CPSC 449-01 Direct Messaging (DM) Microservice using Dynamodb
Author: James Samawi (jsamawi@csu.fullerton.edu) 893474445

Misc. files required to run program: createTable.py, etc/logging.ini, etc/directMsg.ini, /var/log/api.log



Must have installed Dynamodb Local and JRE installed, as well as AWS CLI and configured it. It is assumed the Bottle framework is already installed also.

Install dependancy:
$ sudo apt install --yes python3-boto3

Ensure the local database is running (on port 8000) by executing the following command within the Dynamodb directory:
$ java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb

To test the web service (from within the project directory), start by creating the DirectMessages table and inserting items:
$ python3 createTable.py
- note: executing this script once more will delete the preexisting table.

Then start the miroservice server on port 8080:
$ foreman start



Start testing the microservice with the following four API calls...

listDirectMessagesFor(username):
- Lists a user's DMs.
$ http --verbose GET http://localhost:8080/users/Foo/directMessages/

listRepliesTo(messageId):
- Lists the replies to a DM.
$ http --verbose GET http://localhost:8080/users/Foo/directMessages/54d407bb-2daf-48ad-96a8-2149477dcafd/

sendDirectMessage(to, from, message, quickReplies=None):
- Sends a DM to a user. The API call may or may not include a list of quickReplies.
$ http --verbose POST http://localhost:8080/users/Foo/directMessages/ from=Bar message="Hello World!" quickReplies:='["Hi", "Hello", "(:"]'

replyToDirectMessage(messageId, message): 
- Replies to a DM. The message may either be text or a quick-reply number. If the message parameter is a quick-reply number, it must have been in response to a messageId that included a quick-replies field.
$ http --verbose POST http://localhost:8080/users/Bar/directMessages/54d407bb-2daf-48ad-96a8-2149477dcafd/ message=1



If you wish to start with an empty table, comment the last line of createTable.py, save, and run the script once more. 

To manually insert the original items into the empty table using the DM microservice, follow these steps:
$ http --verbose POST http://localhost:8080/users/Bar/directMessages/ from=Foo message="Hey Mr. Bar! I have a question."
(copy the messageId field!) $ http --verbose GET http://localhost:8080/users/Bar/directMessages/ 
$ http --verbose POST http://localhost:8080/users/Bar/directMessages/<messageId>/ message="Hello Foo! What's on your mind?"
$ http --verbose POST http://localhost:8080/users/Bar/directMessages/ from=Foo message="By any chance, are you free for lunch tomorrow?" quickReplies:='["Yes", "No", "Call me"]'
(copy the messageId field!) $ http --verbose GET http://localhost:8080/users/Bar/directMessages/ 
$ http --verbose POST http://localhost:8080/users/Bar/directMessages/<messageId>/ message=1
$ http --verbose POST http://localhost:8080/users/Bar/directMessages/ from=Foo message="Oh... Well that is okay, maybe next time!"
(copy the messageId field!) $ http --verbose GET http://localhost:8080/users/Bar/directMessages/ 
$ http --verbose POST http://localhost:8080/users/Bar/directMessages/<messageId>/ message="Totally! Maybe after my midterm tomorrow we can try."



Optional Terminal Commands

To validate the table is created on the local Dynamodb:
$ aws dynamodb list-tables --endpoint-url http://localhost:8000

To view the contents of the table:
$ aws dynamodb scan --table-name DirectMessages --endpoint-url http://localhost:8000

To delete the existing table:
$ aws dynamodb delete-table --table-name DirectMessages --endpoint-url http://localhost:8000