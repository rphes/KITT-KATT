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
		DateTime timestamp;
		double speed;
		double distance = 2;

		public void CalculateNewState()
		{
			double distancedriven;
			TimeSpan delta = new TimeSpan(0, 0, 0, 0, 100);//DateTime.Now - timestamp;
			timestamp = DateTime.Now;
			distancedriven = -speed * delta.TotalSeconds;
			distance += distancedriven;

			if (Data.car.ActualPWMSpeed > 155)
				speed = Data.car.ActualPWMSpeed - 155;
			else if (Data.car.ActualPWMSpeed < 145)
				speed = Data.car.ActualPWMSpeed - 145;
			else
				speed = 0;

			speed = maxspeed / maxpwmspeed * speed;

			int intdistance = (int)Math.Round(distance * 100);

			Data.serial.SendString('D' + Data.car.ActualPWMHeading.ToString() + ' ' + Data.car.ActualPWMSpeed.ToString());
			Data.serial.SendString('U' + intdistance.ToString() + ' ' + intdistance.ToString());
		}
	}
}
