package com.pjinkim.sensors_data_logger;

import android.content.Context;
import android.os.BatteryManager;
import android.os.Handler;
import android.util.Log;

import androidx.annotation.NonNull;

import com.pjinkim.sensors_data_logger.fio.FileStreamer;

import java.io.BufferedWriter;
import java.io.IOException;
import java.security.KeyException;
import java.util.concurrent.atomic.AtomicBoolean;

public class BatterySession implements Runnable {

    // properties
    private final static String LOG_TAG = BatterySession.class.getName();

    private final static int DEFAULT_INTERVAL = 60 * 1000; // milli second
    private int mBatteryInterval = DEFAULT_INTERVAL;

    private MainActivity mContext;
    private Handler mHandler = new Handler();

    private AtomicBoolean mIsRunning = new AtomicBoolean(false);
    private AtomicBoolean mIsWritingFile = new AtomicBoolean(false);
    private double mBatteryLevel = 0.0;

    private BatteryManager mBatteryManager;
    private BatteryResultStreamer mFileStreamer;


    // constructor
    public BatterySession(@NonNull MainActivity context, int interval) {
        this.mContext = context;
        this.mBatteryInterval = interval;
        mBatteryManager = (BatteryManager) mContext.getSystemService(Context.BATTERY_SERVICE);
    }

    BatterySession(@NonNull MainActivity context) {
        this(context, DEFAULT_INTERVAL);
    }


    // methods
    public void startSession(final String streamFolder) {

        // initialize text file stream
        mIsRunning.set(true);
        if (streamFolder != null) {
            try {
                mFileStreamer = new BatteryResultStreamer(mContext, streamFolder);
                mIsWritingFile.set(true);
            } catch (IOException e) {
                mContext.showToast("Cannot create file for battery level");
                e.printStackTrace();
            }
        }
        run();
    }


    public void stopSession() {

        // close text file and reset variables
        if (mIsWritingFile.get()) {
            try {
                mFileStreamer.endFiles();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        mIsWritingFile.set(false);
        mIsRunning.set(false);
        mHandler.removeCallbacks(null);
    }


    public void singleScan() {

        // read current battery level
        if (!mIsRunning.get()) {
            return;
        }
        mBatteryLevel = mBatteryManager.getLongProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        Log.i(LOG_TAG, "singleScan: Battery level received. Current battery level: " + mBatteryLevel + " %.");


        // save the battery level results to text file
        if (mIsWritingFile.get()) {
            try {
                mFileStreamer.addBatteryRecord(mBatteryLevel);
            } catch (IOException | KeyException e) {
                Log.e(LOG_TAG, "singleScan: Cannot add the battery result to file");
                e.printStackTrace();
            }
        }
    }


    @Override
    public void run() {
        singleScan();
        if (mIsRunning.get()) {
            mHandler.postDelayed(this, mBatteryInterval);
        }
    }


    // definition of 'BatteryResultStreamer' class
    class BatteryResultStreamer extends FileStreamer {

        // properties
        private BufferedWriter mWriter;


        // constructor
        BatteryResultStreamer(final Context context, final String outputFolder) throws IOException {
            super(context, outputFolder);
            addFile("battery", "battery.txt");
            mWriter = getFileWriter("battery");
        }


        // methods
        public void addBatteryRecord(final double batteryLevel) throws IOException, KeyException {

            // execute the block with only one thread
            synchronized (this) {

                // check 'mWriter' variable
                if (mWriter == null) {
                    throw new KeyException("File writer battery not found.");
                }

                // record battery level in text file
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.append(System.currentTimeMillis());
                stringBuilder.append('\t');
                stringBuilder.append(String.valueOf(batteryLevel));
                stringBuilder.append('\n');
                mWriter.write(stringBuilder.toString());
            }
        }

        @Override
        public void endFiles() throws IOException {

            // execute the block with only one thread
            synchronized (this) {
                mWriter.write("-1");
                mWriter.flush();
                mWriter.close();
            }
        }
    }


    // getter and setter
    public void setBatteryInterval(int newInterval) {
        mBatteryInterval = newInterval;
    }

    public boolean isRunning() {
        return mIsRunning.get();
    }

    public boolean isWritingFile() {
        return mIsWritingFile.get();
    }
}
