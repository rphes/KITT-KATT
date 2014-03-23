import serial
import io
import time

class UnconnectedException(Exception):
	def __init__(self):
		Exception.__init__(self, 'Unconnected')

class KITTStatus:
	def __init__(self, distanceLeft, distanceRight, batteryVoltage, audioEnabled):
		self.distanceLeft = distanceLeft;
		self.distanceRight = distanceRight;
		self.batteryVoltage = batteryVoltage;
		self.audioEnabled = audioEnabled;

class KITTSerial:
	def __init__(self):
		self.port = None
		self.pwm_drive = 150;
		self.pwm_steer = 150;

	def connect(self):
		# Open port
		try:
			self.port = serial.Serial('/dev/tty.RNBT-3217-RNI-SPP')
		except Exception:
			return False
			exit()

		# Configure port
		self.port.baudrate = 115200
		self.port.bytesize = serial.EIGHTBITS
		self.port.parity = serial.PARITY_NONE
		self.port.stopbits = serial.STOPBITS_ONE
		self.port.rtscts = True 			# Hardware flow control
		return True

	def status(self):
		if self.port == None:
			raise UnconnectedException

		# Request status
		self.port.write("S\n")
		content = self.read()

		# Split content by newline
		lines = content.split("\n")

		print content
		print len(lines)

		# Extract data	
		dist = lines[1][1:len(lines[1])].split(' ')
		bat = lines[2][1:len(lines[2])]
		audio = lines[3][6]

		# Create status object
		status = KITTStatus(
			float(dist[0])/100, float(dist[1])/100, # Distances
			float(bat)/1000,				 		# Battery voltage
			bool(audio) 							# Audio enabled
			)

		return status

	def read(self):
		# Read first character
		content = ''
		char_read = self.port.read(1)

		# Read until EoT is detected and status is read
		while ord(char_read) != 4:
			content += char_read
			char_read = self.port.read(1)

		return content

	def drive(self, val):
		if self.port == None:
			raise UnconnectedException

		# Range: 135 - 145, 155 - 156
		self.pwm_drive = 150
		if val > 0:
			self.pwm_drive += 5 + val*10
		elif val < 0:
			self.pwm_drive -= 5 - val*10

		self.pwm_drive = int(round(self.pwm_drive))
		self.port.write("D" + str(self.pwm_steer) + " " + str(self.pwm_drive))
		self.read()

	def steer(self, val):
		if self.port == None:
			raise UnconnectedException

		self.pwm_steer = int(round(150 + val*50))
		self.port.write("D" + str(self.pwm_steer) + " " + str(self.pwm_drive))
		self.read()

	def __del__(self):
		if not self.port == None:
			self.port.close()
