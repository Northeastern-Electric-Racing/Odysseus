#include "SocketUnix.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <stddef.h>
#include <sys/socket.h>
#include <sys/un.h>

int uss_init(UnixSocketServer *server, const char *socket_path)
{
    server->server_fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (server->server_fd == -1) {
        perror("socket(UNIX)");
        return -1;
    }

    // Remove stale socket file
    unlink(socket_path);

    memset(&server->addr, 0, sizeof(struct sockaddr_un));
    server->addr.sun_family = AF_UNIX;

    snprintf(server->addr.sun_path,
             sizeof(server->addr.sun_path),
             "%s", socket_path);

    socklen_t len = offsetof(struct sockaddr_un, sun_path) +
                    strlen(server->addr.sun_path);

    if (bind(server->server_fd,
             (struct sockaddr *)&server->addr,
             len) == -1) {
        perror("bind(UNIX)");
        close(server->server_fd);
        return -1;
    }

    if (listen(server->server_fd, 5) == -1) {
        perror("listen");
        close(server->server_fd);
        return -1;
    }

    server->client_fd = -1;

    printf("UNIX socket server initialized at %s\n", socket_path);
    return 0;
}

int uss_accept(UnixSocketServer *server)
{
    printf("Waiting for client...\n");

    server->client_fd = accept(server->server_fd, NULL, NULL);
    if (server->client_fd == -1) {
        perror("accept");
        return -1;
    }

    printf("Client connected.\n");
    return 0;
}

void uss_disconnect(UnixSocketServer *server)
{
    if (server->client_fd != -1) {
        close(server->client_fd);
        server->client_fd = -1;
    }
}

void uss_cleanup(UnixSocketServer *server, const char *socket_path)
{
    uss_disconnect(server);

    if (server->server_fd != -1) {
        close(server->server_fd);
        server->server_fd = -1;
    }

    unlink(socket_path);
}

int uss_send(UnixSocketServer *server, const char *message)
{
    if (server->client_fd == -1) {
        fprintf(stderr, "No client connected\n");
        return -1;
    }

    ssize_t bytes_sent = send(server->client_fd,
                              message,
                              strlen(message),
                              0);

    if (bytes_sent < 0) {
        perror("send(UNIX)");
        return -1;
    }

    return 0;
}

int uss_receive(UnixSocketServer *server, char *buffer, size_t buffer_size)
{
    if (server->client_fd == -1) {
        fprintf(stderr, "No client connected\n");
        return -1;
    }

    ssize_t bytes_read = recv(server->client_fd,
                              buffer,
                              buffer_size - 1,
                              0);

    if (bytes_read < 0) {
        perror("recv(UNIX)");
        return -1;
    }

    if (bytes_read == 0) {
        printf("Client disconnected.\n");
        uss_disconnect(server);
        return 0;
    }

    buffer[bytes_read] = '\0';
    return (int)bytes_read;
}
