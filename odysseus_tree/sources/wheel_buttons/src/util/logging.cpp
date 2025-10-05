#include <cstdio>
#include <string>

#include "util/logging.h"

void log_info(const char* message) {
    std::printf("[INFO] %s", message);
}

void log_error(const char* message) {
    std::fprintf(stderr, "[ERROR] %s", message);
}