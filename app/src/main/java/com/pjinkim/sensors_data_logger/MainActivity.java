package com.pjinkim.sensors_data_logger;

import android.Manifest;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.os.Handler;
import android.os.PowerManager;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

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

    private Handler mHandler = new Handler();

    private Button mStartStopButton;
    private ProgressDialog mBusyDialog;

    private AtomicBoolean mIsRecording = new AtomicBoolean(false);

    private PowerManager.WakeLock mWakeLock;



    private float rawAccelDataX, rawAccelDataY, rawAccelDataZ, rawGyroDataX, rawGyroDataY, rawGyroDataZ;
    private TextView axLabel, ayLabel, azLabel, wxLabel, wyLabel, wzLabel, rxLabel, ryLabel, rzLabel, mxLabel, myLabel, mzLabel;


    // Android activity lifecycle states
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initializeViews();

        //


        //

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



    // methods
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

    public void showToast(final String text) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(MainActivity.this, text, Toast.LENGTH_SHORT).show();
            }
        });
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
}
