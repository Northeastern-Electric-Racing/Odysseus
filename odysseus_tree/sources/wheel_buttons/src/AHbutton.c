
/**
 * @brief Starts A CAN socket and watchs gpios for button presses
 *  For testing, code was uploaded to the pi (compiled in c using gcc) and tested with Can-utils using 'candump vcan0'
 * 
 * 
 * 
 * @note I dont know what im doing, this is my first C program with major help from stackOverflow, slack, and docs
 
 */




 // USEPRINTFERROS

#include "config.h"

#include <errno.h>
#include <gpiod.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <linux/can.h>
#include <linux/can/raw.h>

/* Request multiple GPIO lines as inputs with edge detection for buttons */
static struct gpiod_line_request *request_button_lines(const char *chip_path,
                                                        unsigned int *offsets,
                                                        unsigned int num_lines,
                                                        const char *consumer)
{
    struct gpiod_request_config *req_cfg = NULL;
    struct gpiod_line_request *request = NULL;
    struct gpiod_line_settings *settings;
    struct gpiod_line_config *line_cfg;
    struct gpiod_chip *chip;
    int ret;

    chip = gpiod_chip_open(chip_path);
    if (!chip)
        return NULL;

    settings = gpiod_line_settings_new();
    if (!settings)
        goto close_chip;

    /* Configure as input with both edge detection */
    gpiod_line_settings_set_direction(settings, GPIOD_LINE_DIRECTION_INPUT);
    gpiod_line_settings_set_edge_detection(settings, GPIOD_LINE_EDGE_BOTH);
    
    /* Pull-up resistor (assuming button connects to ground) */
    gpiod_line_settings_set_bias(settings, GPIOD_LINE_BIAS_PULL_UP);
    
    /* 10ms debounce to prevent spurious triggers */
    gpiod_line_settings_set_debounce_period_us(settings, 10000);

    line_cfg = gpiod_line_config_new();
    if (!line_cfg)
        goto free_settings;

    ret = gpiod_line_config_add_line_settings(line_cfg, offsets, num_lines, settings);
    if (ret)
        goto free_line_config;

    if (consumer) {
        req_cfg = gpiod_request_config_new();
        if (!req_cfg)
            goto free_line_config;
        gpiod_request_config_set_consumer(req_cfg, consumer);
    }

    request = gpiod_chip_request_lines(chip, req_cfg, line_cfg);

    gpiod_request_config_free(req_cfg);
free_line_config:
    gpiod_line_config_free(line_cfg);
free_settings:
    gpiod_line_settings_free(settings);
close_chip:
    gpiod_chip_close(chip);

    return request;
}

/* Initialize CAN socket */
static int init_can_socket(const char *ifname)
{
    struct sockaddr_can addr;
    struct ifreq ifr;
    int s;

    s = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (s < 0) {
        perror("socket");
        return -1;
    }

    strcpy(ifr.ifr_name, ifname);
    if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
        perror("SIOCGIFINDEX");
        close(s);
        return -1;
    }

    memset(&addr, 0, sizeof(addr));
    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("bind");
        close(s);
        return -1;
    }

    return s;
}

/* Send CAN message */
static int send_button_event(int can_socket, unsigned int gpio, int pressed)
{
    struct can_frame frame;

    unsigned int can_id;

    switch (gpio) {
        case 26: can_id = 0x100; break;
        case 21: can_id = 0x101; break;
        case 19: can_id = 0x102; break;
        case 20: can_id = 0x103; break;
        case 13: can_id = 0x104; break;
        case 16: can_id = 0x105; break;
        case 6: can_id = 0x106; break;
        case 12: can_id = 0x107; break;
        case 5: can_id = 0x108; break;
        case 7: can_id = 0x109; break;
        default:
            fprintf(stderr, "Unknown GPIO: %u\n", gpio);
            return -1;
    }


    memset(&frame, 0, sizeof(frame));
    
    
    frame.can_id = can_id;
    frame.can_dlc = 2;
    
    /* Data[0] = GPIO number, Data[1] = state (1=pressed, 0=released) */
    frame.data[0] = gpio;
    frame.data[1] = pressed ? 1 : 0;

    if (write(can_socket, &frame, sizeof(frame)) != sizeof(frame)) {
        perror("write");
        return -1;
    }

    return 0;
}

