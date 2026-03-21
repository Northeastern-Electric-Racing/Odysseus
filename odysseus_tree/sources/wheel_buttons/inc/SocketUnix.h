#ifndef SOCKET_UNIX_H
#define SOCKET_UNIX_H

#include <stddef.h>
#include <sys/socket.h>
#include <sys/un.h>

/* =========================
 * UNIX SOCKET SERVER
 * ========================= */

typedef struct {
    int server_fd;
    int client_fd;
    struct sockaddr_un addr;
} UnixSocketServer;

/**
 * Initialize the UNIX socket server.
 * Creates, binds, and starts listening.
 *
 * @param server Pointer to server struct
 * @param socket_path Path (e.g. "/tmp/wheel_buttons_socket")
 * @return 0 on success, -1 on error
 */
int uss_init(UnixSocketServer *server, const char *socket_path);

/**
 * Accept a client connection (blocking).
 *
 * @param server Pointer to server struct
 * @return 0 on success, -1 on error
 */
int uss_accept(UnixSocketServer *server);

/**
 * Disconnect current client.
 */
void uss_disconnect(UnixSocketServer *server);

/**
 * Cleanup server (close fds + remove socket file).
 *
 * @param server Pointer to server struct
 * @param socket_path Path used during init
 */
void uss_cleanup(UnixSocketServer *server, const char *socket_path);

/**
 * Send message to connected client.
 *
 * @param server Pointer to server struct
 * @param message Null-terminated string
 * @return 0 on success, -1 on error
 */
int uss_send(UnixSocketServer *server, const char *message);

/**
 * Receive message from client.
 *
 * @param server Pointer to server struct
 * @param buffer Output buffer
 * @param buffer_size Size of buffer
 * @return number of bytes read, 0 if disconnected, -1 on error
 */
int uss_receive(UnixSocketServer *server, char *buffer, size_t buffer_size);

#endif /* SOCKET_UNIX_H */
