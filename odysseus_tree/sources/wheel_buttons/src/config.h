#pragma once



#define SOCKET_PATH "/tmp/wheel_buttons_socket"
#define BUFFER_SIZE 256


/**
 * @buttons:
 *  - numbered for now
 *
 *
 *
 * Button Function | Button Number | Button NET Name         | CM5 pin | GPIO Pin  | CAN ID  | 
 * --------------- | ------------- | ------------------------| --------| --------- | --------|
 * Left            | 2             | GPIO_BUTTON1            | 25      | GPIO 21   | 0x101
 * Right           | 7             | GPIO_BUTTON6            | 30      | GPIO 6    | 0x106
 * Enter           | 6             | GPIO_BUTTON5            | 29      | GPIO 16   | 0x105
 * Escape          | 1             | GPIO_BUTTON0            | 24      | GPIO 26   | 0x100
 * Up (regen)      | 4             | GPIO_BUTTON3            | 27      | GPIO 20   | 0x103
 * Down (regen)    | 5             | GPIO_BUTTON4            | 28      | GPIO 13   | 0x104
 * Up (torque)     | 9             | GPIO_BUTTON8            | 34      | GPIO 5    | 0x108
 * Down (torque)   | 10            | GPIO_BUTTON9            | 37      | GPIO 7    | 0x109
 * On (launch)     | 3             | GPIO_BUTTON2            | 26      | GPIO 19   | 0x102
 * Off (launch)    | 8             | GPIO_BUTTON7            | 31      | GPIO 12   | 0x107
 *
 */










#define BUTTON_0_PIN 18
#define BUTTON_1_PIN 19
#define BUTTON_2_PIN 20
#define BUTTON_3_PIN 21
#define BUTTON_4_PIN 22
#define BUTTON_5_PIN 23
#define BUTTON_6_PIN 24
#define BUTTON_7_PIN 25
#define BUTTON_8_PIN 26
#define BUTTON_9_PIN 27