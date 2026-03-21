/**
 * @brief Main loop — monitors all steering wheel GPIO buttons,
 *        sends CAN frames and Unix socket messages on each press.
 *
 * Build:
 *   gcc -o wheel_buttons main.c SocketCan.c SocketUnix.c -lgpiod
 *
 * Setup (vcan for testing):
 *   sudo modprobe vcan
 *   sudo ip link add dev vcan0 type vcan
 *   sudo ip link set up vcan0
 *
 * Monitor:
 *   candump vcan0
 */

#include "config.h"
#include "SocketCan.h"
#include "SocketUnix.h"

#include <errno.h>
#include <gpiod.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define EVENT_BUF_SIZE  NUM_BUTTONS  /* worst-case: one event per line */

/* ── GPIO helpers ──────────────────────────────────────────────── */

static struct gpiod_line_request *request_button_lines(unsigned int *offsets,
                                                       unsigned int num_lines)
{
    struct gpiod_request_config *req_cfg = NULL;
    struct gpiod_line_request *request   = NULL;
    struct gpiod_line_settings *settings = NULL;
    struct gpiod_line_config *line_cfg   = NULL;
    struct gpiod_chip *chip              = NULL;
    int ret;

    chip = gpiod_chip_open(CHIP_PATH);
    if (!chip) {
        perror("gpiod_chip_open");
        return NULL;
    }

    settings = gpiod_line_settings_new();
    if (!settings) goto out;

    gpiod_line_settings_set_direction(settings, GPIOD_LINE_DIRECTION_INPUT);
    gpiod_line_settings_set_edge_detection(settings, GPIOD_LINE_EDGE_BOTH);
    gpiod_line_settings_set_bias(settings, GPIOD_LINE_BIAS_PULL_UP);
    gpiod_line_settings_set_debounce_period_us(settings, DEBOUNCE_US);

    line_cfg = gpiod_line_config_new();
    if (!line_cfg) goto out;

    ret = gpiod_line_config_add_line_settings(line_cfg, offsets, num_lines, settings);
    if (ret) goto out;

    req_cfg = gpiod_request_config_new();
    if (!req_cfg) goto out;
    gpiod_request_config_set_consumer(req_cfg, "wheel-buttons");

    request = gpiod_chip_request_lines(chip, req_cfg, line_cfg);

out:
    gpiod_request_config_free(req_cfg);
    gpiod_line_config_free(line_cfg);
    gpiod_line_settings_free(settings);
    gpiod_chip_close(chip);
    return request;
}

static int is_pressed(struct gpiod_edge_event *event)
{
    /* Active-low: falling edge = pressed */
    return gpiod_edge_event_get_event_type(event) == GPIOD_EDGE_EVENT_FALLING_EDGE;
}

/* ── Unix socket message formatting ───────────────────────────── */

static int send_unix_button_event(UnixSocketClient *client,
                                  const ButtonMapping *btn,
                                  int pressed)
{
    char msg[128];
    snprintf(msg, sizeof(msg), "BTN:%s:%s\n",
             btn->name,
             pressed ? "PRESSED" : "RELEASED");

    return usc_send(client, msg);
}

/* ── Main ─────────────────────────────────────────────────────── */

