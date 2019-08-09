package com.pjinkim.sensors_data_logger;

import android.Manifest;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Handler;
import android.os.PowerManager;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import java.io.IOException;
import java.security.KeyException;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicBoolean;


public class MainActivity extends AppCompatActivity {

    // properties
    private final static String LOG_TAG = MainActivity.class.getName();

    private final static int REQUEST_CODE_ANDROID = 1001;
    private final static int REQUEST_CODE_TIME_SYNC = 1003;
    private final static int SEC_TO_MILL = 1000;

    private static String[] REQUIRED_PERMISSIONS = new String[] {
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.CHANGE_WIFI_STATE,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.ACCESS_FINE_LOCATION
    };

    private IMUConfig mConfig = new IMUConfig();
    private IMUSession mIMUSession;
    private WifiSession mWifiSession;

    private Handler mHandler = new Handler();



    private AtomicBoolean mIsRecording = new AtomicBoolean(false);

    private PowerManager.WakeLock mWakeLock;



    private TextView mLabelAccelDataX, mLabelAccelDataY, mLabelAccelDataZ;
    private TextView mLabelGyroDataX, mLabelGyroDataY, mLabelGyroDataZ;
    private TextView mLabelOrientationX, mLabelOrientationY, mLabelOrientationZ;
    private TextView mLabelWifiRecordNums, mLabelWifiAPNums, mLabelInfoWifi, mLabelInfoWifiInterval;
    private TextView mLabelInfoFile, mLabelInfoPrefix, mLabelReferenceTime;

    private Button mStartStopButton;
    private ProgressDialog mBusyDialog;


    // Android activity lifecycle states
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // initialize screen labels and buttons
        initializeViews();
        mBusyDialog = new ProgressDialog(this);


        // setup sessions
        mIMUSession = new IMUSession(this);


        // battery power setting
        PowerManager powerManager = (PowerManager) getSystemService(Context.POWER_SERVICE);
        mWakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "sensors_data_logger:wakelocktag");
        mWakeLock.acquire();


        // monitor various sensor measurements
        displayIMUSensorMeasurements();
    }


    private void displayIMUSensorMeasurements() {

        // get IMU sensor measurements from IMUSession
        final float[] accel_data = mIMUSession.getAcceMeasure();
        final float[] gyro_data = mIMUSession.getGyroMeasure();
        final float[] magnet_data = mIMUSession.getMagnetMeasure();

        // update current screen (activity)
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mLabelAccelDataX.setText(String.format(Locale.US, "%.3f", accel_data[0]));
                mLabelAccelDataY.setText(String.format(Locale.US, "%.3f", accel_data[1]));
                mLabelAccelDataZ.setText(String.format(Locale.US, "%.3f", accel_data[2]));

                mLabelGyroDataX.setText(String.format(Locale.US, "%.3f", gyro_data[0]));
                mLabelGyroDataY.setText(String.format(Locale.US, "%.3f", gyro_data[1]));
                mLabelGyroDataZ.setText(String.format(Locale.US, "%.3f", gyro_data[2]));
            }
        });

        // determine display update rate (500 ms)
        final long displayInterval = 500;
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                displayIMUSensorMeasurements();
            }
        }, displayInterval);
    }






    @Override
    protected void onResume() {
        super.onResume();
    }


    @Override
    protected void onPause() {
        super.onPause();
    }


    @Override
    protected void onDestroy() {
        if (mIsRecording.get()) {

        }
        if (mWakeLock.isHeld()) {
            mWakeLock.release();
        }
        mIMUSession.unregisterSensors();
        super.onDestroy();
    }


    // methods
    private void startRecording() {

        // output directory for text files
        String outputFolder = null;
        try {
            OutputDirectoryManager folder = new OutputDirectoryManager(mConfig.getFolderPrefix(), mConfig.getSuffix());
            outputFolder = folder.getOutputDirectory();
        } catch (IOException e) {
            showAlertAndStop("Cannot create output folder.");
            e.printStackTrace();
        }

        // start each session
        mIMUSession.startSession(outputFolder);
        //mWifiSession.startSession(outputFolder);
        mIsRecording.set(true);

        //
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mStartStopButton.setEnabled(true);
                mStartStopButton.setText("Stop");
            }
        });
        showToast("Record started");
    }


    public void showAlertAndStop(final String text) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                new AlertDialog.Builder(MainActivity.this)
                        .setTitle(text)
                        .setCancelable(false)
                        .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialogInterface, int i) {
                                stopRecording();
                            }
                        }).show();
            }
        });
    }


    public void showToast(final String text) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(MainActivity.this, text, Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void resetUI {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mStartStopButton.setEnabled(true);
                mStartStopButton.setText(R.string.start_title);
            }
        });
    }


    private void initializeViews() {

        mStartStopButton = (Button) findViewById(R.id.button_start_stop);

        mLabelWifiRecordNums = (TextView) findViewById(R.id.label_wifi_record_num);
        mLabelWifiAPNums = (TextView) findViewById(R.id.label_wifi_beacon_num);
        mLabelInfoWifi = (TextView) findViewById(R.id.label_info_wifi);
        mLabelInfoWifiInterval = (TextView) findViewById(R.id.label_info_wifi_interval);

        mLabelAccelDataX = (TextView) findViewById(R.id.label_accel_X);
        mLabelAccelDataY = (TextView) findViewById(R.id.label_accel_Y);
        mLabelAccelDataZ = (TextView) findViewById(R.id.label_accel_Z);

        mLabelGyroDataX = (TextView) findViewById(R.id.label_gyro_X);
        mLabelGyroDataY = (TextView) findViewById(R.id.label_gyro_Y);
        mLabelGyroDataZ = (TextView) findViewById(R.id.label_gyro_Z);

        mLabelOrientationX = (TextView) findViewById(R.id.label_orientation_X);
        mLabelOrientationY = (TextView) findViewById(R.id.label_orientation_Y);
        mLabelOrientationZ = (TextView) findViewById(R.id.label_orientation_Z);
    }


    private void displayCleanValues() {
        mLabelAccelDataX.setText("0.0");
        mLabelAccelDataY.setText("0.0");
        mLabelAccelDataZ.setText("0.0");

        mLabelGyroDataX.setText("0.0");
        mLabelGyroDataY.setText("0.0");
        mLabelGyroDataZ.setText("0.0");

        mLabelOrientationX.setText("0.0");
        mLabelOrientationY.setText("0.0");
        mLabelOrientationZ.setText("0.0");
    }
}