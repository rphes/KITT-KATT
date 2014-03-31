#include "mex.h"
#include <stdlib.h>
#include <string.h>
#include "../libs/serial.h"

#define BUFFER_SIZE 1024
	
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	static int port = -1;
	int cmd_len, arg_len;
	int port_open, arg_given;

	char *cmd, *arg;
	
	// Checks
	if (nrhs < 1) mexErrMsgTxt("One argument required.");
	if (nrhs > 2) mexErrMsgTxt("Too many arguments given.");
	if (nlhs > 1) mexErrMsgTxt("Too many outputs.");
	if (!mxIsChar(prhs[0])) mexErrMsgTxt("Input must be a string.");
	if (mxGetM(prhs[0]) != 1) mexErrMsgTxt("Input must be a row vector.");

	// Get command
	cmd = mxArrayToString(prhs[0]);
	cmd_len = mxGetN(prhs[0]);
	
	// Get argument
	if (nrhs == 2) {
		arg = mxArrayToString(prhs[1]);
		arg_len = mxGetN(prhs[1]);
	}

	// Last inits
	// out = mxCalloc(BUFFER_SIZE, sizeof(char));
	port_open = (port != -1);
	arg_given = (nrhs == 2);

	// Check command
	if (strcmp("open", cmd) == 0) {
		// Open port
		if (!arg_given) mexErrMsgTxt("Second argument required.");

		port = open_port(arg);

		// Check if port is opened
		if (port == -1) {
			// Return failure
			plhs[0] = mxCreateDoubleScalar(0);
		} else {
			// Return success
			plhs[0] = mxCreateDoubleScalar(1);
		}
	} else if (strcmp("close", cmd) == 0) {
		// Close port
		if (arg_given) mexErrMsgTxt("Second argument unexpected.");

		if (port != -1) {
			close_port(port);
			port = -1;
		}

		// Return success
		plhs[0] = mxCreateDoubleScalar(1);
	} else if (strcmp("transmit", cmd) == 0) {
		// Transmit and receive data
		if (!arg_given) mexErrMsgTxt("Second argument required.");
		if (port == -1) mexErrMsgTxt("No port openend.");

		// Write port
		write_port(port, arg);

		// Read data
		char *ret = mxCalloc(BUFFER_SIZE, sizeof(char));
		read_port(port, ret, 4); // ASCII 4 is end-of-transmission character

		// Return data read
		plhs[0] = mxCreateString(ret);
		mxFree(ret);
	}

	// Return value and free variables
	mxFree(cmd);
	if (arg_given) mxFree(arg);
}
