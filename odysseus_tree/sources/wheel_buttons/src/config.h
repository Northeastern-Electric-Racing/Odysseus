#ifndef CONFIG_H
#define CONFIG_H

/* ── GPIO ──────────────────────────────────────────────────────── */
#define CHIP_PATH           "/dev/gpiochip0"   /*  /dev/gpiochip0 on Pi 4    /dev/gpiochip4 on Pi 5 */
#define DEBOUNCE_US         10000              /* 10 ms debounce */

/* ── CAN ───────────────────────────────────────────────────────── */
#define CAN_INTERFACE       "vcan0"
#define CAN_BASE_ID         0x100

/* ── Unix Socket ───────────────────────────────────────────────── */
#define UNIX_SOCK_PATH      "/tmp/wheel_buttons_socket"

/* ── Buttons ───────────────────────────────────────────────────── */
#define NUM_BUTTONS         10

#endif