#!/usr/bin/env sage 
import socket

def connect_server(server_name, port, message):
    server = (server_name, int(port)) #calling int is required when using Sage
    s = socket.create_connection(server)
    s.send(message + "\n")
    response=""
    while True: #data might come in several packets, need to wait for all of it
        data = s.recv(1024)
        if len(data) == 0:
        	break
        if data[-1] == '\n': 
        	response += data[:-1]  
        	break
        response += data
    s.close()
    return response

def encryption_query(sciper, pt):
    server_name = "lasecpc25.epfl.ch"
    port = "5559"
    message = sciper + " " + pt
    response = connect_server(server_name, port, message)
    #print(response)
    return response