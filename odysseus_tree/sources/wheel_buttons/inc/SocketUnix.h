#ifndef SOCKETUNIX_H
#define SOCKETUNIX_H

#include <sys/socket.h>
#include <sys/un.h>

#define MAX_CLIENTS 8

typedef struct {
    int server_fd;
    int client_fds[MAX_CLIENTS];
    int num_clients;
    struct sockaddr_un addr;
} UnixSocketServer;

/** Create and bind the server socket. */
int  uss_init(UnixSocketServer *server, const char *socket_path);

/** Close all clients and the server socket, unlink the file. */
void uss_shutdown(UnixSocketServer *server);

/** Non-blocking accept — call once per main-loop iteration. */
void uss_accept_clients(UnixSocketServer *server);

/** Send a message to all connected clients. Returns how many received it. */
int  uss_broadcast(UnixSocketServer *server, const char *message);

#endif