package com.pjinkim.sensors_data_logger.tango;

import android.content.Context;
import android.util.Log;

import com.google.atap.tangoservice.Tango;
import com.google.atap.tangoservice.TangoAreaDescriptionMetaData;
import com.google.atap.tangoservice.TangoConfig;
import com.google.atap.tangoservice.TangoCoordinateFramePair;
import com.google.atap.tangoservice.TangoErrorException;
import com.google.atap.tangoservice.TangoEvent;
import com.google.atap.tangoservice.TangoInvalidException;
import com.google.atap.tangoservice.TangoOutOfDateException;
import com.google.atap.tangoservice.TangoPointCloudData;
import com.google.atap.tangoservice.TangoPoseData;
import com.google.atap.tangoservice.TangoXyzIjData;
import com.google.tango.support.TangoSupport;
import com.pjinkim.sensors_data_logger.fio.FileStreamer;
import com.pjinkim.sensors_data_logger.MainActivity;
import com.pjinkim.sensors_data_logger.rajawali.ScenePoseCalculator;

import org.rajawali3d.math.Matrix4;

import java.io.BufferedWriter;
import java.io.IOException;
import java.security.KeyException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

public class TangoSession {

    // properties
    private final static String LOG_TAG = TangoSession.class.getName();
    private final static float mulNanoToSec = 1000000000;

    private MainActivity mContext;

    private AtomicBoolean mIsRunning = new AtomicBoolean(false);
    private AtomicBoolean mIsWritingFile = new AtomicBoolean(false);
    private AtomicBoolean mIsTangoInitialized = new AtomicBoolean(false);
    private AtomicBoolean mIsLocalizedToADF = new AtomicBoolean(false);
    private AtomicBoolean mIsTangoConnected = new AtomicBoolean(false);
    private AtomicInteger mLocalizeCounter = new AtomicInteger(0);

    private AtomicBoolean mIsAreaLearningMode = new AtomicBoolean(true);
    private AtomicBoolean mIsADFEnabled = new AtomicBoolean(false);

