#include <stdlib.h>
#include <sys/time.h>
#include <string.h>
#include "serial.h"

#define BUFFER_SIZE 1024

#define FRICTION_COEFFICIENT 0.1
#define MASS 0.7
#define FORCE_MULTIPLIER 0.35

#define abs(x) ((x)<0?-(x):(x))

double getTimeInMilliseconds(void) {
	struct timeval tv;
	gettimeofday(&tv, NULL);

	return tv.tv_sec * 1000 + tv.tv_usec / 1000;	
}

void updatePhysics(double* curDist, double* curSpeed, double appliedForce, double dt) {
	/*
		IMPORTANT:
		Gets more accurate with lower sample times.

		BUG:
		When moving forward, with opposite force applied and a long
		sample time, the friction will be condisidered as applied force.
	 */
	double resForce = appliedForce;
	fprintf(stdout, "--------[BEGIN PHYSICS]--------\n");
	fprintf(stdout, "Current distance: %.2f\nCurrent speed %.2f\nApplied force: %.2f\nTime interval: %.2f\n", *curDist, *curSpeed, appliedForce, dt);

	// Friction
	double friction =  MASS*9.81*FRICTION_COEFFICIENT;
	
	if (abs(*curSpeed) > 0.05) {
		if (*curSpeed > 0) {
			resForce -= friction;
		} else {
			resForce += friction;
		}
	}

	fprintf(stdout, "Friction: %.2f\nResultant force: %.2f\n", friction, resForce);

	// Sign of current speed
	double speedSign = (*curSpeed == 0 ? 0 : (*curSpeed > 0 ? 1 : -1));

	// Adjust distance
	*curDist += (*curSpeed)*dt + 1/2*(resForce/MASS)*dt*dt;

	// Update current speed
	*curSpeed += resForce/MASS*dt;

	fprintf(stdout, "New distance: %.2f\nNew speed: %.2f\n", *curDist, *curSpeed);

	// Check if friction moved the car the other way
	if (
		(appliedForce >= 0 && speedSign > 0 && *curSpeed < 0) ||
		(appliedForce <= 0 && speedSign < 0 && *curSpeed > 0)
		) {
		*curSpeed = 0;
	}

	fprintf(stdout, "Corrected speed: %.2f\n", *curSpeed);

	fprintf(stdout, "---------[END PHYSICS]---------\n");
}

int main(int argc, char *argv[]) {
	fprintf(stdout, "Opening port /dev/ptyp0\n");
	int port = open_port("/dev/ptyp0");

	// Check if port is open
	if (port == -1) {
		return 0;
	}

	// Initialization
	char *temp = malloc(sizeof(char)*BUFFER_SIZE);
	char *ret = malloc(sizeof(char)*BUFFER_SIZE);
	double startTime = getTimeInMilliseconds();

	// Physics initializaion
	double curDist = 1.2, curSpeed = 0, curForce = 0;
	double prevTime = 0;

	while (read_port(port, temp, '\n')) {
		// KITT delay
		usleep(1000*150);

		// Update time
		double curTime = getTimeInMilliseconds() - startTime;
		double dt = (curTime - prevTime)/1000;
		prevTime = curTime;

		// Update physics
		updatePhysics(&curDist, &curSpeed, curForce, dt);

		// Report
		fprintf(stdout, "\nTime: %.0fms\n-----[BEGIN RECEIVED DATA]-----\n%s\n------[END RECEIVED DATA]------\n", curTime, temp);

		if (strcmp(temp, "S") == 0) {
			fprintf(stdout, ">> Returning status\n");

			// Returning status
			sprintf(ret, "D150 150\nU%.0f %.0f\nB19511\nAudio 1\nX", curDist*100, curDist*100);
		} else if (strncmp(temp, "D", 1) == 0) {
			fprintf(stdout, ">> Adjusting force applied\n");

			// Adjusting applied force
			int drive;
			int steer;
			sscanf(temp, "D%d %d", &steer, &drive);

			// Minus sign to invert excitation
			if (drive >= 154) {
				curForce = -(drive - 154)*FORCE_MULTIPLIER;
			} else if (drive <= 146) {
				curForce = -(drive - 146)*FORCE_MULTIPLIER;
			} else {
				curForce = 0;
			}

			// Report
			fprintf(stdout, ">> Drive: %d, steer: %d\n>> New force applied: %.2f\n", drive, steer, curForce);

			// Adjusted driving speed
			sprintf(ret, "Adjusted driving speedX");
		} else {
			fprintf(stdout, ">> Unknown command\n");

			// Unknown command
			sprintf(ret, "Unknown commandX");
		}

		// Replace all X's by end-of-transmission characters
		int i;
		for (i = 0; ret[i] != '\0'; i++) {
			if (ret[i] == 'X') {
				ret[i] = 4; // ASCII 4 is end-of-transmission
			}
		}
		
		write_port(port, ret);

		// Reset buffers
		memset(temp, 0, BUFFER_SIZE);
		memset(ret, 0, BUFFER_SIZE);
	}

	free(ret);
	free(temp);

	close_port(port);
	return 0;
}