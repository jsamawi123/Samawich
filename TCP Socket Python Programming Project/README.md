# CPSC 471 Programming Assignment #

#### Team Members: ###
- Justin Do (justinkhado@csu.fullerton.edu)
- Damien Mousavi (kahrenmousavi@csu.fullerton.edu)
- James Samawi (jsamawi@csu.fullerton.edu)

#### Programming Language: ###
- Python

#### How to execute: ###f
In a Linux environment:

1. Navigate to directory in terminal

2. Run server
   `$ python server.py <SERVER PORT>`
   ex. `$ python server.py 1234`

3. Run client
   `$ python client.py <SERVER MACHINE> <SERVER PORT>`
   ex. `$ python client.py localhost 1234`

4. If client successfully connects to server, client will print `ftp>`

5. User can input following commands into client:
    - `ftp> get <FILE NAME>`   : downloads file <FILE NAME> from the server
    - `ftp> put <FILE NAME>`   : uploads file <FILE NAME> to the server
    - `ftp> ls`                : lists files on the server
    - `ftp> quit`              : disconnects from the server and exits


NOTE: - The client and server's root directory are /client_files and /server_files respectively. For more info and adjustments see code comments.
      - After client disconnects from server, server will wait for new connection.
      - User can KeyboardInterrupt (CTRL+C) or force close to stop the server.