    private Tango mTango;
    private HashMap<String, String> mAdfList = new HashMap<>();
    private Matrix4 mInitialTransform = new Matrix4();
    private TangoResultStreamer mFileStreamer;


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
                    Log.e(LOG_TAG, "Out of date.");
                } catch (TangoErrorException e) {
                    Log.e(LOG_TAG, "Tango error.");
                } catch (TangoInvalidException e) {
                    Log.e(LOG_TAG, "Tango invalid.");
                }
            }
        });
    }


    // methods
    public void startSession(final String streamFolder) {

        // execute the block with only one thread
        mIsRunning.set(true);
        synchronized (this) {
            try {
                TangoConfig tangoConfig = setupTangoConfig(mTango);
                mTango.connect(tangoConfig);

                // initialize text file stream
                if (streamFolder != null) {
                    mFileStreamer = new TangoResultStreamer(mContext, streamFolder);
                    mIsWritingFile.set(true);
                }
                startupTango();
                mIsTangoConnected.set(true);
            } catch (IOException e) {
                mContext.showToast("Cannot create file for Tango (pose) API.");
                mIsWritingFile.set(false);
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

        // perform initialization each time a recording is ended.
        mIsTangoConnected.set(false);
        updateADFList();
        synchronized (this) {
            mTango.disconnect();
        }
        mIsLocalizedToADF.set(false);
        mLocalizeCounter.set(0);
    }


    // set up the Tango API callback listeners for the Tango Service
    private void startupTango() {

        // select coordinate frame pair
        ArrayList<TangoCoordinateFramePair> framePairs = new ArrayList<TangoCoordinateFramePair>();
        framePairs.add(new TangoCoordinateFramePair(
                TangoPoseData.COORDINATE_FRAME_START_OF_SERVICE,
                TangoPoseData.COORDINATE_FRAME_DEVICE));

        if (mIsADFEnabled.get()) {
            framePairs.add(new TangoCoordinateFramePair(
                    TangoPoseData.COORDINATE_FRAME_AREA_DESCRIPTION,
                    TangoPoseData.COORDINATE_FRAME_START_OF_SERVICE));
            framePairs.add(new TangoCoordinateFramePair(
                    TangoPoseData.COORDINATE_FRAME_AREA_DESCRIPTION,
                    TangoPoseData.COORDINATE_FRAME_DEVICE));
        }

        // Tango callback functions
        mIsLocalizedToADF.set(false);
        mLocalizeCounter.set(0);
        final int minLocalized = 10;
        mTango.connectListener(framePairs, new Tango.TangoUpdateCallback() {
            @Override
            public void onPoseAvailable(TangoPoseData pose) {

                // save pure odometry results regardless whether ADF is enabled or not
                if ((pose.baseFrame == TangoPoseData.COORDINATE_FRAME_START_OF_SERVICE) && (pose.targetFrame == TangoPoseData.COORDINATE_FRAME_DEVICE)
                        && (pose.statusCode == TangoPoseData.POSE_VALID) && (mIsWritingFile.get())) {
                    try {
                        mFileStreamer.addPoseRecord(pose);
                    } catch (IOException | KeyException e) {
                        Log.e(LOG_TAG, "onPoseAvailable: Cannot add the pose result to file");
                        e.printStackTrace();
                    }
                }
            }

            @Override
            public void onXyzIjAvailable(TangoXyzIjData xyzIj) {
                super.onXyzIjAvailable(xyzIj);
            }

            @Override
            public void onFrameAvailable(int cameraId) {
                super.onFrameAvailable(cameraId);
            }

            @Override
            public void onTangoEvent(TangoEvent event) {
                super.onTangoEvent(event);
            }

            @Override
            public void onPointCloudAvailable(TangoPointCloudData pointCloud) {
                super.onPointCloudAvailable(pointCloud);
            }
        });
    }


    private TangoConfig setupTangoConfig(Tango tango) {

        // default configuration for Tango service
        TangoConfig tangoConfig = tango.getConfig(TangoConfig.CONFIG_TYPE_DEFAULT);

        // motion tracking setting
        tangoConfig.putBoolean(TangoConfig.KEY_BOOLEAN_MOTIONTRACKING, true);
        tangoConfig.putBoolean(TangoConfig.KEY_BOOLEAN_HIGH_RATE_POSE, true);
        tangoConfig.putBoolean(TangoConfig.KEY_BOOLEAN_LOWLATENCYIMUINTEGRATION, true);
        tangoConfig.putBoolean(TangoConfig.KEY_BOOLEAN_AUTORECOVERY, true);

        // area learning setting
        if (mIsAreaLearningMode.get()) {
            tangoConfig.putBoolean(TangoConfig.KEY_BOOLEAN_LEARNINGMODE, true);
        }

        // depth perception setting

        //
        return tangoConfig;
    }


    public Matrix4 getLatestPoseMatrix() {

        // obtain the latest tango pose
        Matrix4 mLatestPose = new Matrix4();
        if (mIsTangoConnected.get()) {
            try {
                TangoPoseData pose = mTango.getPoseAtTime(0, new TangoCoordinateFramePair(
                        TangoPoseData.COORDINATE_FRAME_START_OF_SERVICE, TangoPoseData.COORDINATE_FRAME_DEVICE));
                mLatestPose = ScenePoseCalculator.tangoPoseToMatrix(pose);
                if (mIsLocalizedToADF.get()) {
                    mLatestPose.leftMultiply(mInitialTransform);
                }
            } catch (TangoInvalidException e) {
                e.printStackTrace();
            }
        }

        // return the current tango pose
        return mLatestPose;
    }


    public void updateADFList() {
        try {
            ArrayList<String> uuids = mTango.listAreaDescriptions();
            mAdfList.clear();
            for (String uuid : uuids) {
                String name = "unknown";
                try {
                    TangoAreaDescriptionMetaData metaData = mTango.loadAreaDescriptionMetaData(uuid);
                    name = new String(metaData.get(TangoAreaDescriptionMetaData.KEY_NAME));
                } catch (TangoErrorException e) {
                    Log.w(LOG_TAG, "Name unknown for adf: " + uuid);
                }
                mAdfList.put(uuid, name);
            }
        } catch (TangoInvalidException e){
            mContext.showToast("Can not update ADF list: tango invalid.");
        }
    }


    // definition of 'TangoResultStreamer' class
    class TangoResultStreamer extends FileStreamer {

        // properties
        private BufferedWriter mPoseWriter;
        private BufferedWriter mPointWriter;


        // constructor
        TangoResultStreamer(final Context context, final String outputFolder) throws IOException {
            super(context, outputFolder);
            addFile("pose", "pose.txt");
            addFile("point", "point.txt");
            mPoseWriter = getFileWriter("pose");
            mPointWriter = getFileWriter("point");
        }


        // methods
        public void addPoseRecord(final TangoPoseData pose) throws IOException, KeyException {

            // execute the block with only one thread
            synchronized (this) {

                // check 'mPoseWriter' variable
                if (mPoseWriter == null) {
                    throw new KeyException("File writer pose not found.");
                }

                // extract time, pose information from TangoPoseData
                long timestamp = (long) (pose.timestamp * mulNanoToSec);
                final float[] rotation = pose.getRotationAsFloats();
                final float[] translation = pose.getTranslationAsFloats();

                // record Tango 6-DoF pose information in text file
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.append(timestamp); // nano seconds since boot
                stringBuilder.append(String.format(Locale.US, " %.6f %.6f %.6f %.6f", rotation[0], rotation[1], rotation[2], rotation[3])); // qx qy qz qw
                stringBuilder.append(String.format(Locale.US, " %.6f %.6f %.6f", translation[0], translation[1], translation[2]));          // tx ty tz
                stringBuilder.append(" \n");
                mPoseWriter.write(stringBuilder.toString());
            }
        }

        @Override
        public void endFiles() throws IOException {

            // execute the block with only one thread
            synchronized (this) {
                mPoseWriter.flush();
                mPoseWriter.close();
                mPointWriter.flush();
                mPointWriter.close();
            }
        }
    }


    // getter and setter
    public boolean isInitialized() {
        return mIsTangoInitialized.get();
    }

    public Tango getTango(){
        return mTango;
    }

    public boolean isTangoConnected() {
        return mIsTangoConnected.get();
    }

    public boolean isTangoInitialized() {
        return mIsTangoInitialized.get();
    }

    static public String tangoPoseToString(final TangoPoseData pose) {
        return String.format(Locale.US, "%d %.3f %.3f %.3f %.3f %.3f %.3f %.3f",
                (long) (pose.timestamp * mulNanoToSec), pose.translation[0], pose.translation[1], pose.translation[2],
                pose.rotation[0], pose.rotation[1], pose.rotation[2], pose.rotation[3]);
    }

    public HashMap<String, String> getADFList() {
        return mAdfList;
    }

    public String getAdfName(final String uuid) {
        if (mAdfList.containsKey(uuid)) {
            return mAdfList.get(uuid);
        } else {
            return "N/A";
        }
    }
}
