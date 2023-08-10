#ifndef INCLUDED_SERVER
#define INCLUDED_SERVER

#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <string>

namespace http {

	class SirenServer {
	public:
		SirenServer(std::string ip, int port);
		~SirenServer();

	private:
		const int BUFFER_SIZE = 30720;

		SOCKET m_socket;
		SOCKET new_socket;
		sockaddr_in m_socketAddress;
		unsigned int m_socketAddress_len;
		
		void startServer();
		void startListen();
		void stopListen();
		void acceptConnection(SOCKET &new_socket);
		void sendMessage();
	};
}

#endif
