import os
import data_handling

HEADER_SIZE = data_handling.HEADER_SIZE

# ******************************************************************************
# Available commands
# ******************************************************************************
CMDS = ('get', 'put', 'ls', 'quit')

# ******************************************************************************
# File directories
# ******************************************************************************
package_dir = os.path.dirname(os.path.abspath(__file__))
CLIENT_FILES_DIR = os.path.join(package_dir, 'client_files')
SERVER_FILES_DIR = os.path.join(package_dir, 'server_files')


# ******************************************************************************
# Client commands
#   - command responses from client socket
# ******************************************************************************
def client_get(sock, file_name):
    '''
    downloads file from server to client
    '''
    # receive valid file indicator from server
    file_check_size = int(data_handling.receive_data(sock, HEADER_SIZE))
    file_check = data_handling.receive_data(sock, file_check_size)

    # check if file in server_files
    if file_check == '/FileNotFound':
        print(f'{file_name} does not exist in server')
        data_handling.send_data(sock, '/FileNotFound')
        return

    # get file size
    file_size = int(data_handling.receive_data(sock, HEADER_SIZE))

    print(f'Downloading {file_name} (Size: {file_size} B) from server...')

    # receive file data
    file_data = data_handling.receive_data(sock, file_size)

    # create file with received data in client_files directory
    file_path = os.path.join(CLIENT_FILES_DIR, file_name)
    file = open(file_path, 'w')
    file.write(file_data)
    file.close()

    print(f'Succesfully downloaded {file_name} from server')

def client_put(sock, file_name):
    '''
    uploads file to the server from client
    '''
    # client_files list
    client_files = dir_list = os.listdir(CLIENT_FILES_DIR)
    # check if file in cient_files
    if file_name not in client_files:
        print(f'{file_name} does not exist in client')
        data_handling.send_data(sock, '/FileNotFound')
        return
    else:
        data_handling.send_data(sock, '/ValidFile')

    print(f'Uploading {file_name} to server...')

    # open file from client_files
    file = open(os.path.join(CLIENT_FILES_DIR, file_name), 'r')
    # send file to server
    data_handling.send_file(sock, file)

    print(f'Successfully uploaded {file_name} to server')

def client_ls(sock):
    '''
    lists files on server
    '''
    files_list_size = int(data_handling.receive_data(sock, HEADER_SIZE))
    files_list = data_handling.receive_data(sock, files_list_size)
    for file in files_list.split('/'):
        print(file)

def client_quit(sock):
    '''
    disconnects from server and exits
    '''
    sock.close()
    exit()

# ******************************************************************************
# Server commands
#   - command responses from server socket
# ******************************************************************************
def server_get(sock, file_name):
    '''
    downloads file from server to client
    '''
    # check if file in server_files
    if file_name not in os.listdir(SERVER_FILES_DIR):
        data_handling.send_data(sock, '/FileNotFound')
        return 0
    else:
        data_handling.send_data(sock, '/ValidFile')

    # open file from server_files
    file = open(os.path.join(SERVER_FILES_DIR, file_name), 'r')
    # send file to client
    data_handling.send_file(sock, file)

    return 1

def server_put(sock, file_name):
    '''
    uploads file to server from client
    '''
    # receive valid file indicator from client
    file_check_size = int(data_handling.receive_data(sock, HEADER_SIZE))
    file_check = data_handling.receive_data(sock, file_check_size)

    # check if file in client_files
    if file_check == '/FileNotFound':
        return 0

    # receive file size from client
    file_size = int(data_handling.receive_data(sock, HEADER_SIZE))
    # receive file from client
    file_data = data_handling.receive_data(sock, file_size)

    # create file with received data in server_files directory
    file_path = os.path.join(SERVER_FILES_DIR, file_name)
    file = open(file_path, 'w')
    file.write(file_data)
    file.close()

    return 1

def server_ls(sock):
    '''
    lists files on server
    '''
    dir_list = os.listdir(SERVER_FILES_DIR)
    dir_list_str = '/'.join(dir_list)
    data_handling.send_data(sock, dir_list_str)
