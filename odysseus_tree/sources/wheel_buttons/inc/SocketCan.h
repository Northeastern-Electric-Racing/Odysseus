#ifndef NER_SOCKETCAN_H
#define NER_SOCKETCAN_H

#include "config.h"
#include <stddef.h>
#include <stdint.h>
#include <linux/can.h>

/**
 * Button Function | Button Number | Button NET Name         | CM5 pin | GPIO Pin  | CAN MSG
 * --------------- | ------------- | ------------------------| --------| --------- | --------
 * Escape          | 1             | GPIO_BUTTON0            | 24      | GPIO 26   | 0x100
 * Left            | 2             | GPIO_BUTTON1            | 25      | GPIO 21   | 0x101
 * On (launch)     | 3             | GPIO_BUTTON2            | 26      | GPIO 19   | 0x102
 * Up (regen)      | 4             | GPIO_BUTTON3            | 27      | GPIO 20   | 0x103
 * Down (regen)    | 5             | GPIO_BUTTON4            | 28      | GPIO 13   | 0x104
 * Enter           | 6             | GPIO_BUTTON5            | 29      | GPIO 16   | 0x105
 * Right           | 7             | GPIO_BUTTON6            | 30      | GPIO 6    | 0x106
 * Off (launch)    | 8             | GPIO_BUTTON7            | 31      | GPIO 12   | 0x107
 * Up (torque)     | 9             | GPIO_BUTTON8            | 34      | GPIO 5    | 0x108
 * Down (torque)   | 10            | GPIO_BUTTON9            | 37      | GPIO 7    | 0x109
 */

typedef struct {
    unsigned int gpio;
    unsigned int can_id;
    const char *name;
} ButtonMapping;

/* Lookup table: index = button number - 1 */
static const ButtonMapping button_map[NUM_BUTTONS] = {
    { 26, CAN_BASE_ID + 0, "Escape"       },  /* Button 1  */
    { 21, CAN_BASE_ID + 1, "Left"         },  /* Button 2  */
    { 19, CAN_BASE_ID + 2, "On (launch)"  },  /* Button 3  */
    { 20, CAN_BASE_ID + 3, "Up (regen)"   },  /* Button 4  */
    { 13, CAN_BASE_ID + 4, "Down (regen)" },  /* Button 5  */
    { 16, CAN_BASE_ID + 5, "Enter"        },  /* Button 6  */
    {  6, CAN_BASE_ID + 6, "Right"        },  /* Button 7  */
    { 12, CAN_BASE_ID + 7, "Off (launch)" },  /* Button 8  */
    {  5, CAN_BASE_ID + 8, "Up (torque)"  },  /* Button 9  */
    {  7, CAN_BASE_ID + 9, "Down (torque)"},  /* Button 10 */
};

static inline const ButtonMapping *button_map_find(unsigned int gpio)
{
    for (int i = 0; i < NUM_BUTTONS; i++) {
        if (button_map[i].gpio == gpio)
            return &button_map[i];
    }
    return NULL;
}

static inline void button_map_get_gpios(unsigned int *out)
{
    for (int i = 0; i < NUM_BUTTONS; i++)
        out[i] = button_map[i].gpio;
}

/* CAN socket functions */
int can_init(const char *ifname);
int can_send_button_event(int can_socket, const ButtonMapping *btn, int pressed);

#endif
