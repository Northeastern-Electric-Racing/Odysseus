#include "siren_server.h"

#include <iostream>
#include <sstream>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <openssl/sha.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>
#include <cstring>

NER::SirenServer::SirenServer(std::string ip, int port)
{
	socketAddress.sin_family = AF_INET;
	socketAddress.sin_port = htons(port);
	socketAddress.sin_addr.s_addr = inet_addr(ip.c_str());
	socketAddressLen = sizeof(socketAddress);
}

NER::SirenServer::~SirenServer()
{
	close(serverFile);
}

int NER::SirenServer::startServer()
{
	int err;

	serverFile = ::socket(AF_INET, SOCK_STREAM, 0);
	if(serverFile < 0) {
		perror("init socket");
		return serverFile;
	}

	err = setsockopt(serverFile, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT,
				   &opt, sizeof(opt));
	if (err) {
        perror("setsockopt");
        return err;
    }

	err = bind(serverFile, (struct sockaddr*) &socketAddress, socketAddressLen);
	if (err) {
		perror("bind");
		return err;
	}

	return 0;
}

int NER::SirenServer::startListen()
{
	int err;
	socket newSocket;

	err = listen(serverFile, 1);
	if (err) {
		perror("listen");
		return err;
	}

	while (true) {
		std::cout << "looking for connection" << std::endl;
		err = acceptConnection(&newSocket);
		if (err)
			return err;
		
		char buffer[BUFFER_SIZE];

		std::size_t bytesReceived = read(newSocket, buffer, BUFFER_SIZE);
		if (bytesReceived <= 0) {
			perror("read");
			return bytesReceived;
		}

		std::cout << buffer << std::endl;

		std::string keyHeaderKey = "Sec-WebSocket-Key: ";
		std::size_t index = ((std::string) buffer).find(keyHeaderKey);

		if (index == std::string::npos) {
			perror("invalid handshake");
			return index;
		}

		index += keyHeaderKey.length();

		std::string key = ((std::string) buffer).substr(index, 24); // TODO: make 24 a constant

		std::string acceptValue = parseSocketKey(key);

		err = handshake(newSocket, acceptValue);
		if (err) {
			return err;
		}

		// err = sendMessage(newSocket);
		// if (err)
		// 	return err;

		std::cout << "receiving" << std::endl;

		char newbuffer[BUFFER_SIZE];

		bytesReceived = read(newSocket, newbuffer, BUFFER_SIZE);

		std::cout << newbuffer << std::endl;
	}

	return 0;
}

int NER::SirenServer::acceptConnection(socket *newSocket)
{
	*newSocket = accept(serverFile, (struct sockaddr*) &socketAddress, &socketAddressLen);

	if (*newSocket < 0) {
		perror("accept");
		return *newSocket;
	}

	return 0;
}

int NER::SirenServer::handshake(socket socket, std::string acceptValue)
{

	std::ostringstream handshake;
	handshake << "HTTP/1.1 101 Switching Protocols\nUpgrade: websocket\nConnection: Upgrade\nSec-WebSocket-Accept: " << acceptValue << "\n\n";

	long bytesSent = write(socket, handshake.str().c_str(), handshake.str().size());

	if (bytesSent != handshake.str().size()) {
		perror("Incorrect response");
		return -1;
	}

	return 0;
}

int NER::SirenServer::sendMessage(socket socket)
{

	std::string body = "<!DOCTYPE html><html lang=\"en\"><body><h1> HOME </h1><p> Hello from your Server :) </p></body></html>";

	std::ostringstream response;
	response << "HTTP/1.1 200 OK\nContent-Type: text/html\nContent-Length: " << body.size() << "\n\n" << body;

	long bytesSent = write(socket, response.str().c_str(), response.str().size());

	if (bytesSent != response.str().size()) {
		perror("Incorrect response");
		return -1;
	}

	return 0;
}

std::string NER::SirenServer::parseSocketKey(std::string key)
{
	std::string input = key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

	char* cinput = new char[input.length() + 1];
	cinput = std::strcpy(cinput, input.c_str());

	unsigned char* ucinput = reinterpret_cast<unsigned char*>(cinput);

	unsigned char* hash = new unsigned char[SHA_DIGEST_LENGTH];

	SHA1(ucinput, strlen(cinput), hash);

	BIO* b64 = BIO_new(BIO_f_base64());
	BIO* bio = BIO_new(BIO_s_mem());
	BIO_push(b64, bio);
	BIO_write(b64, (char*) hash, strlen((char*) hash));
	BIO_flush(b64);
	
	BUF_MEM *bptr;
	BIO_get_mem_ptr(bio, &bptr);
	BIO_set_close(bio, BIO_NOCLOSE);

	BIO_free_all(b64);

	return bptr->data;
}