/**
 * @brief Main loop — monitors all steering wheel GPIO buttons using
 *        edge-event interrupts, sends CAN frames and broadcasts
 *        Unix socket messages to any connected clients.
 *
 * Build:
 *   gcc -o wheel_buttons main.c SocketCan.c SocketUnix.c -lgpiod
 *
 * Setup (vcan for testing):
 *   sudo modprobe vcan
 *   sudo ip link add dev vcan0 type vcan
 *   sudo ip link set up vcan0
 *
 * Monitor CAN:
 *   candump vcan0
 *
 * Monitor Unix socket:
 *   socat - UNIX-CONNECT:/tmp/wheel_buttons_socket
 */

#include "config.h"
#include "SocketCan.h"
#include "SocketUnix.h"

#include <errno.h>
#include <gpiod.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define EVENT_BUF_SIZE  NUM_BUTTONS

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
    return gpiod_edge_event_get_event_type(event) == GPIOD_EDGE_EVENT_FALLING_EDGE;
}

/* ── Format + broadcast a button event over Unix socket ────────── */

static void broadcast_button_event(UnixSocketServer *server,
                                   const ButtonMapping *btn,
                                   int pressed)
{
    char msg[128];
    snprintf(msg, sizeof(msg), "BTN:%s:%s\n",
             btn->name,
             pressed ? "PRESSED" : "RELEASED");

    int n = uss_broadcast(server, msg);
    printf("[UNIX] %-14s %-8s  -> %d client(s)\n",
           btn->name,
           pressed ? "PRESSED" : "RELEASED",
           n);
}

/* ── Main ─────────────────────────────────────────────────────── */

int main(void)
{
    struct gpiod_edge_event_buffer *event_buffer = NULL;
    struct gpiod_line_request *gpio_request      = NULL;
    UnixSocketServer unix_server;
    int can_socket = -1;
    int unix_ok    = 0;
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

    /* ── Init Unix socket server ──────────────────────────────── */
    if (uss_init(&unix_server, UNIX_SOCK_PATH) == 0) {
        unix_ok = 1;
    } else {
        fprintf(stderr, "UNIX socket server failed to start, CAN-only mode.\n");
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

    printf("\nMonitoring %d buttons (interrupt-driven) — Ctrl+C to exit\n",
           NUM_BUTTONS);
    printf("Clients can connect with: socat - UNIX-CONNECT:%s\n\n",
           UNIX_SOCK_PATH);

    /* ── Interrupt-driven event loop ──────────────────────────── */
    for (;;) {
        /* Accept any pending clients before blocking on GPIO */
        if (unix_ok)
            uss_accept_clients(&unix_server);

        ret = gpiod_line_request_wait_edge_events(gpio_request, -1);
        if (ret < 0) {
            if (errno == EINTR) continue;
            perror("gpiod_line_request_wait_edge_events");
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

            /* Broadcast to Unix socket clients */
            if (unix_ok)
                broadcast_button_event(&unix_server, btn, pressed);
        }
    }

    ret = EXIT_SUCCESS;

cleanup:
    if (event_buffer)    gpiod_edge_event_buffer_free(event_buffer);
    if (gpio_request)    gpiod_line_request_release(gpio_request);
    if (unix_ok)         uss_shutdown(&unix_server);
    if (can_socket >= 0) close(can_socket);

    return ret;
}