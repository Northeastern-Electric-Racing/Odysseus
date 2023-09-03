#ifndef SIREN_SERVER_H
#define SIREN_SERVER_H

#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <string>
#include <map>

namespace NER {

typedef int socket;

class Connection {
	public:
		Connection();
		~Connection();
	private:
		socket m_socket;
};

class SirenServer {
public:
	SirenServer(std::string ip, int port);
	~SirenServer();

	int startServer();
	int startListen();
	int stopListen();
	int sendMessage(socket socket);

private:
	static const int BUFFER_SIZE = 30720;

	//std::map<std::string, Connection> connections;
	int opt = 1;

	int serverFile;
	sockaddr_in socketAddress;
	uint socketAddressLen;

	int acceptConnection(socket *newSocket);
	std::string parseSocketKey(std::string key);
};

} // NER

#endif // SIREN_SERVER_H
