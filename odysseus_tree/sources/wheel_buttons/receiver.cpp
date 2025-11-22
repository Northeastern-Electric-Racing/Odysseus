#include <iostream>
#include <cstring>
#include <string>
#include <csignal>
#include <cstdint>

#include <unistd.h>

#include <sys/socket.h>
#include <sys/un.h>

/**
 * @note    this is just a test script; only works in unix. i just compiled it
 *          using g++ and did not include it in cmake since it is not part of
 *          the production code. to test this locally, you need to comment out
 *          all pigpio includes/function in main.cpp AND in CMakeLists.txt.
 */
int main() {
    printf("Starting receiver...\n");

    const char *socket_path = "/tmp/wheel_buttons_socket";
    const int buffer_size = 256;

    unlink(socket_path); // this deletes the old path

    // create new socket
    int server_fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (server_fd==-1) { 
        return 1; 
    }

    // bind the socket to `socket_path`
    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX; // this sets the unix family
    strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path) - 1);
    if (bind(server_fd, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
        close(server_fd);
        return 1;
    }

    // enable listening
    if (listen(server_fd, 1) == -1) {
        close(server_fd);
        return 1;
    }
    printf("listening on path: %s\n", socket_path);
    
    // main loop
    bool running = true;
    while (running) {
        // await client connection
        printf("Waiting for connection...\n");
        int client_fd = accept(server_fd, nullptr, nullptr);
        if (client_fd==-1) {
            continue;
        }
        printf("Client connected\n");

        // communication loop
        char buffer[buffer_size];
        while (true) {
            ssize_t n_bytes = read(client_fd, buffer, buffer_size - 1);
            if (n_bytes > 0) {
                buffer[n_bytes] = '\0'; // need to manually terminate byte array
                printf("Received: %s\n", buffer);
            } else if (n_bytes == 0) {
                printf("Client disconnected\n");
                break;
            }
        }

        // clean up
        close(client_fd);
    }

    close(server_fd);
    unlink(socket_path);

    return 0;
}