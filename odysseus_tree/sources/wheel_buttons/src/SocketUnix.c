/**
 * @brief Unix socket server — binds, listens, accepts clients,
 *        and broadcasts button events to all connected clients.
 *        All fds are non-blocking.  Client acceptance is lazy:
 *        new clients are picked up each time we broadcast,
 *        so the server fd never needs to be polled.
 */

#include "SocketUnix.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

static int set_nonblocking(int fd)
{
    int flags = fcntl(fd, F_GETFL, 0);
    if (flags < 0) return -1;
    return fcntl(fd, F_SETFL, flags | O_NONBLOCK);
}

int uss_init(UnixSocketServer *server, const char *socket_path)
{
    unlink(socket_path);

    server->server_fd   = socket(AF_UNIX, SOCK_STREAM, 0);
    server->num_clients = 0;

    if (server->server_fd < 0) {
        perror("socket(UNIX)");
        return -1;
    }

    memset(&server->addr, 0, sizeof(struct sockaddr_un));
    server->addr.sun_family = AF_UNIX;
    strncpy(server->addr.sun_path, socket_path,
            sizeof(server->addr.sun_path) - 1);

    if (bind(server->server_fd,
             (struct sockaddr *)&server->addr,
             sizeof(struct sockaddr_un)) < 0) {
        perror("bind(UNIX)");
        close(server->server_fd);
        server->server_fd = -1;
        return -1;
    }

    if (listen(server->server_fd, MAX_CLIENTS) < 0) {
        perror("listen(UNIX)");
        close(server->server_fd);
        unlink(socket_path);
        server->server_fd = -1;
        return -1;
    }

    set_nonblocking(server->server_fd);

    printf("UNIX socket server listening on %s\n", socket_path);
    return 0;
}

void uss_shutdown(UnixSocketServer *server)
{
    for (int i = 0; i < server->num_clients; i++)
        close(server->client_fds[i]);
    server->num_clients = 0;

    if (server->server_fd >= 0) {
        close(server->server_fd);
        server->server_fd = -1;
    }

    unlink(server->addr.sun_path);
    printf("UNIX socket server shut down.\n");
}

static void accept_pending(UnixSocketServer *server)
{
    while (server->num_clients < MAX_CLIENTS) {
        int fd = accept(server->server_fd, NULL, NULL);
        if (fd < 0)
            break;

        set_nonblocking(fd);
        server->client_fds[server->num_clients++] = fd;
        printf("UNIX client connected (fd=%d, total=%d)\n",
               fd, server->num_clients);
    }
}

int uss_broadcast(UnixSocketServer *server, const char *message)
{
    /* Pick up any waiting clients before sending */
    accept_pending(server);

    size_t len = strlen(message);
    int sent   = 0;

    for (int i = 0; i < server->num_clients; ) {
        ssize_t n = send(server->client_fds[i], message, len, MSG_NOSIGNAL);

        if (n < 0) {
            if (errno == EAGAIN || errno == EWOULDBLOCK) {
                i++;
                continue;
            }
            printf("UNIX client disconnected (fd=%d)\n", server->client_fds[i]);
            close(server->client_fds[i]);
            server->client_fds[i] = server->client_fds[--server->num_clients];
        } else {
            sent++;
            i++;
        }
    }

    return sent;
}