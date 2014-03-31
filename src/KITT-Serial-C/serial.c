#include "serial.h"

/**
 * Open serial port
 * @param  port port, e.g. /dev/tty01
 * @return      port file descriptor
 */
int open_port(const char *port) {
	int fd;

	fd = open(port, O_RDWR | O_NOCTTY);
	if (fd == -1) {
		fprintf(stderr, "Unable to open port\n");
		return fd;
	}

	// Configure port
	struct termios tty;
	memset(&tty, 0 , sizeof(tty));

	if (tcgetattr(fd, &tty) != 0) {
		fprintf(stderr, "Could not get port attributes\n");
		return fd;
	}

	// Baud rate
	cfsetospeed(&tty, B115200);
	cfsetispeed(&tty, B115200);

	// No two stop bits, unset data bits, no parity
	// 8 data bits, hardware flow control, enable receiver, ignore modem control
	tty.c_cflag &= ~(CSIZE | PARENB);
	tty.c_cflag |= (CS8 | CRTSCTS | CREAD | CLOCAL);
	// Disable canonical input
	// Set read time-out to five seconds
	tty.c_lflag &= ~ICANON;
	tty.c_cc[VTIME] = 50;

	cfmakeraw(&tty); // Raw data

	// Flush and apply attributes
	tcflush(fd, TCIOFLUSH);
	if (tcsetattr(fd, TCSANOW, &tty) != 0) {
        tcsetattr(fd, TCSAFLUSH, &tty);
		fprintf(stderr, "Could not set port attributes\n");
		return fd;
	}

	return fd;
}

/**
 * Write to port
 * @param fd  port file descriptor
 * @param msg message
 */
void write_port(int fd, const char *msg) {
	int len;

	for (len = 0; msg[len] != '\0'; len++)
		; // Get length of message

	write(fd, msg, len);

	// Enforce data transmission
	fsync(fd);
}

/**
 * Read message from port
 * @param  fd  port file descriptor
 * @param  buf buffer variable
 * @param  eom end of message character
 * @return     message read
 */
const char* read_port(int fd, char* buf, const char eom) {
	int byte_read_len = 0;
	char byte_read;

	while (read(fd, &byte_read, 1)) {
		if (byte_read != eom) { // Still in message
			buf[byte_read_len++] = byte_read;
		} else {
			// Check for string end
			if (buf[byte_read_len-1] != '\0') {
				buf[byte_read_len++] = '\0';
			}

			// Return result
			return buf;
		}
	}

	// No correct result read
	return NULL;
}

/**
 * Close port
 * @param fd port file descriptor
 */
void close_port(int fd) {
	// Sleep before closing the port to ensure data transmission
	sleep(1);
	close(fd);
}

/**
 * Flush port
 * @param fd fd port file descriptor
 */
void flush_port(int fd) {
	tcflush(fd, TCIOFLUSH);
}