static const char *edge_event_type_str(struct gpiod_edge_event *event)
{
    switch (gpiod_edge_event_get_event_type(event)) {
    case GPIOD_EDGE_EVENT_RISING_EDGE:
        return "Released";
    case GPIOD_EDGE_EVENT_FALLING_EDGE:
        return "Pressed";
    default:
        return "Unknown";
    }
}

static int is_pressed(struct gpiod_edge_event *event)
{
    return gpiod_edge_event_get_event_type(event) == GPIOD_EDGE_EVENT_FALLING_EDGE;
}

int main(void)
{
    static const char *const chip_path = "/dev/gpiochip0";
    static const char *const can_interface = "vcan0";
    static unsigned int button_pins[] = {5, 6};  /* GPIO5 and GPIO6 */
    static const unsigned int num_buttons = 2;
    
    struct gpiod_edge_event_buffer *event_buffer;
    struct gpiod_line_request *request;
    struct gpiod_edge_event *event;
    struct pollfd pollfd;
    int i, ret, can_socket;

    printf("Button detection on GPIO5 and GPIO6 with CAN output to %s\n", can_interface);
    
    /* Initialize CAN socket */
    can_socket = init_can_socket(can_interface);
    if (can_socket < 0) {
        fprintf(stderr, "Failed to initialize CAN socket\n");
        fprintf(stderr, "Make sure vcan0 is set up: sudo ip link add dev vcan0 type vcan && sudo ip link set up vcan0\n");
        return EXIT_FAILURE;
    }
    printf("CAN socket initialized on %s\n", can_interface);

    /* Request GPIO lines */
    request = request_button_lines(chip_path, button_pins, num_buttons, "button-detector");
    if (!request) {
        fprintf(stderr, "Failed to request GPIO lines: %s\n", strerror(errno));
        close(can_socket);
        return EXIT_FAILURE;
    }

    /* Buffer size of 2 to handle events from both buttons */
    event_buffer = gpiod_edge_event_buffer_new(2);
    if (!event_buffer) {
        fprintf(stderr, "Failed to create event buffer: %s\n", strerror(errno));
        gpiod_line_request_release(request);
        close(can_socket);
        return EXIT_FAILURE;
    }

    pollfd.fd = gpiod_line_request_get_fd(request);
    pollfd.events = POLLIN;

    printf("Monitoring buttons... Press Ctrl+C to exit\n\n");

    /* Main event loop */
    for (;;) {
        ret = poll(&pollfd, 1, -1);
        if (ret == -1) {
            fprintf(stderr, "Error waiting for events: %s\n", strerror(errno));
            break;
        }

        ret = gpiod_line_request_read_edge_events(request, event_buffer, 2);
        if (ret == -1) {
            fprintf(stderr, "Error reading events: %s\n", strerror(errno));
            break;
        }

        for (i = 0; i < ret; i++) {
            event = gpiod_edge_event_buffer_get_event(event_buffer, i);
            unsigned int gpio = gpiod_edge_event_get_line_offset(event);
            int pressed = is_pressed(event);
            
            /* Send CAN message */
            if (send_button_event(can_socket, gpio, pressed) == 0) {
                printf("GPIO%d Button %s -> CAN ID 0x%03X [%d %d]\n",
                       gpio,
                       edge_event_type_str(event),
                       0x100 + (gpio - 5),
                       gpio,
                       pressed);
            } else {
                fprintf(stderr, "Failed to send CAN message\n");
            }
        }
    }

    /* Cleanup */
    gpiod_edge_event_buffer_free(event_buffer);
    gpiod_line_request_release(request);
    close(can_socket);
    
    return EXIT_SUCCESS;
}