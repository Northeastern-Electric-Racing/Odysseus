#ifndef NER_SOCKETCAN_H
#define NER_SOCKETCAN_H

#include "config.h"
#include <stddef.h>
#include <stdint.h>

/**
 * Button | GPIO | Index | Name
 * -------|------|-------|------
 *  1     |  26  |  0    | Escape
 *  2     |  21  |  1    | Left
 *  3     |  19  |  2    | On (launch)
 *  4     |  20  |  3    | Up (regen)
 *  5     |  13  |  4    | Down (regen)
 *  6     |  16  |  5    | Enter
 *  7     |   6  |  6    | Right
 *  8     |  12  |  7    | Off (launch)
 *  9     |   5  |  8    | Up (torque)
 * 10     |   7  |  9    | Down (torque)
 *
 * CAN frame (all buttons use CAN_ID 0x100):
 *   data[0] = button index (0-9)
 *   data[1] = 1 pressed, 0 released
 */

typedef struct {
    unsigned int gpio;
    uint8_t      index;
    const char  *name;
} ButtonMapping;

static const ButtonMapping button_map[NUM_BUTTONS] = {
    { 26, 0, "Escape"       },
    { 21, 1, "Left"         },
    { 19, 2, "On (launch)"  },
    { 20, 3, "Up (regen)"   },
    { 13, 4, "Down (regen)" },
    { 16, 5, "Enter"        },
    {  6, 6, "Right"        },
    { 12, 7, "Off (launch)" },
    {  5, 8, "Up (torque)"  },
    {  7, 9, "Down (torque)"},
};

static inline const ButtonMapping *button_map_find(unsigned int gpio)
{
    for (int i = 0; i < NUM_BUTTONS; i++)
        if (button_map[i].gpio == gpio)
            return &button_map[i];
    return NULL;
}

static inline void button_map_get_gpios(unsigned int *out)
{
    for (int i = 0; i < NUM_BUTTONS; i++)
        out[i] = button_map[i].gpio;
}

int can_init(const char *ifname);
int can_send(int sock, const ButtonMapping *btn);

#endif