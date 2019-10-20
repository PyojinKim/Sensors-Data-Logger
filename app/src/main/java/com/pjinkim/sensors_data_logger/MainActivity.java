package com.pjinkim.sensors_data_logger;

import android.Manifest;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.PowerManager;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import com.google.atap.tangoservice.Tango;
import com.pjinkim.sensors_data_logger.fio.OutputDirectoryManager;
import com.pjinkim.sensors_data_logger.tango.TangoSession;

import java.io.IOException;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.atomic.AtomicBoolean;


public class MainActivity extends AppCompatActivity implements WifiSession.WifiScannerCallback {

    // properties
    private final static String LOG_TAG = MainActivity.class.getName();

    private final static int REQUEST_CODE_ANDROID = 1001;
    private final static int REQUEST_CODE_AREA_LEARNING = 1002;
    private static String[] REQUIRED_PERMISSIONS = new String[] {
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.CHANGE_WIFI_STATE,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.VIBRATE,
            Manifest.permission.CAMERA
    };

    private IMUConfig mConfig = new IMUConfig();
    private IMUSession mIMUSession;
    private WifiSession mWifiSession;
    private BatterySession mBatterySession;
    private FLPSession mFLPSession;
    private TangoSession mTangoSession;

    private Handler mHandler = new Handler();
    private AtomicBoolean mIsRecording = new AtomicBoolean(false);
    private PowerManager.WakeLock mWakeLock;

    private TextView mLabelAccelDataX, mLabelAccelDataY, mLabelAccelDataZ;
    private TextView mLabelAccelBiasX, mLabelAccelBiasY, mLabelAccelBiasZ;
    private TextView mLabelGyroDataX, mLabelGyroDataY, mLabelGyroDataZ;
    private TextView mLabelGyroBiasX, mLabelGyroBiasY, mLabelGyroBiasZ;
    private TextView mLabelMagnetDataX, mLabelMagnetDataY, mLabelMagnetDataZ;
    private TextView mLabelMagnetBiasX, mLabelMagnetBiasY, mLabelMagnetBiasZ;

    private TextView mLabelWifiAPNums, mLabelWifiScanInterval;
    private TextView mLabelWifiNameSSID, mLabelWifiRSSI;

    private Button mStartStopButton;
    private TextView mLabelInterfaceTime;
    private Timer mInterfaceTimer = new Timer();
    private int mSecondCounter = 0;


    // Android activity lifecycle states
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // initialize screen labels and buttons
        initializeViews();


        // setup sessions
        mIMUSession = new IMUSession(this);
        mWifiSession = new WifiSession(this);
        mBatterySession = new BatterySession(this);
        mFLPSession = new FLPSession(this);
        mTangoSession = new TangoSession(this);


