#ifndef UNIX_SOCKET_CLIENT_H
#define UNIX_SOCKET_CLIENT_H

#include <sys/socket.h>
#include <sys/un.h>

#define BUFFER_SIZE 1024

typedef struct {
    int client_fd;
    int connected;
    struct sockaddr_un addr;
} UnixSocketClient;

int usc_init(UnixSocketClient *client, const char *socket_path);
int usc_connect(UnixSocketClient *client);
void usc_disconnect(UnixSocketClient *client);
int usc_send(UnixSocketClient *client, const char *message);
int usc_receive(UnixSocketClient *client, char *buffer, size_t buffer_size);

#endif