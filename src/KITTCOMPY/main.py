from kitt import *
from tools import *
import numpy as np
import time
import os

kitt = KITTSerial()
print "Connecting to KITT..."
if not kitt.connect():
	print "Could not connect"
	exit()

model = StateSpaceModel()
lp_filter = LowPassFilter(10, 0.3)
unr_filter = UnrealisticValueFilter(0.5)

dists_left = [0]
dists_right = [0]
state = [[[0],[0]]]
start_sample_time = time.time()
start_time = time.time()

ref_time = [0,   5,   5.1, 10 ]
ref_sig =  [0.5, 0.5, 1.5, 1.5]
drive_limit = 0.15
time_max = 10

while True:
	if time.time()-start_time >= time_max:
		break

	status = kitt.status()
	time.sleep(0.1)

	# Apply unrealistic value filter
	dist_left = unr_filter.eval(dists_left, status.distanceLeft)
	dist_right = unr_filter.eval(dists_right, status.distanceRight)

	# Apply low pass filter
	dist_left = lp_filter.eval(dists_left, dist_left)
	dist_right = lp_filter.eval(dists_right, dist_left)

	dists_left.append(dist_left)
	dists_right.append(dist_right)

	if dist_left < dist_right:
		dist = dist_left
	else:
		dist = dist_right

	# Time calculation
	dt = time.time()-start_sample_time
	start_sample_time = time.time()
	cur_time = time.time()-start_time

	# Find reference
	ref = np.interp(cur_time, ref_time, ref_sig)

	# State-space calculation
	cur_state = np.matrix(state[-1])
	cur_slope = model.slope(cur_state, ref, dist, control=True) 			# Current slope
	pred_state = cur_state + dt*cur_slope 									# Predicted state
	pred_slope = model.slope(pred_state, ref, dist, control=True) 			# Predicted slope
	cur_state = cur_state + dt/2*(cur_slope + pred_slope);					# New current state
	state.append(cur_state.tolist()) 					
	drive = model.output(cur_state, ref, control=True)						# Model output

	# Limit drive signal
	if drive > drive_limit:
		drive = drive_limit

	if drive < -drive_limit:
		drive = -drive_limit

	os.system('clear')
	print "KITTCOMPY"
	print "-------------"
	print "Time:                " + str(round(cur_time,2)) + "s / " + str(round(time_max,2)) + "s"
	print "Current sample time: " + str(round(dt*1000,2)) + "ms"
	print 
	print "Distance left:       " + str(round(dist_left,2)) + "m"
	print "Distance right:      " + str(round(dist_right,2)) + "m"
	print
	print "Distance:            " + str(round(dist,2)) + "m"
	print "Goal:                " + str(round(ref,2)) + "m"
	print "Drive:               " + str(round(drive,3))
	print
	print "Internal state 1:    " + str(round(cur_state.tolist()[0][0],2))
	print "Internal state 2:    " + str(round(cur_state.tolist()[1][0],2))
	print
	print "Battery voltage:     " + str(round(status.batteryVoltage,2))	+ "V"

	kitt.drive(drive)
