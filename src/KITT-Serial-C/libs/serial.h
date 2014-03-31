#if !defined(SERIAL_H)
#define SERIAL_H

#include <stdio.h> // Standard I/O
#include <string.h> // String handling
#include <unistd.h> // Standard UNIX function defs
#include <fcntl.h> // File control definitions
#include <errno.h> // Error number definitions
#include <termios.h> // Terminal control defs
#include <time.h> // Time calls

int open_port(const char*);
void write_port(int, const char*);
const char* read_port(int, char*, const char);
void close_port(int);
void flush_port(int);

#endif