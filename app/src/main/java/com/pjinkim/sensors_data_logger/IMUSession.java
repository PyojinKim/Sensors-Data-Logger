package com.pjinkim.sensors_data_logger;

import android.content.Context;
import android.content.Intent;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.net.Uri;
import android.os.Environment;
import android.util.Log;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.security.Key;
import java.security.KeyException;
import java.util.HashMap;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicBoolean;

public class IMUSession implements SensorEventListener {

    // properties
    private final static String LOG_TAG = IMUSession.class.getName();

    private MainActivity mContext;
    private SensorManager mSensorManager;
    private HashMap<String, Sensor> mSensors = new HashMap<>();
    private float mInitialStepCount = -1;
    private FileStreamer mFileStreamer = null;

    private AtomicBoolean mIsRecording = new AtomicBoolean(false);
    private AtomicBoolean mIsWritingFile = new AtomicBoolean(false);

    private float[] mGyroBias = new float[3];
    private float[] mMagnetBias = new float[3];
    private float[] mAcceBias = new float[3];


    // constructor
    public IMUSession(MainActivity context) {

        // initialize object and sensor manager
        mContext = context;
        mSensorManager = (SensorManager) mContext.getSystemService(Context.SENSOR_SERVICE);

        // setup and register various sensors
        mSensors.put("acce", mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER));
        mSensors.put("gyro", mSensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE));
        registerSensors();
    }


    // methods
    private void registerSensors() {
        for (Sensor eachSensor : mSensors.values()) {
            mSensorManager.registerListener(this, eachSensor, SensorManager.SENSOR_DELAY_GAME);
        }
    }

    private void unregisterSensors() {
        for (Sensor eachSensor : mSensors.values()) {
            mSensorManager.unregisterListener(this, eachSensor);
        }
    }

    public void startSession(String streamFolder) {

        // initialize text file streams
        if (streamFolder != null) {
            mFileStreamer = new FileStreamer(mContext, streamFolder);
            try {
                mFileStreamer.addFile("acce", "acce.txt");
                mFileStreamer.addFile("gyro", "gyro.txt");
                mIsWritingFile.set(true);
            } catch (IOException e) {
                mContext.showToast("Error occurs when creating output IMU files.");
                e.printStackTrace();
            }
        }
        mIsRecording.set(true);
    }

    public void stopSession() {

        mIsRecording.set(false);
        if (mIsWritingFile.get()) {

            // close text files and save gyro bias data
            try {
                BufferedWriter gyroBiasEndWriter = mFileStreamer.getFileWriter("gyro_bias");
                gyroBiasEndWriter.write(String.format(Locale.US, "%f %f %f", mGyroBias[0], mGyroBias[1], mGyroBias[2]));
                mFileStreamer.endFiles();
            } catch (IOException e) {
                mContext.showToast("Error occurs when finishing IMU text files.");
                e.printStackTrace();
            }

            // copy accelerometer calibration file to the streaming folder
            try {
                File acceCalibFile = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS) + "/acce_calib.txt");
                File outAcceCalibFile = new File(mFileStreamer.getOutputFolder() + "/acce_calib.txt");
                if (acceCalibFile.exists()) {
                    FileInputStream istr = new FileInputStream(acceCalibFile);
                    FileOutputStream ostr = new FileOutputStream(outAcceCalibFile);
                    FileChannel ichn = istr.getChannel();
                    FileChannel ochn = ostr.getChannel();
                    ichn.transferTo(0, ichn.size(), ochn);
                    istr.close();
                    ostr.close();

                    Intent scanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
                    scanIntent.setData(Uri.fromFile(outAcceCalibFile));
                    mContext.sendBroadcast(scanIntent);
                }
            } catch (IOException e) {
                mContext.showToast("Error occurs when copying accelerometer calibration text files.");
                e.printStackTrace();
            }

            // reset some properties
            mIsWritingFile.set(false);
            mFileStreamer = null;
        }
        mInitialStepCount = -1;
    }

    @Override
    public void onSensorChanged(final SensorEvent sensorEvent) {

        // set some variables
        float[] values = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
        boolean isFileSaved = (mIsRecording.get() && mIsWritingFile.get());

        // update each sensor measurements
        long timestamp = sensorEvent.timestamp;
        Sensor eachSensor = sensorEvent.sensor;
        try {
            switch (eachSensor.getType()) {
                case Sensor.TYPE_ACCELEROMETER:
                    if (isFileSaved) {
                        mFileStreamer.addRecord(timestamp, "acce", 3, sensorEvent.values);
                    }
                    break;

                case Sensor.TYPE_GYROSCOPE:
                    if (isFileSaved) {
                        mFileStreamer.addRecord(timestamp, "gyro", 3, sensorEvent.values);
                    }
                    break;
            }
        } catch (IOException | KeyException e) {
            Log.d(LOG_TAG, "onSensorChanged: Something is wrong.");
            e.printStackTrace();
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }


    // getter and setter
    public boolean isRecording() {
        return mIsRecording.get();
    }

    public float[] getGyroBias() {
        return mGyroBias;
    }

    public float[] getMagnetBias() {
        return mMagnetBias;
    }

    public float[] getAcceBias() {
        return mAcceBias;
    }
}




            /*if (eachSensor.getType() == ) {
                rawAccelDataX = sensorEvent.values[0];
                rawAccelDataY = sensorEvent.values[1];
                rawAccelDataZ = sensorEvent.values[2];

                axLabel.setText(String.format("%.3f", rawAccelDataX));
                ayLabel.setText(String.format("%.3f", rawAccelDataY));
                azLabel.setText(String.format("%.3f", rawAccelDataZ));
            } else if (eachSensor.getType() == ) {
                rawGyroDataX = sensorEvent.values[0];
                rawGyroDataY = sensorEvent.values[1];
                rawGyroDataZ = sensorEvent.values[2];

                wxLabel.setText(String.format("%.3f", rawGyroDataX));
                wyLabel.setText(String.format("%.3f", rawGyroDataY));
                wzLabel.setText(String.format("%.3f", rawGyroDataZ));
            } else {

            } */