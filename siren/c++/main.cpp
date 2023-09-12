#include "siren_server.h"

int main()
{
    int err;
    std::string ipAddr = "127.0.0.1";
    int port = 8080;

    NER::SirenServer server = NER::SirenServer(ipAddr, port);

    err = server.startServer();
    if (err)
        return err;

    err = server.startListen();
    if (err)
        return err;

    return 0;
}