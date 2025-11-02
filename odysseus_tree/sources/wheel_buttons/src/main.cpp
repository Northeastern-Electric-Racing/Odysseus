#include <iostream>
#include <cstring>
#include <string>
#include <csignal>
#include <cstdint>

#include <unistd.h>
#include <pigpio.h>

#include <sys/socket.h>
#include <sys/un.h>

#include "connection/unix_socket_client.h"
#include "connection/config.h"

/**
 * buttons:
 *      - just button1 for now
 * 
 */

 // function declarations
void handle_signal(int signum);
void button_signal_handler(int gpio, int level, uint32_t tick);

void button1_callback(int level, uint32_t tick);

// globals
UnixSocketClient unix_socket_client(SOCKET_PATH);

/**
 * @brief Client application that connects to a Unix domain socket server,
 * sends button press messages, and waits for server acknowledgments.For 
 * now it just sends stdin strings to the python application.
 * 
 * @note `receiver.py` must be running before running this client. For testing.
 */
int main(void) {

    if (gpioInitialise() < 0) {
        printf("pigpio init failed");
        return -1;
    }

    gpioSetMode(BUTTON1_PIN, PI_INPUT);
    gpioSetPullUpDown(BUTTON1_PIN, PI_PUD_UP);
    gpioSetAlertFunc(BUTTON1_PIN, button_signal_handler);

    // setup signal handlers
    signal(SIGINT, handle_signal);

    // connect socket client
    unix_socket_client.connect();

    // send messages
    std::string button;
    while (true) {
        std::cout << "> ";
        std::getline(std::cin, button);

        if (button == "exit") {
            break;
        }

        unix_socket_client.send(button);
        std::string response = unix_socket_client.receive();
        printf(("Received response: \"" + response + "\"\n").c_str());
    }

    unix_socket_client.disconnect();
    gpioTerminate();
    printf("Socket closed. Exiting.\n");
    
    return 0;
}

// implementations

void handle_signal(int signum) {
    printf("signal received %d", signum);
    exit(signum);
}

void button_signal_handler(int gpio, int level, uint32_t tick) {
    printf("GPIO %d changed to level %d at tick %u\n", gpio, level, tick);

    if (gpio == BUTTON1_PIN) {
        button1_callback(level, tick);
    }
}

void button1_callback(int level, uint32_t tick) {
    if (level==0) { // button down, falling edge
        printf("button 1 down");
        unix_socket_client.send("button1_down");
    } else if (level==1) { // button up, rising edge
        printf("button 1 up");
        unix_socket_client.send("button1_up");
    }
}