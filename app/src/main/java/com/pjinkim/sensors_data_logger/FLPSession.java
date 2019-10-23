package com.pjinkim.sensors_data_logger;

import android.content.Context;
import android.location.Location;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.pjinkim.sensors_data_logger.fio.FileStreamer;

import java.io.BufferedWriter;
import java.io.IOException;
import java.security.KeyException;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicBoolean;

public class FLPSession {

    // properties
    private final static String LOG_TAG = FLPSession.class.getName();

    private final static int DEFAULT_INTERVAL = 2 * 1000; // milli second
    private int mLocationInterval = DEFAULT_INTERVAL;

    private MainActivity mContext;
    private Handler mHandler = new Handler();

    private AtomicBoolean mIsRunning = new AtomicBoolean(false);
    private AtomicBoolean mIsWritingFile = new AtomicBoolean(false);

    private FusedLocationProviderClient mFusedLocationProviderClient;
    private LocationRequest mLocationRequest;
    private double mCurrentLatitude = 0.0;
    private double mCurrentLongitude = 0.0;
    private float mCurrentAccuracy = 0;
    private FLPResultStreamer mFileStreamer;
    private LocationCallback mLocationCallback = new LocationCallback() {
        @Override
        public void onLocationResult(LocationResult locationResult) {

            // check valid location result
            if (locationResult == null) {
                return;
            }

            // save the current location to text file
            List<Location> locationList = locationResult.getLocations();
            if ((locationList.size() > 0) && (mIsWritingFile.get())) {
                try {
                    // the last location in the list is the newest one
                    Location location = locationList.get(locationList.size() - 1);
                    mFileStreamer.addFLPRecord(location);
                    mCurrentLatitude = location.getLatitude();
                    mCurrentLongitude = location.getLongitude();
                    mCurrentAccuracy = location.getAccuracy();
                } catch (IOException | KeyException e) {
                    Log.e(LOG_TAG, "onLocationResult: Cannot add the location result to file");
                    e.printStackTrace();
                }
            }
        }
    };


    // constructor
    public FLPSession(@NonNull MainActivity context, int interval) {
        this.mContext = context;
        this.mLocationInterval = interval;
        mFusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(context);
    }

    FLPSession(@NonNull MainActivity context) {
        this(context, DEFAULT_INTERVAL);
    }


    // methods
    public void startSession(final String streamFolder) {

        // FLP location request parameters
        mLocationRequest = new LocationRequest();
        mLocationRequest.setInterval(mLocationInterval);
        mLocationRequest.setFastestInterval(mLocationInterval / 2);
        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);

        // initialize text file stream
        mIsRunning.set(true);
        try {
            mFusedLocationProviderClient.requestLocationUpdates(mLocationRequest, mLocationCallback, Looper.myLooper());
        } catch (SecurityException e) {
            Log.e(LOG_TAG, "startSession: Error creating location service: " + e.getMessage());
            e.printStackTrace();
        }
        if (streamFolder != null) {
            try {
                mFileStreamer = new FLPResultStreamer(mContext, streamFolder);
                mIsWritingFile.set(true);
            } catch (IOException e) {
                Log.d(LOG_TAG, "startSession: Cannot create file for Fused Location Provider (FLP)");
                e.printStackTrace();
            }
        }
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

        // stop location updates when app is no longer active
        if (mFusedLocationProviderClient != null) {
            mFusedLocationProviderClient.removeLocationUpdates(mLocationCallback);
        }
        mHandler.removeCallbacks(null);
    }


    // definition of 'FLPResultStreamer' class
    class FLPResultStreamer extends FileStreamer {

        // properties
        private BufferedWriter mWriter;


        // constructor
        FLPResultStreamer(final Context context, final String outputFolder) throws IOException {
            super(context, outputFolder);
            addFile("FLP", "FLP.txt");
            mWriter = getFileWriter("FLP");
        }


        // methods
        public void addFLPRecord(final Location location) throws IOException, KeyException {

            // execute the block with only one thread
            synchronized (this) {

                // check 'mWriter' variable
                if (mWriter == null) {
                    throw new KeyException("File writer FLP not found.");
                }

                // record Fused Location Provider (FLP) information in text file
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.append(location.getElapsedRealtimeNanos()); // nano seconds since boot
                stringBuilder.append(String.format(Locale.US, " %.6f %.6f %.6f", location.getLatitude(), location.getLongitude(), location.getAccuracy()));
                stringBuilder.append(" \n");
                mWriter.write(stringBuilder.toString());
            }
        }

        @Override
        public void endFiles() throws IOException {

            // execute the block with only one thread
            synchronized (this) {
                mWriter.flush();
                mWriter.close();
            }
        }
    }


    // getter and setter
    public double getCurrentLatitude() {
        return mCurrentLatitude;
    }

    public double getCurrentLongitude() {
        return mCurrentLongitude;
    }

    public float getCurrentAccuracy() {
        return mCurrentAccuracy;
    }

    public boolean isRunning() {
        return mIsRunning.get();
    }

    public boolean isWritingFile() {
        return mIsWritingFile.get();
    }
}