int main(void)
{
    struct gpiod_edge_event_buffer *event_buffer = NULL;
    struct gpiod_line_request *gpio_request      = NULL;
    UnixSocketClient unix_client;
    int can_socket  = -1;
    int unix_ok     = 0;
    int ret;

    unsigned int gpio_pins[NUM_BUTTONS];
    button_map_get_gpios(gpio_pins);

    printf("=== Wheel Button Controller ===\n");
    printf("GPIO chip     : %s\n", CHIP_PATH);
    printf("CAN interface : %s\n", CAN_INTERFACE);
    printf("UNIX socket   : %s\n", UNIX_SOCK_PATH);
    printf("Buttons       : %d\n\n", NUM_BUTTONS);

    /* ── Init CAN ─────────────────────────────────────────────── */
    can_socket = can_init(CAN_INTERFACE);
    if (can_socket < 0) {
        fprintf(stderr, "CAN init failed. Make sure the interface is up:\n"
                "  sudo ip link add dev %s type vcan && sudo ip link set up %s\n",
                CAN_INTERFACE, CAN_INTERFACE);
        return EXIT_FAILURE;
    }
    printf("CAN socket ready.\n");

    /* ── Init Unix socket (non-fatal if server isn't running) ── */
    if (usc_init(&unix_client, UNIX_SOCK_PATH) == 0) {
        if (usc_connect(&unix_client) == 0) {
            unix_ok = 1;
            printf("UNIX socket connected.\n");
        } else {
            fprintf(stderr, "UNIX socket: server not available, "
                    "CAN-only mode.\n");
        }
    }

    /* ── Request GPIO lines ───────────────────────────────────── */
    gpio_request = request_button_lines(gpio_pins, NUM_BUTTONS);
    if (!gpio_request) {
        fprintf(stderr, "Failed to request GPIO lines: %s\n", strerror(errno));
        ret = EXIT_FAILURE;
        goto cleanup;
    }
    printf("GPIO lines acquired.\n");

    event_buffer = gpiod_edge_event_buffer_new(EVENT_BUF_SIZE);
    if (!event_buffer) {
        fprintf(stderr, "Failed to create event buffer: %s\n", strerror(errno));
        ret = EXIT_FAILURE;
        goto cleanup;
    }

    /* ── Event loop ───────────────────────────────────────────── */
    struct pollfd pfd = {
        .fd     = gpiod_line_request_get_fd(gpio_request),
        .events = POLLIN,
    };

    printf("\nMonitoring %d buttons — Ctrl+C to exit\n\n", NUM_BUTTONS);

    for (;;) {
        ret = poll(&pfd, 1, -1);
        if (ret < 0) {
            if (errno == EINTR) continue;
            perror("poll");
            break;
        }

        int nevents = gpiod_line_request_read_edge_events(gpio_request,
                                                          event_buffer,
                                                          EVENT_BUF_SIZE);
        if (nevents < 0) {
            perror("gpiod_line_request_read_edge_events");
            break;
        }

        for (int i = 0; i < nevents; i++) {
            struct gpiod_edge_event *ev =
                gpiod_edge_event_buffer_get_event(event_buffer, i);

            unsigned int gpio = gpiod_edge_event_get_line_offset(ev);
            int pressed       = is_pressed(ev);

            const ButtonMapping *btn = button_map_find(gpio);
            if (!btn) {
                fprintf(stderr, "Unexpected GPIO %u event, skipping.\n", gpio);
                continue;
            }

            /* Send CAN frame */
            if (can_send_button_event(can_socket, btn, pressed) == 0) {
                printf("[CAN ] 0x%03X  %-14s %s  [%02X %02X]\n",
                       btn->can_id, btn->name,
                       pressed ? "PRESSED " : "RELEASED",
                       btn->gpio, pressed);
            }

            /* Send Unix socket message */
            if (unix_ok) {
                if (send_unix_button_event(&unix_client, btn, pressed) < 0) {
                    fprintf(stderr, "[UNIX] send failed, disabling.\n");
                    unix_ok = 0;
                } else {
                    printf("[UNIX] %-14s %s\n",
                           btn->name,
                           pressed ? "PRESSED " : "RELEASED");
                }
            }
        }
    }

    ret = EXIT_SUCCESS;

cleanup:
    if (event_buffer)    gpiod_edge_event_buffer_free(event_buffer);
    if (gpio_request)    gpiod_line_request_release(gpio_request);
    if (unix_ok)         usc_disconnect(&unix_client);
    if (can_socket >= 0) close(can_socket);

    return ret;
}