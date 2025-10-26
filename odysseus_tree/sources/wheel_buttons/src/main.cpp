#include <iostream>
#include <cstring>
#include <string>
#include <csignal>
#include <cstdint>

#include <unistd.h>
#include <pigpio.h>

#include <sys/socket.h>
#include <sys/un.h>

#include "util/logging.h"
#include "connection/unix_socket_client.h"

/**
 * buttons:
 * 
 * 
 */

void button1_callback(int gpio, int level, uint32_t tick) {
    if (level==0) { // button down, fallign edge
        // TODO just log for now, send over socket to 
        printf("button 1 pressed");
    } else if (level==1) { // button up, rising edge
        printf("button 1 released");
    }
}

void handle_signal(int signum) {
    printf("signal received %d", signum);
}

/**
 * @brief Client application that connects to a Unix domain socket server,
 * sends button press messages, and waits for server acknowledgments.For 
 * now it just sends stdin strings to the python application.
 * 
 * @note `receiver.py` must be running before running this client.
 */
int main(void) {

    if (gpioInitialise() < 0) {
        printf("pigpio init failed");
        return -1;
    }

    gpioSetMode(BUTTON1_PIN, PI_INPUT);
    gpioSetPullUpDown(BUTTON_PIN, PI_PUD_UP);
    gpioSetAlertFunc(BUTTON_PIN, button_1_callback);

    // setup signal handlers
    signal(SIGINT, handle_signal);

    // constr socket
    UnixSocketClient client(SOCKET_PATH);
    client.connect();

    // send messages
    std::string button;
    while (true) {
        std::cout << "> ";
        std::getline(std::cin, button);

        if (button == "exit") {
            break;
        }

        client.send(button);
        std::string response = client.receive();
        log_info(("Received response: \"" + response + "\"\n").c_str());
    }

    client.disconnect();
    gpioTerminate();
    log_info("Socket closed. Exiting.\n");
    
    return 0;
}