using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SerialApp
{
	public class FakeKITT
	{
		const double maxspeed = 10 / 3.6;
		const double maxpwmspeed = 15;
		const double multiplier = 0.4;
		DateTime timestamp;
		double speed = 0;
		double distance = 2;

		public void CalculateNewState()
		{
			double distancedriven;
			TimeSpan delta = new TimeSpan(0, 0, 0, 0, 50);//DateTime.Now - timestamp;
			timestamp = DateTime.Now;
			distancedriven = -speed * delta.TotalSeconds * multiplier;
			distance += distancedriven;

			speed = Data.car.ActualPWMSpeed - 150;
			speed = (maxspeed / maxpwmspeed) * speed;

			int intdistance = (int)Math.Round(distance * 100);

			System.Threading.Thread.Sleep(50);
			string send = 'D' + Data.car.ActualPWMHeading.ToString() + ' ' + Data.car.ActualPWMSpeed.ToString() + '\n' + 
							'U' + intdistance.ToString() + ' ' + intdistance.ToString() +
							(char)4;
			//Data.serial.SendString('D' + Data.car.ActualPWMHeading.ToString() + ' ' + Data.car.ActualPWMSpeed.ToString());
			//Data.serial.SendString('U' + intdistance.ToString() + ' ' + intdistance.ToString());
			//Data.serial.SendByte(4); //append EOT to terminate status response
			Data.serial.SendString(send);
		}
	}
}
