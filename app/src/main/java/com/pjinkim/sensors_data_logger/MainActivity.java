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

public class MainActivity extends AppCompatActivity implements SensorEventListener {

    //
    private SensorManager mSensorManager;
    private Sensor mAccelerometer;

    private long timestamp;
    private float rawAccelDataX, rawAccelDataY, rawAccelDataZ;
    private TextView axLabel, ayLabel, azLabel;

    private static final String TAG = "MainActivity";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initializeViews();

        mSensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        if (mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) != null) {

            mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
            mSensorManager.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_GAME);
        } else {

        }


    }

    public void initializeViews() {
        axLabel = (TextView) findViewById(R.id.axLabel);
        ayLabel = (TextView) findViewById(R.id.ayLabel);
        azLabel = (TextView) findViewById(R.id.azLabel);
    }

    // onResume() register the accelerometer for listening the events
    protected void onResume() {
        super.onResume();
        mSensorManager.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_GAME);
    }

    // onPause() unregister the accelerometer for stop listening the events
    protected void onPause() {
        super.onPause();
        mSensorManager.unregisterListener(this);
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }

    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {

        // clean and update current accelerometer measurements
        displayCleanValues();

        timestamp = sensorEvent.timestamp;
        rawAccelDataX = sensorEvent.values[0];
        rawAccelDataY = sensorEvent.values[1];
        rawAccelDataZ = sensorEvent.values[2];

        axLabel.setText(String.format("%.3f", rawAccelDataX));
        ayLabel.setText(String.format("%.3f", rawAccelDataY));
        azLabel.setText(String.format("%.3f", rawAccelDataZ));

        Log.d(TAG, "onSensorChanged: " + timestamp);



    }

    public void displayCleanValues() {
        axLabel.setText("0.0");
        ayLabel.setText("0.0");
        azLabel.setText("0.0");
    }







}
