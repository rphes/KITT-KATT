#include "serial.h"
#include <stdlib.h>

int main(int argc, char *argv[]) {
	fprintf(stdout, "Opening port\n");
	int port = open_port("/dev/ttyp0");

	// Check if port is open
	if (port == -1) {
		return 0;
	}

	fprintf(stdout, "Writing\n");
	write_port(port, "Hey, how are you?\n");

	fprintf(stdout, "Reading\n");
	char *ret = malloc(sizeof(char)*1024);
	read_port(port, ret, '\n');
	fprintf(stdout, "Read: %s\n", ret);

	fprintf(stdout, "Writing\n");
	write_port(port, "Fine too, thank you!\n");

	fprintf(stdout, "Reading\n");
	read_port(port, ret, '\n');
	fprintf(stdout, "Read: %s\n", ret);

	free(ret);
	close(port);
	return 0;
}