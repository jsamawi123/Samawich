'''
helper functions for handling incoming or outgoing data
'''

HEADER_SIZE = 10

def receive_data(sock, num_bytes):
    '''
    return the received num_bytes of data obtained from socket
    '''
    # buffer
    receive_buffer = ''
    # temp buffer
    temp_buffer = ''

    # receive until num_bytes is received
    while len(receive_buffer) < num_bytes:
        temp_buffer = sock.recv(num_bytes)

        # check if other side closed the socket
        if not temp_buffer:
            break

        # decode and add received bytes to buffer
        receive_buffer += temp_buffer.decode()

    return receive_buffer

def send_data(sock, data):
    '''
    send data from socket
    '''
    # get size of data as string
    data_size = str(len(data))

    # add 0's to data_size until 10 bytes
    while len(data_size) < HEADER_SIZE:
        data_size = '0' + data_size

    # add data_size header to data
    data = data_size + data

    # send data until no data is left
    bytes_sent = 0
    while len(data) > bytes_sent:
        bytes_sent += sock.send(data[bytes_sent:].encode())

def send_file(sock, file):
    '''
    send file from socket
    '''
    # send data until all is sent
    while True:
        data = file.read()

        # check if EOF
        if data:
            send_data(sock, data)
        else:
            return
