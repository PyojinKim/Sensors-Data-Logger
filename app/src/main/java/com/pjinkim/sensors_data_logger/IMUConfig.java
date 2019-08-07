package com.pjinkim.sensors_data_logger;

public class IMUConfig implements java.io.Serializable {

    // properties
    private Boolean mIsFileEnabled = true;
    private String mFolderPrefix = "";
    private Boolean mIsWifiEnabled = true;
    private int mWifiScanInterval = 1;
    private Boolean mIsLocationEnabled = true;

    private int mConnectionMode = 1;
    private int mStartDelay = 0;
    private long mReferenceTimestamp = 0;
    private String mTimeSyncToken = "";
    private String mOutputFolder = "";
    public static final int MASTER = 1;
    public static final int SLAVE = 2;


    // methods
    public Boolean getFileEnabled() {
        return this.mIsFileEnabled;
    }

    public Boolean getWifiEnabled() {
        return this.mIsWifiEnabled;
    }

    public int getWifiScanInterval() {
        return this.mWifiScanInterval;
    }

    public int getStartDelay() {
        return this.mStartDelay;
    }

    public long getReferenceTimestamp() {
        return this.mReferenceTimestamp;
    }

    public int getConnectionMode() {
        return mConnectionMode;
    }

    public String getOutputFolder() {
        return mOutputFolder;
    }

    public void setOutputFolder(final String folder) {
        mOutputFolder = folder;
    }

    public String getFolderPrefix() {
        return this.mFolderPrefix;
    }

    public void setFileEnabled(Boolean v) {
        this.mIsFileEnabled = v;
    }

    public void setWifiEnabled(Boolean v) {
        this.mIsWifiEnabled = v;
    }

    public void setWifiScanInterval(int v) {
        this.mWifiScanInterval = v;
    }

    public void setStartDelay(int v) {
        this.mStartDelay = v;
    }

    public void setFolderPrefix(String v) {
        this.mFolderPrefix = v;
    }

    public Boolean getLocationEnabled() {
        return mIsLocationEnabled;
    }

    public void setLocationEnabled(Boolean l) {
        this.mIsLocationEnabled = l;
    }

    public void setConnectionMode(int mode) {
        this.mConnectionMode = mode;
    }

    public void setReferenceTimestamp(long v) {
        this.mReferenceTimestamp = v;
    }

    public String getTimeSyncToken() {
        return mTimeSyncToken;
    }

    public void setTimeSyncToken(String t) {
        this.mTimeSyncToken = t;
    }

    public String getSuffix() {
        return "R";
    }
}
