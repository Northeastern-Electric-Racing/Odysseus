/**
 * @brief CAN socket helper — init + send button events.
 */

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
    struct sockaddr_can addr;
    struct ifreq ifr;
    int s;

    s = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (s < 0) {
        perror("socket(CAN)");
        return -1;
    }

    strncpy(ifr.ifr_name, ifname, IFNAMSIZ - 1);
    ifr.ifr_name[IFNAMSIZ - 1] = '\0';

    if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
        perror("ioctl(SIOCGIFINDEX)");
        close(s);
        return -1;
    }

    memset(&addr, 0, sizeof(addr));
    addr.can_family  = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("bind(CAN)");
        close(s);
        return -1;
    }

    return s;
}

int can_send_button_event(int can_socket, const ButtonMapping *btn, int pressed)
{
    struct can_frame frame;

    memset(&frame, 0, sizeof(frame));
    frame.can_id  = btn->can_id;
    frame.can_dlc = 2;
    frame.data[0] = (uint8_t)btn->gpio;
    frame.data[1] = pressed ? 1 : 0;

    if (write(can_socket, &frame, sizeof(frame)) != sizeof(frame)) {
        perror("write(CAN)");
        return -1;
    }

    return 0;
}