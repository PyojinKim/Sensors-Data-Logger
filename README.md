# Sensors Data Logger #

This is a simple application to allow the easy capture of IMU and other sensor data on Android devices for offline use.
I wanted to play around with data from various sensors such as IMU in Android Studio 3.4.2, API level 26 for Android devices.

![Sensors Data Logger](https://github.com/PyojinKim/Sensors-Data-Logger/blob/master/screenshot.png)

The aspects of the IMU that you can log follow directly from the sensor API documentation provided by Android developer website.
For more details, see the Android developer sensor API documentation [here](https://developer.android.com/guide/topics/sensors/sensors_overview).


## Usage Notes ##

The txt files are produced automatically after pressing Stop button.
This project is written Java under Android Studio Version 3.4.2 for Android 8.0 (API level 26) tested with Samsung Galaxy S9.
It doesn't currently check for sensor availability before logging.


## Reference Frames and Device Attitude ##

The IMU body frame attached to the device is shown in the above figure: [here](https://developer.android.com/guide/topics/sensors/sensors_overview#sensors-coords).


## Output Format ##

I have chosen the following output formats, but they are easy to modify if you find something else more convenient.

* acce.txt: `timestamp, acceleration_x, acceleration_y, acceleration_z \n`
* acce_uncalib.txt: `timestamp, acceleration_x, acceleration_y, acceleration_z \n`
* gyro.txt: `timestamp, gyro_x, gyro_y, gyro_z \n`
* gyro_uncalib.txt: `timestamp, gyro_x, gyro_y, gyro_z \n`
* linacce.txt: `timestamp, user_acceleration_x, user_acceleration_y, user_acceleration_z \n`
* gravity.txt: `timestamp, gravity_x, gravity_y, gravity_z \n`
* magnet.txt: `timestamp, magnetic_x, magnetic_y, magnetic_z \n`
* magnet_uncalib.txt: `timestamp, magnetic_x, magnetic_y, magnetic_z \n`
* rv.txt: `timestamp, quaternion_x, quaternion_y, quaternion_z, quaternion_w \n`
* game_rv.txt: `timestamp, quaternion_x, quaternion_y, quaternion_z, quaternion_w \n`
* magnetic_rv.txt: `timestamp, quaternion_x, quaternion_y, quaternion_z, quaternion_w \n`
* acce_bias.txt: `timestamp, acce_bias_x, acce_bias_y, acce_bias_z \n`
* gyro_bias.txt: `timestamp, gyro_bias_x, gyro_bias_y, gyro_bias_z \n`
* magnet_bias.txt: `timestamp, magnet_bias_x, magnet_bias_y, magnet_bias_z \n`
* wifi.txt: `timestamp, BSSID, RSSI \n`
* step.txt: `timestamp, step_count \n`
* pressure.txt: `timestamp, pressure \n`
* battery.txt: `timestamp, battery_level \n`

You will have to modify the source code if you prefer logging one of those instead of quaternion format.


## Offline Matlab Visualization ##

The ability to experiment with different algorithms to process the IMU data is the reason that I created this project in the first place.
I have included an example script that you can use to parse and visualize the data that comes from Sensors Data Logger.
Look under the Visualization directory to check it out.
You can run the script by typing the following in your terminal:

    run main_script.m



