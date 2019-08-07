package com.pjinkim.sensors_data_logger;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.security.KeyException;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Locale;

public class FileStreamer {

    // properties
    private final static String LOG_TAG = FileStreamer.class.getName();

    private Context mContext;
    private HashMap<String, BufferedWriter> mFileWriters = new HashMap<>();
    private String mOutputFolder;


    // constructor
    public FileStreamer(Context mContext, final String mOutputFolder) {
        this.mContext = mContext;
        this.mOutputFolder = mOutputFolder;
    }


    // methods
    public void addFile(final String writerId, final String fileName) throws IOException {

        // check if there is a already generated text file
        if (mFileWriters.containsKey(writerId)) {
            Log.w(LOG_TAG, "addFile: " + writerId + " already exist.");
            return;
        }

        // get current time information
        Calendar fileTimestamp = Calendar.getInstance();
        String timeHeader = "# Created at " + fileTimestamp.getTime().toString() + " in Burnaby Canada \n";

        // generate text file
        BufferedWriter newWriter = createFile(mOutputFolder + "/" + fileName, timeHeader);
        mFileWriters.put(writerId, newWriter);
    }

    private BufferedWriter createFile(final String path, final String timeHeader) throws IOException {

        File file = new File(path);
        BufferedWriter writer = new BufferedWriter((new FileWriter(file)));

        Intent scanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
        scanIntent.setData(Uri.fromFile(file));
        mContext.sendBroadcast(scanIntent);
        if ((timeHeader != null) && (timeHeader.length() != 0)) {
            writer.append(timeHeader);
            writer.flush();
        }
        return writer;
    }

    public String getOutputFolder() {
        return mOutputFolder;
    }

    public BufferedWriter getFileWriter(final String writerId) {
        return mFileWriters.get(writerId);
    }

    public void addRecord(final long timestamp, final String writerId, final int numValues, final float[] values) throws IOException, KeyException {

        // execute the block with only one thread
        synchronized (this) {

            // get BufferedWriter of 'writerId'
            BufferedWriter writer = getFileWriter(writerId);
            if (writer == null) {
                throw new KeyException("addRecord: " + writerId + " not found.");
            }

            // record timestamp, and values in text file
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.append(timestamp);
            for (int i = 0; i < numValues; ++i) {
                stringBuilder.append(String.format(Locale.US, " %.6f", values[i]));
            }
            stringBuilder.append(" \n");
            writer.write(stringBuilder.toString());
        }
    }

    public void endFiles() throws IOException {

        // execute the block with only one thread
        synchronized (this) {
            for (BufferedWriter eachWriter : mFileWriters.values()) {
                eachWriter.flush();
                eachWriter.close();
            }
        }
    }
}
