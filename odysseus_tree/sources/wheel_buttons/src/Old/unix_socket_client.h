#pragma once

#include <unistd.h>
#include <iostream>
#include <cstring>
#include <string>
#include <stdexcept>

#include <sys/socket.h>
#include <sys/un.h>

#include "connection/config.h"

/**
 * @brief A simple Unix domain socket client for sending and receiving messages.
 * 
 */
class UnixSocketClient {
private:
    int client_fd;
    struct sockaddr_un addr;
    bool connected;

public:
    UnixSocketClient(const std::string& socket_path);
    ~UnixSocketClient();

    // need to prevent copying
    UnixSocketClient(const UnixSocketClient&) = delete;
    UnixSocketClient& operator=(const UnixSocketClient&) = delete;

    void connect();
    void disconnect();
    void send(const std::string& message);
    std::string receive();

    bool is_connected() const noexcept { return connected; };
};