#include "SocketUnix.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>

int usc_init(UnixSocketClient *client, const char *socket_path)
{
    client->client_fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (client->client_fd == -1) {
        perror("socket(UNIX)");
        return -1;
    }

    memset(&client->addr, 0, sizeof(struct sockaddr_un));
    client->addr.sun_family = AF_UNIX;
    strncpy(client->addr.sun_path, socket_path,
            sizeof(client->addr.sun_path) - 1);

    client->connected = 0;
    return 0;
}

int usc_connect(UnixSocketClient *client)
{
    if (client->connected) {
        printf("Already connected to server.\n");
        return 0;
    }

    printf("Connecting to UNIX socket server...\n");

    if (connect(client->client_fd,
                (struct sockaddr *)&client->addr,
                sizeof(struct sockaddr_un)) == -1) {
        perror("connect(UNIX)");
        close(client->client_fd);
        client->client_fd = -1;
        return -1;
    }

    client->connected = 1;
    printf("Connected to server.\n");
    return 0;
}

void usc_disconnect(UnixSocketClient *client)
{
    if (client->client_fd != -1) {
        close(client->client_fd);
        client->client_fd = -1;
    }
    client->connected = 0;
}

int usc_send(UnixSocketClient *client, const char *message)
{
    if (!client->connected) {
        fprintf(stderr, "UNIX socket: not connected\n");
        return -1;
    }

    ssize_t bytes_sent = send(client->client_fd, message, strlen(message), 0);
    if (bytes_sent < 0) {
        perror("send(UNIX)");
        client->connected = 0;
        return -1;
    }

    return 0;
}

int usc_receive(UnixSocketClient *client, char *buffer, size_t buffer_size)
{
    if (!client->connected) {
        fprintf(stderr, "UNIX socket: not connected\n");
        return -1;
    }

    ssize_t bytes_read = recv(client->client_fd, buffer, buffer_size - 1, 0);
    if (bytes_read < 0) {
        perror("recv(UNIX)");
        client->connected = 0;
        return -1;
    }

    if (bytes_read == 0) {
        printf("Server closed the connection.\n");
        client->connected = 0;
        return 0;
    }

    buffer[bytes_read] = '\0';
    return (int)bytes_read;
}