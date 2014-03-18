import serial
import io

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
		return True
		# Open port
		try:
			self.port = serial.Serial('/dev/tty.RNBT-3217-RNI-SPP')
		except Exception:
			return False
			exit()

		# Configure port
		self.port.baudrate = 115200
		self.port.bytesize = EIGHTBITS
		self.port.parity = PARITY_NONE
		self.port.stopbits = STOPBITS_ONE
		self.port.rtscts = True 			# Hardware flow control
		return True

	def status(self):
		return KITTStatus(0.7, 0.6, 19, 1)

		if self.port == None:
			raise UnconnectedException

		# Request status
		self.port.write("S\n")
		
		# Read first character
		content = ''
		char_read = self.port.read(1)

		# Read until EoT is detected
		while ord(char_read) != 4:
			content += char_read
			char_read = self.port.read(1)

		# Extract data
		lines = content.split("\n")
		dist = lines[1][1:len(lines[1])].split(' ')
		bat = lines[2][1:len(lines[2])]
		audio = lines[3][6:len(lines[2])]

		# Create status object
		status = KITTStatus(
			float(dist[0])/100, float(dist[1])/100, # Distances
			float(bat)/1000,				 		# Battery voltage
			bool(audio) 							# Audio enabled
			)

		return status

	def drive(self, val):
		return 1
		if self.port == None:
			raise UnconnectedException

		# Range: 135 - 145, 155 - 156
		pwm_drive = 150
		if val > 0:
			pwm_drive += 5 + val_drive*10
		elif val < 0:
			pwm_drive -= 5 - val_drive*10

		pwm_drive = int(round(pwm_drive))

		self.port.write("D" + pwm_steer + " " + pwm_drive)

	def steer(self, val):
		return 1
		if self.port == None:
			raise UnconnectedException

		pwm_steer = int(round(150 + val*50))

		self.port.write("D" + pwm_steer + " " + pwm_drive)

	def __del__(self):
		if not self.port == None:
			port.close()