        // battery power setting
        PowerManager powerManager = (PowerManager) getSystemService(Context.POWER_SERVICE);
        mWakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "sensors_data_logger:wakelocktag");
        mWakeLock.acquire();


        // monitor various sensor measurements
        displayIMUSensorMeasurements();
        mLabelInterfaceTime.setText(R.string.ready_title);
    }


    @Override
    protected void onResume() {
        super.onResume();

        // request Android permission
        if (!hasPermissions(this, REQUIRED_PERMISSIONS)) {
            requestPermissions(REQUIRED_PERMISSIONS, REQUEST_CODE_ANDROID);
        }

        // request Tango permission
        if (!Tango.hasPermission(this, Tango.PERMISSIONTYPE_ADF_LOAD_SAVE)) {
            startActivityForResult(
                    Tango.getRequestPermissionIntent(Tango.PERMISSIONTYPE_ADF_LOAD_SAVE),
                    REQUEST_CODE_AREA_LEARNING
            );
        }
        if (mTangoSession.isInitialized()) {
            mTangoSession.updateADFList();
        }

        updateConfig();
    }


    @Override
    protected void onPause() {
        super.onPause();
    }


    @Override
    protected void onDestroy() {
        if (mIsRecording.get()) {
            stopRecording();
        }
        if (mWakeLock.isHeld()) {
            mWakeLock.release();
        }
        mIMUSession.unregisterSensors();
        super.onDestroy();
    }


    // methods
    public void startStopRecording(View view) {
        if (!mIsRecording.get()) {

            // start recording sensor measurements when button is pressed
            startRecording();

            // start interface timer on display
            mSecondCounter = 0;
            mInterfaceTimer.schedule(new TimerTask() {
                @Override
                public void run() {
                    mSecondCounter += 1;
                }
            }, 0, 1000);

        } else {

            // stop recording sensor measurements when button is pressed
            stopRecording();

            // stop interface timer on display
            mInterfaceTimer.cancel();
            mLabelInterfaceTime.setText(R.string.ready_title);
        }
    }


    private void startRecording() {

        // output directory for text files
        String outputFolder = null;
        try {
            OutputDirectoryManager folder = new OutputDirectoryManager(mConfig.getFolderPrefix(), mConfig.getSuffix());
            outputFolder = folder.getOutputDirectory();
            mConfig.setOutputFolder(outputFolder);
        } catch (IOException e) {
            showAlertAndStop("Cannot create output folder.");
            e.printStackTrace();
        }

        // start each session
        mIMUSession.startSession(outputFolder);
        mWifiSession.startSession(outputFolder);
        mBatterySession.startSession(outputFolder);
        mFLPSession.startSession(outputFolder);
        mTangoSession.startSession(outputFolder);
        mIsRecording.set(true);

        // update Start/Stop button UI
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mStartStopButton.setEnabled(true);
                mStartStopButton.setText(R.string.stop_title);
            }
        });
        showToast("Recording starts!");
    }


    protected void stopRecording() {
        mHandler.post(new Runnable() {
            @Override
            public void run() {

                // stop each session
                mIMUSession.stopSession();
                mWifiSession.stopSession();
                mBatterySession.stopSession();
                mFLPSession.stopSession();
                mTangoSession.stopSession();
                mIsRecording.set(false);

                // update screen UI and button
                showToast("Recording stops!");
                resetUI();
            }
        });
    }


    private static boolean hasPermissions(Context context, String... permissions) {

        // check Android hardware permissions
        for (String permission : permissions) {
            if (ContextCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }
        return true;
    }


    private void updateConfig() {
        final int MICRO_TO_SEC = 1000;
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


    private void resetUI() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mStartStopButton.setEnabled(true);
                mStartStopButton.setText(R.string.start_title);
                mLabelWifiAPNums.setText("N/A");
                mLabelWifiScanInterval.setText("0");
                mLabelWifiNameSSID.setText("N/A");
                mLabelWifiRSSI.setText("N/A");
            }
        });
    }


    @Override
    public void onBackPressed() {

        // nullify back button when recording starts
        if (!mIsRecording.get()) {
            super.onBackPressed();
        }
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        if (requestCode != REQUEST_CODE_ANDROID) {
            return;
        }

        for (int grantResult : grantResults) {
            if (grantResult == PackageManager.PERMISSION_DENIED) {
                showToast("Permission not granted");
                finish();
                return;
            }
        }
    }


    private void initializeViews() {

        mLabelAccelDataX = (TextView) findViewById(R.id.label_accel_X);
        mLabelAccelDataY = (TextView) findViewById(R.id.label_accel_Y);
        mLabelAccelDataZ = (TextView) findViewById(R.id.label_accel_Z);

        mLabelAccelBiasX = (TextView) findViewById(R.id.label_accel_bias_X);
        mLabelAccelBiasY = (TextView) findViewById(R.id.label_accel_bias_Y);
        mLabelAccelBiasZ = (TextView) findViewById(R.id.label_accel_bias_Z);

        mLabelGyroDataX = (TextView) findViewById(R.id.label_gyro_X);
        mLabelGyroDataY = (TextView) findViewById(R.id.label_gyro_Y);
        mLabelGyroDataZ = (TextView) findViewById(R.id.label_gyro_Z);

        mLabelGyroBiasX = (TextView) findViewById(R.id.label_gyro_bias_X);
        mLabelGyroBiasY = (TextView) findViewById(R.id.label_gyro_bias_Y);
        mLabelGyroBiasZ = (TextView) findViewById(R.id.label_gyro_bias_Z);

        mLabelMagnetDataX = (TextView) findViewById(R.id.label_magnet_X);
        mLabelMagnetDataY = (TextView) findViewById(R.id.label_magnet_Y);
        mLabelMagnetDataZ = (TextView) findViewById(R.id.label_magnet_Z);

        mLabelMagnetBiasX = (TextView) findViewById(R.id.label_magnet_bias_X);
        mLabelMagnetBiasY = (TextView) findViewById(R.id.label_magnet_bias_Y);
        mLabelMagnetBiasZ = (TextView) findViewById(R.id.label_magnet_bias_Z);

        mLabelWifiAPNums = (TextView) findViewById(R.id.label_wifi_number_ap);
        mLabelWifiScanInterval = (TextView) findViewById(R.id.label_wifi_scan_interval);
        mLabelWifiNameSSID = (TextView) findViewById(R.id.label_wifi_SSID_name);
        mLabelWifiRSSI = (TextView) findViewById(R.id.label_wifi_RSSI);

        mStartStopButton = (Button) findViewById(R.id.button_start_stop);
        mLabelInterfaceTime = (TextView) findViewById(R.id.label_interface_time);
    }


    private void displayIMUSensorMeasurements() {

        // get IMU sensor measurements from IMUSession
        final float[] acce_data = mIMUSession.getAcceMeasure();
        final float[] acce_bias = mIMUSession.getAcceBias();

        final float[] gyro_data = mIMUSession.getGyroMeasure();
        final float[] gyro_bias = mIMUSession.getGyroBias();

        final float[] magnet_data = mIMUSession.getMagnetMeasure();
        final float[] magnet_bias = mIMUSession.getMagnetBias();

        // update current screen (activity)
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mLabelAccelDataX.setText(String.format(Locale.US, "%.3f", acce_data[0]));
                mLabelAccelDataY.setText(String.format(Locale.US, "%.3f", acce_data[1]));
                mLabelAccelDataZ.setText(String.format(Locale.US, "%.3f", acce_data[2]));

                mLabelAccelBiasX.setText(String.format(Locale.US, "%.3f", acce_bias[0]));
                mLabelAccelBiasY.setText(String.format(Locale.US, "%.3f", acce_bias[1]));
                mLabelAccelBiasZ.setText(String.format(Locale.US, "%.3f", acce_bias[2]));

                mLabelGyroDataX.setText(String.format(Locale.US, "%.3f", gyro_data[0]));
                mLabelGyroDataY.setText(String.format(Locale.US, "%.3f", gyro_data[1]));
                mLabelGyroDataZ.setText(String.format(Locale.US, "%.3f", gyro_data[2]));

                mLabelGyroBiasX.setText(String.format(Locale.US, "%.3f", gyro_bias[0]));
                mLabelGyroBiasY.setText(String.format(Locale.US, "%.3f", gyro_bias[1]));
                mLabelGyroBiasZ.setText(String.format(Locale.US, "%.3f", gyro_bias[2]));

                mLabelMagnetDataX.setText(String.format(Locale.US, "%.3f", magnet_data[0]));
                mLabelMagnetDataY.setText(String.format(Locale.US, "%.3f", magnet_data[1]));
                mLabelMagnetDataZ.setText(String.format(Locale.US, "%.3f", magnet_data[2]));

                mLabelMagnetBiasX.setText(String.format(Locale.US, "%.3f", magnet_bias[0]));
                mLabelMagnetBiasY.setText(String.format(Locale.US, "%.3f", magnet_bias[1]));
                mLabelMagnetBiasZ.setText(String.format(Locale.US, "%.3f", magnet_bias[2]));

                mLabelInterfaceTime.setText(interfaceIntTime(mSecondCounter));
            }
        });

        // determine display update rate (100 ms)
        final long displayInterval = 100;
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                displayIMUSensorMeasurements();
            }
        }, displayInterval);
    }


    @Override
    public void displayWifiScanMeasurements(final int currentApNums, final float currentScanInterval, final String nameSSID, final int RSSI) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mLabelWifiAPNums.setText(String.valueOf(currentApNums));
                mLabelWifiScanInterval.setText(String.format(Locale.US, "%.1f", currentScanInterval));
                mLabelWifiNameSSID.setText(String.valueOf(nameSSID));
                mLabelWifiRSSI.setText(String.valueOf(RSSI));
            }
        });
    }


    private String interfaceIntTime(final int second) {

        // check second input
        if (second < 0) {
            showAlertAndStop("Second cannot be negative.");
        }

        // extract hour, minute, second information from second
        int input = second;
        int hours = input / 3600;
        input = input % 3600;
        int mins = input / 60;
        int secs = input % 60;

        // return interface int time
        return String.format(Locale.US, "%02d:%02d:%02d", hours, mins, secs);
    }
}