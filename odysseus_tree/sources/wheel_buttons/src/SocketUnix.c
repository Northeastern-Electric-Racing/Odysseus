#include "SocketUnix.h"

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>

int uss_init(UnixSender *s, const char *dest_path)
{
    s->fd = socket(AF_UNIX, SOCK_DGRAM, 0);
    if (s->fd < 0) { perror("socket(UNIX)"); return -1; }

    memset(&s->dest, 0, sizeof(s->dest));
    s->dest.sun_family = AF_UNIX;
    strncpy(s->dest.sun_path, dest_path,
            sizeof(s->dest.sun_path) - 1);

    printf("UNIX datagram sender ready -> %s\n", dest_path);
    return 0;
}

void uss_shutdown(UnixSender *s)
{
    if (s->fd >= 0) close(s->fd);
    s->fd = -1;
}

int uss_send(UnixSender *s, const char *msg)
{
    ssize_t n = sendto(s->fd, msg, strlen(msg), MSG_NOSIGNAL,
                       (struct sockaddr *)&s->dest,
                       sizeof(s->dest));
    if (n < 0 && errno != ENOENT && errno != ECONNREFUSED)
        perror("sendto(UNIX)");

    return (n >= 0) ? 0 : -1;
}