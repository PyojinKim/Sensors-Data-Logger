package com.pjinkim.sensors_data_logger.tango;

import android.util.Log;

import com.google.atap.tangoservice.Tango;
import com.google.atap.tangoservice.TangoOutOfDateException;
import com.google.tango.support.TangoSupport;
import com.pjinkim.sensors_data_logger.FileStreamer;
import com.pjinkim.sensors_data_logger.MainActivity;

import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Handler;

public class TangoSession {

    // properties
    private final static String LOG_TAG = TangoSession.class.getName();

    private final static float mulNanoToSec = 1000000000;

    private MainActivity mContext;
    private Handler mHandler = new Handler();

    private AtomicBoolean mIsRunning = new AtomicBoolean(false);
    private AtomicBoolean mIsWritingFile = new AtomicBoolean(false);
    private AtomicBoolean mIsTangoInitialized = new AtomicBoolean(false);
    private AtomicBoolean mIsLocalizedToADF = new AtomicBoolean(false);
    private AtomicBoolean mIsTangoConnected = new AtomicBoolean(false);
    private AtomicInteger mLocalizeCounter = new AtomicInteger(0);

    private Tango mTango;
    private FileStreamer mFileStreamer = null;


    // constructor
    public TangoSession(final MainActivity context) {
        this.mContext = context;
        this.mTango = new Tango(mContext, new Runnable() {
            @Override
            public void run() {
                try {
                    TangoSupport.initialize(mTango);
                    mIsTangoInitialized.set(true);
                } catch (TangoOutOfDateException e) {
                    Log.e(LOG_TAG, "run: ", );
                }
            }
        });
    }





    // methods





    // getter and setter


}
