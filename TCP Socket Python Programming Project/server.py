import sys
import os
import socket
import cmds
import data_handling

HEADER_SIZE = data_handling.HEADER_SIZE

def main():
    # check correct number of arguments
    if len(sys.argv) < 2:
        print(f'USAGE: $ python {sys.argv[0]} <PORT NUMBER>')
        exit()

    # listening port
    server_port = sys.argv[1]

    # create a socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # bind socket to port
    server_socket.bind(('', int(server_port)))
    # start listening on socket
    server_socket.listen(1)

    # accept connections until interrupt (CTRL+C)
    while True:
        print('Waiting for connections...')

        # accept connection
        client_socket, client_addr = server_socket.accept()
        print(f'Accepted connection from client: {client_addr}')

        # keep connection open until client issues 'quit' command
        while True:
            # receive command header
            cmd_size = int(data_handling.receive_data(client_socket, HEADER_SIZE))
            # receive command
            cmd = data_handling.receive_data(client_socket, cmd_size)
            # split 'cmd' so that:
            #   cmd[0]: command
            #   cmd[1]: <FILE NAME> if exists
            cmd = cmd.split()

            # get command
            if cmd[0] == cmds.CMDS[0]:
                print(f'Executing command: {cmd[0]} {cmd[1]}...')
                check = cmds.server_get(client_socket, cmd[1])
                # check if download successful
                if check:
                    print(f'Client successfully downloaded {cmd[1]} from server')
                else:
                    print(f'{cmd[1]} does not exist')
            # put command
            elif cmd[0] == cmds.CMDS[1]:
                print(f'Executing command: {cmd[0]} {cmd[1]}...')
                check = cmds.server_put(client_socket, cmd[1])
                # check if download successful
                if check:
                    print(f'Client successfully uploaded {cmd[1]} to server')
                else:
                    print(f'{cmd[1]} does not exist')
            # ls command
            elif cmd[0] == cmds.CMDS[2]:
                print(f'Executing command: {cmd[0]}...')
                cmds.server_ls(client_socket)
                print('Client successfully received list of files in server')
            # quit command
            elif cmd[0] == cmds.CMDS[3]:
                print(f'Executing command: {cmd[0]}...')
                print('Client disconnected')
                break

        # close socket
        client_socket.close()

if __name__ == '__main__':
    main()
