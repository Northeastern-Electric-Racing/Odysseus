#include "siren_server.h"

#include <iostream>
#include <sstream>
#include <unistd.h>

namespace http {
	SirenServer::SirenServer(std::string ip, int port) 
		: m_socket(), new_socket(), m_socketAddress(), m_socketAddress_len()
	{
		m_socketAddress.sin_family = AF_INET;
		m_socketAddress.sin_port = htons(port);
		m_socketAddress.sin_addr.s_addr = inet_addr(ip.c_str());

		m_socketAddress_len = sizeof(m_socketAddress);

		startServer();
	}

	SirenServer::~SirenServer() {
		close(m_socket);
		exit(0);
	}

	void SirenServer::startServer() {
		m_socket = socket(AF_INET, SOCK_STREAM, 0);
		if (m_socket < 0) {
			// TODO: log error
			exit(1);
		}

		if (bind(m_socket, (sockaddr*) &m_socketAddress, m_socketAddress_len)) {
			// TODO: log error
			exit(1);
		}
	}

	void SirenServer::startListen() {
		if (listen(m_socket, 1)) {
			// TODO: log error
			exit(1);
		}

		while (true) {
			
			acceptConnection(new_socket);
			
			char buffer[BUFFER_SIZE] = {0};

			bytesRecieved = read(new_socket, buffer, BUFFER_SIZE);
			if (bytesRecieved < 0) {
				// TODO: log error
				exit(1);
			}

			// TODO: print buffer

			sendMessage();
		}
	}

	void SirenServer::acceptConnection(SOCKET &new_socket) {
		new_socket = accept(m_socket, (sockaddr*)&m_socketAddress, &m_socketAddress_len);

		if (new_socket < 0) {
			// TODO: log error
			exit(1);
		}
	}

	void SirenServer::sendMessage() {
		
		std::string body = "<!DOCTYPE html><html lang=\"en\"><body><h1> HOME </h1><p> Hello from your Server :) </p></body></html>";

		std::ostringstream response;
		response << "HTTP/1.1 200 OK\nContent-Type: text/html\nContent-Length: " << body.size() << "\n\n" << body;

		long bytesSent = write(new_socket, response.str().c_str(), response.str().size());

		if (bytesSent != response.str().size()) {
			// TODO: log error
			exit(1);
		}
	}
}