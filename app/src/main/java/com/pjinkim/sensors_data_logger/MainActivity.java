package com.pjinkim.sensors_data_logger;

import android.app.Activity;
import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import java.io.IOException;
import java.security.KeyException;
import java.util.HashMap;
import java.util.concurrent.atomic.AtomicBoolean;

public class MainActivity extends AppCompatActivity implements SensorEventListener {

    private final static String LOG_TAG = MainActivity.class.getName();

    private SensorManager mSensorManager;
    private HashMap<String, Sensor> mSensors = new HashMap<>();

    private AtomicBoolean mIsRecording = new AtomicBoolean(false);
    private AtomicBoolean mIsWritingFile = new AtomicBoolean(false);

    private float[] mGyroBias = new float[3];
    private float[] mMagnetBias = new float[3];
    private float[] mAcceBias = new float[3];

    private long timestamp;
    private float rawAccelDataX, rawAccelDataY, rawAccelDataZ, rawGyroDataX, rawGyroDataY, rawGyroDataZ;
    private TextView axLabel, ayLabel, azLabel, wxLabel, wyLabel, wzLabel, rxLabel, ryLabel, rzLabel, mxLabel, myLabel, mzLabel;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initializeViews();

        // setup sensors' configuration
        mSensorManager = (SensorManager) this.getSystemService(Context.SENSOR_SERVICE);
        mSensors.put("acce", mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER));
        mSensors.put("gyro", mSensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE));
    }

    private void initializeViews() {
        axLabel = (TextView) findViewById(R.id.axLabel);
        ayLabel = (TextView) findViewById(R.id.ayLabel);
        azLabel = (TextView) findViewById(R.id.azLabel);

        wxLabel = (TextView) findViewById(R.id.wxLabel);
        wyLabel = (TextView) findViewById(R.id.wyLabel);
        wzLabel = (TextView) findViewById(R.id.wzLabel);

        rxLabel = (TextView) findViewById(R.id.rxLabel);
        ryLabel = (TextView) findViewById(R.id.ryLabel);
        rzLabel = (TextView) findViewById(R.id.rzLabel);
    }

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


    @Override
    protected void onResume() {
        super.onResume();
        registerSensors();
    }


    @Override
    protected void onPause() {
        super.onPause();
        unregisterSensors();
    }


    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {

        // update each sensor measurements
        timestamp = sensorEvent.timestamp;
        Sensor eachSensor = sensorEvent.sensor;
        try {
            if (eachSensor.getType() == Sensor.TYPE_ACCELEROMETER) {
                rawAccelDataX = sensorEvent.values[0];
                rawAccelDataY = sensorEvent.values[1];
                rawAccelDataZ = sensorEvent.values[2];

                axLabel.setText(String.format("%.3f", rawAccelDataX));
                ayLabel.setText(String.format("%.3f", rawAccelDataY));
                azLabel.setText(String.format("%.3f", rawAccelDataZ));
            } else if (eachSensor.getType() == Sensor.TYPE_GYROSCOPE) {
                rawGyroDataX = sensorEvent.values[0];
                rawGyroDataY = sensorEvent.values[1];
                rawGyroDataZ = sensorEvent.values[2];

                wxLabel.setText(String.format("%.3f", rawGyroDataX));
                wyLabel.setText(String.format("%.3f", rawGyroDataY));
                wzLabel.setText(String.format("%.3f", rawGyroDataZ));
            } else {

            }
        } catch (Exception e) {
            Log.d(LOG_TAG, "onSensorChanged: Something is wrong.");
        }



        Log.d(LOG_TAG, "onSensorChanged: " + timestamp);




    }

    private void displayCleanValues() {
        axLabel.setText("0.0");
        ayLabel.setText("0.0");
        azLabel.setText("0.0");

        wxLabel.setText("0.0");
        wyLabel.setText("0.0");
        wzLabel.setText("0.0");

        rxLabel.setText("0.0");
        ryLabel.setText("0.0");
        rzLabel.setText("0.0");
    }


    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }
}
