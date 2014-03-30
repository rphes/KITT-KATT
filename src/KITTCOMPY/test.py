from kitt import *

kitt = KITTSerial()
print "Connecting to KITT..."
if not kitt.connect():
	print "Could not connect"
	exit()

status = kitt.status()

print status.distanceLeft
print status.distanceRight
print status.batteryVoltage
print status.audioEnabled
