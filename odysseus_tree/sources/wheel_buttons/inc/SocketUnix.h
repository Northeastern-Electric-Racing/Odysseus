#ifndef NER_SOCKETUNIX_H
#define NER_SOCKETUNIX_H

#include <sys/un.h>

typedef struct {
    int fd;
    struct sockaddr_un dest;
} UnixSender;

/** Create a DGRAM socket aimed at dest_path. Fire-and-forget. */
int  uss_init(UnixSender *s, const char *dest_path);
void uss_shutdown(UnixSender *s);
int  uss_send(UnixSender *s, const char *msg, const size_t msg_len);

#endif
