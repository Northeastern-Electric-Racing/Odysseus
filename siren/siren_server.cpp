#include "siren_server.h"

#include <iostream>
#include <sstream>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <openssl/sha.h>
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
		err = acceptConnection(&newSocket);
		if (err)
			return err;
		
		char* buffer = new char[BUFFER_SIZE];

		int bytesReceived = read(newSocket, buffer, BUFFER_SIZE);
		if (bytesReceived <= 0) {
			perror("read");
			return bytesReceived;
		}

		std::cout << "read: " << bytesReceived << "::" << buffer << std::endl;
		parseSocketKey("dGhlIHNhbXBsZSBub25jZQ==");
		// err = sendMessage(newSocket);
		// if (err)
		// 	return err;
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

int NER::SirenServer::sendMessage(socket socket)
{

	std::ostringstream handshake;
	handshake << "HTTP/1.1 200 OK\nUpgrade: websocket\nConnection: Upgrade\n" << 0 << "\n\n";

	long hbytesSent = write(socket, handshake.str().c_str(), handshake.str().size());

	if (hbytesSent != handshake.str().size()) {
		perror("Incorrect response");
		return -1;
	}

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
	const unsigned char* input = reinterpret_cast<const unsigned char *> ((key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11").c_str());

	unsigned char* hash = new unsigned char[SHA_DIGEST_LENGTH];

	SHA1(input, sizeof(input), hash);

	std::cout << sizeof(input) << "and" << hash << std::endl;

	return "h";
}