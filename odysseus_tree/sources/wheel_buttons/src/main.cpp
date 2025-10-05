#include <iostream>
#include <cstring>
#include <string>

#include <unistd.h>
#include <signal.h>

#include <sys/socket.h>
#include <sys/un.h>

#include <ncurses.h>

#include "util/logging.h"
#include "connection/unix_socket_client.h"

void handle_signal(int sig) {
    std::string msg = "Received signal ";
    msg += strsignal(sig);
    msg += "\n";
    log_info(msg.c_str());
    if (sig==SIGINT) {
        log_info("Exiting...\n");
        exit(sig);
    }
}

/**
 * @brief Client application that connects to a Unix domain socket server,
 * sends button press messages, and waits for server acknowledgments.For 
 * now it just sends stdin strings to the python application.
 * 
 * @note `receiver.py` must be running before running this client.
 */
int main(void) {

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
    log_info("Socket closed. Exiting.\n");
    
    return 0;
}