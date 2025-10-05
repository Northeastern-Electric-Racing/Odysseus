#include <unistd.h>
#include <iostream>
#include <cstring>
#include <string>

#include <sys/socket.h>
#include <sys/un.h>

#include "util/logging.h"

#define SOCKET_PATH "/tmp/wheel_buttons_socket"
#define BUFFER_SIZE 256

// socket sender
int main(void) {
    
    int client_fd;
    struct sockaddr_un server_addr;
    char buffer[BUFFER_SIZE];

    // create socket
    log_info("Creating socket...\n");
    client_fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (client_fd == -1) {
        log_error("Failed to create socket\n");
        return 1;
    }
    log_info("Socket created.\n");

    // set up server address
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sun_family = AF_UNIX;
    strncpy(server_addr.sun_path, SOCKET_PATH, sizeof(server_addr.sun_path) - 1);

    // connect to server
    log_info("Connecting to server...\n");
    if (connect(client_fd, (struct sockaddr*)&server_addr, sizeof(server_addr)) == -1) {
        log_error("Failed to connect to server\n");
        close(client_fd);
        return 1;
    }
    log_info("Connected to server.\n");

    // send messages
    std::string button;
    while (true) {
        std::cout << "> ";
        std::getline(std::cin, button);

        if (button == "exit") {
            break;
        }

        log_info(("Sending message: \"" + button + "\"...\n").c_str());
        if (send(client_fd, button.c_str(), button.size(), 0) == -1) {
            log_error("Failed to send message\n");
            break;
        }
        log_info("Message sent.\n");

        // receive acknowledgment
        log_info("Waiting for server ACK...\n");
        ssize_t bytes_read = recv(client_fd, buffer, BUFFER_SIZE - 1, 0);
        if (bytes_read > 0) {
            buffer[bytes_read] = '\0';
            log_info(("Server Response: \"" + std::string(buffer) + "\"\n").c_str());
        }
    }

    close(client_fd);
    log_info("Socket closed. Exiting.\n");
    
    return 0;
}