/**
 * Build:  gcc -o wheel_buttons main.c SocketCan.c SocketUnix.c -lgpiod
 *
 * vcan setup:
 *   sudo modprobe vcan
 *   sudo ip link add dev vcan0 type vcan
 *   sudo ip link set up vcan0
 *
 * Monitor CAN:   candump vcan0
 * Monitor UNIX:  socat UNIX-RECVFROM:/tmp/wheel_buttons_socket,fork -
 */

#include "config.h"
#include "SocketCan.h"
#include "SocketUnix.h"

#include <errno.h>
#include <gpiod.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static struct gpiod_line_request *request_buttons(unsigned int *offsets,
                                                  unsigned int n)
{
    struct gpiod_chip *chip           = gpiod_chip_open(CHIP_PATH);
    struct gpiod_line_settings *set   = NULL;
    struct gpiod_line_config *lcfg    = NULL;
    struct gpiod_request_config *rcfg = NULL;
    struct gpiod_line_request *req    = NULL;

    if (!chip) { perror("gpiod_chip_open"); return NULL; }

    set  = gpiod_line_settings_new();
    lcfg = gpiod_line_config_new();
    rcfg = gpiod_request_config_new();
    if (!set || !lcfg || !rcfg) goto out;

    gpiod_line_settings_set_direction(set, GPIOD_LINE_DIRECTION_INPUT);
    gpiod_line_settings_set_edge_detection(set, GPIOD_LINE_EDGE_RISING);
    gpiod_line_settings_set_bias(set, GPIOD_LINE_BIAS_PULL_DOWN);
    gpiod_line_settings_set_debounce_period_us(set, DEBOUNCE_US);

    if (gpiod_line_config_add_line_settings(lcfg, offsets, n, set))
        goto out;

    gpiod_request_config_set_consumer(rcfg, "wheel-buttons");
    req = gpiod_chip_request_lines(chip, rcfg, lcfg);

out:
    gpiod_request_config_free(rcfg);
    gpiod_line_config_free(lcfg);
    gpiod_line_settings_free(set);
    gpiod_chip_close(chip);
    return req;
}

int main(void)
{
    unsigned int gpios[NUM_BUTTONS];
    button_map_get_gpios(gpios);

    int can = can_init(CAN_INTERFACE);
    if (can < 0) return EXIT_FAILURE;

    UnixSender unix_tx;
    uss_init(&unix_tx, UNIX_SOCK_PATH);

    struct gpiod_line_request *req = request_buttons(gpios, NUM_BUTTONS);
    if (!req) { fprintf(stderr, "GPIO request failed\n"); return EXIT_FAILURE; }

    struct gpiod_edge_event_buffer *buf =
        gpiod_edge_event_buffer_new(NUM_BUTTONS);
    if (!buf) { fprintf(stderr, "Event buffer alloc failed\n"); return EXIT_FAILURE; }

    struct pollfd pfd = {
        .fd     = gpiod_line_request_get_fd(req),
        .events = POLLIN
    };

    printf("Monitoring %d buttons — Ctrl+C to exit\n", NUM_BUTTONS);

    for (;;) {
        if (poll(&pfd, 1, -1) < 0) {
            if (errno == EINTR) continue;
            perror("poll"); break;
        }
        if (!(pfd.revents & POLLIN)) continue;

        int n = gpiod_line_request_read_edge_events(req, buf, NUM_BUTTONS);
        if (n < 0) { perror("read_edge_events"); break; }

        for (int i = 0; i < n; i++) {
            struct gpiod_edge_event *ev =
                gpiod_edge_event_buffer_get_event(buf, i);
            unsigned int gpio = gpiod_edge_event_get_line_offset(ev);

            const ButtonMapping *btn = button_map_find(gpio);
            if (!btn) continue;

            can_send(can, btn);
            printf("[CAN ] 0x%03X [%u %s] \n",
                   CAN_ID, btn->index, btn->name);

            uss_send(&unix_tx, &btn->index, sizeof(btn->index));
        }
    }

    gpiod_edge_event_buffer_free(buf);
    gpiod_line_request_release(req);
    uss_shutdown(&unix_tx);
    close(can);
    return 0;
}
