#include "SocketCan.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <linux/can.h>
#include <linux/can/raw.h>

int can_init(const char *ifname)
{
    int s = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (s < 0) { perror("socket(CAN)"); return -1; }

    struct ifreq ifr;
    strncpy(ifr.ifr_name, ifname, IFNAMSIZ - 1);
    ifr.ifr_name[IFNAMSIZ - 1] = '\0';

    if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
        perror("ioctl"); close(s); return -1;
    }

    struct sockaddr_can addr = { .can_family  = AF_CAN,
                                 .can_ifindex = ifr.ifr_ifindex };
    if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("bind(CAN)"); close(s); return -1;
    }
    return s;
}

int can_send(int sock, const ButtonMapping *btn, int pressed)
{
    struct can_frame frame = {
        .can_id  = CAN_ID,
        .can_dlc = 2,
        .data    = { btn->index, pressed ? 1 : 0 },
    };

    if (write(sock, &frame, sizeof(frame)) != sizeof(frame)) {
        perror("write(CAN)");
        return -1;
    }
    return 0;
}