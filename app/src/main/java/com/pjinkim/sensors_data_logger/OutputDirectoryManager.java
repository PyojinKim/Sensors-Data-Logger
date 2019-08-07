package com.pjinkim.sensors_data_logger;

import android.os.Environment;
import android.util.Log;

import java.io.File;
import java.io.FileNotFoundException;
import java.text.SimpleDateFormat;
import java.util.Calendar;

public class OutputDirectoryManager {

    // properties
    private final static String LOG_TAG = OutputDirectoryManager.class.getName();

    private String mOutputDirectory;


    // constructors
    public OutputDirectoryManager(final String prefix, final String suffix) throws FileNotFoundException {
        update(prefix, suffix);
    }

    public OutputDirectoryManager(final String prefix) throws FileNotFoundException {
        update(prefix);
    }

    public OutputDirectoryManager() throws FileNotFoundException {
        update();
    }


    // methods
    private void update(final String prefix, final String suffix) throws FileNotFoundException {

        // initialize folder name with current time information
        Calendar currentTime = Calendar.getInstance();
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddhhmmss");
        File externalDirectory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
        String folderName = formatter.format(currentTime.getTime());

        // combine prefix and suffix
        if (prefix != null) {
            folderName = prefix + folderName;
        }
        if (suffix != null) {
            folderName = folderName + suffix;
        }

        // generate output directory folder
        File outputDirectory = new File(externalDirectory.getAbsolutePath() + "/" + folderName);
        if (!outputDirectory.exists()) {
            if (!outputDirectory.mkdir()) {
                Log.e(LOG_TAG, "update: Cannot create output directory.");
                throw new FileNotFoundException();
            }
        }
        mOutputDirectory = outputDirectory.getAbsolutePath();
        Log.i(LOG_TAG, "update: Output directory: " + outputDirectory.getAbsolutePath());
    }

    private void update(final String prefix) throws FileNotFoundException {
        update(prefix, null);
    }

    private void update() throws FileNotFoundException {
        update(null, null);
    }


    // getter and setter
    public String getOutputDirectory() {
        return mOutputDirectory;
    }
}
