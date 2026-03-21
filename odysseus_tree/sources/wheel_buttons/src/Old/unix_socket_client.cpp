#include "unix_socket_client.h"

UnixSocketClient::UnixSocketClient(const std::string& socket_path) : connected(false) {
    printf("Creating socket...\n");
    client_fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (client_fd == -1) {
        throw std::runtime_error("Failed to create socket");
    }

    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, socket_path.c_str(), sizeof(addr.sun_path) - 1);
}

UnixSocketClient::~UnixSocketClient() {
    disconnect();
}

void UnixSocketClient::connect() {
    if (connected) {
        printf("Already connected to server.\n");
        return;
    }

    printf("Connecting to server...\n");
    if (::connect(client_fd, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
        ::close(client_fd);
        client_fd = -1;
        throw std::runtime_error("Server connection failed");
    }

    connected = true;
    printf("Connected to server.\n");
}

void UnixSocketClient::disconnect() {
    if (client_fd != -1) {
        ::close(client_fd);
        client_fd = -1;
    }
    connected = false;
    printf("Disconnected from server.\n");
}

void UnixSocketClient::send(const std::string& message) {
    if (!connected) {
        throw std::runtime_error("Not connected to server");
    }

    printf(("Sending message: \"" + message + "\"...\n").c_str());
    ssize_t bytes_sent = ::send(client_fd, message.c_str(), message.length(), 0);
    if (bytes_sent < 0) {
        connected = false;
        throw std::runtime_error("Failed to send message: " + std::string(std::strerror(errno)));
    }
    printf("Message sent.\n");
}

std::string UnixSocketClient::receive() {
    if (!connected) {
        throw std::runtime_error("Not connected to server");
    }

    char buffer[BUFFER_SIZE];
    ssize_t bytes_read = recv(client_fd, buffer, BUFFER_SIZE - 1, 0);
    if (bytes_read < 0) {
        connected = false;
        throw std::runtime_error("Failed to receive message: " + std::string(std::strerror(errno)));
    } else if (bytes_read == 0) {
        connected = false;
        printf("Server closed the connection.\n");
        return "";
    }

    buffer[bytes_read] = '\0';
    return std::string(buffer);
}