import numpy as np
import math

class StateSpaceModel:
	def __init__(self):
		# Initialize state-space model
		self.A = np.matrix("0 1;-0.07233 -3.495");
		self.B = np.matrix("1.634;-8.287");
		self.C = np.matrix("1 0");
		self.K = np.matrix("-0.1007 0.2692");
		self.L = np.matrix("3.2045;-0.0537");

		self.R = np.linalg.inv(
			self.C * np.linalg.inv(
				self.B*self.K - self.A
			) * self.B
		)

	def slope(self, x, r, y, control=True):
		if control == True:
			control = 1
		else:
			control = 0

		return (
			(self.A - self.L*self.C - control*self.B*self.K) * x +
			control*self.B*self.R*r +
			self.L*y
		)

	def output(self, x, r, control=True):
		if control == True:
			control = 1
		else:
			control = 0
			
		return control*(
			self.R*r - self.K*x
		)

class LowPassFilter:
	def __init__(self, freq, dt):
		# Coefficients
		self.a = 1/(2*np.pi*freq*dt);
		self.c1 = (2*math.pow(self.a,2)+2*self.a)/(math.pow(self.a,2)+2*self.a+1);
		self.c2 = (-math.pow(self.a,2))/(math.pow(self.a,2)+2*self.a+1);
		self.c3 = 1/(math.pow(self.a,2)+2*self.a+1);

	def eval(self, data, new_value):
		new_value *= self.c3;

		if len(data) >= 1:
			new_value += self.c1*data[-1]

		if len(data) >= 2:
			new_value += self.c2*data[-2]

		return new_value

class UnrealisticValueFilter:
	def __init__(self, dev_max):
		self.dev_max = dev_max

	def eval(self, data, new_value):
		if len(data) < 3:
			return new_value
		else:
			# Calculate prediction
			pred = 5/2*data[-1] - 2*data[-2] + 1/2*data[3]

			if abs(pred - new_value) > dev_max:
				# Exceeded maximum deviation
				new_value = pred

			return new_value
