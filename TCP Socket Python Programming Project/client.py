import sys
import socket
import cmds
import data_handling

def execute_cmd(cmd, sock):
    '''
    executes given command from client
    Params:
        cmd: [command, file name (if exists)]
        sock: socket
    '''
    # get command
    if cmd[0] == cmds.CMDS[0]:
        try:
            cmds.client_get(sock, cmd[1])
        except:
            print(f'USAGE: ftp> get <FILE NAME>')
            return
    # put command
    elif cmd[0] == cmds.CMDS[1]:
        # check file name
        if len(cmd) > 2:
            print('Make sure file name has no spaces')
            return
        try:
            cmds.client_put(sock, cmd[1])
        except:
            print(f'USAGE: ftp> put <FILE NAME>')
            return
    # ls command
    elif cmd[0] == cmds.CMDS[2]:
        cmds.client_ls(sock)
    # quit command
    elif cmd[0] == cmds.CMDS[3]:
        cmds.client_quit(sock)

def main():
    # check correct number of arguments
    if len(sys.argv) < 3:
        print(f'USAGE: $ python {sys.argv[0]} <SERVER MACHINE> <SERVER PORT>')
        exit()

    # server address
    server_addr = sys.argv[1]
    # server port
    server_port = sys.argv[2]

    # create a socket
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # connect to server
    client_socket.connect((server_addr, int(server_port)))

    # loop until user enters 'exit' command
    while True:
        cmd = input('ftp> ')
        # check empty input
        if not cmd:
            continue
        # check file name
        if len(cmd.split()) > 2:
            print('Make sure file name has no spaces')
            continue

        # send command to server
        data_handling.send_data(client_socket, cmd)

        # split 'cmd' into list:
        #   cmd[0]: command
        #   cmd[1]: <FILE NAME> if exists
        cmd = cmd.split()

        # execute command
        if cmd[0] in cmds.CMDS:
            execute_cmd(cmd, client_socket)
        # invalid command check
        else:
            print(
                f'Invalid command: \'{cmd[0]}\'\n'
                f'Available commands: {cmds.CMDS}'
            )

if __name__ == '__main__':
    main()
