package com.sssemil.sonyirremote.ir;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.PowerManager;
import android.util.Log;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.entity.BufferedHttpEntity;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.concurrent.ExecutionException;
import java.util.regex.Pattern;

/**
 * Copyright (c) 2014 Emil Suleymanov
 * Distributed under the GNU GPL v2. For full terms see the file LICENSE.
 */

public class ir extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_ir);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        fixPermissionsForIr();
        spinner = ((Spinner) findViewById(R.id.spinner2));
        spinner2 = ((Spinner) findViewById(R.id.spinner));
        spinner6 = ((Spinner) findViewById(R.id.spinner6));
        new Thread(new Runnable() {
            public void run() {
                startIR();
            }
        }).start();
        prepIRKeys();
        prepItemBrandArray();
        PackageInfo pInfo = null;
        try {
            pInfo = getPackageManager().getPackageInfo(getPackageName(), 0);
            cur_ver = pInfo.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        cur_ver = pInfo.versionName;
        firstRunChecker();
        Thread thread = new Thread() {
            public void run() {
                Log.i("SonyIRRemote", "new Thread()");
                File f;
                while (true) {
                    f = new File(irpath + brand + "/" + item + "/disable.ini");
                    /*runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            prepItemBrandArray();
                        }
                    });*/
                    if (f.exists() && wrt == false) {
                        try {
                            FileInputStream is = new FileInputStream(f);
                            BufferedReader reader = new BufferedReader(new InputStreamReader(is));
                            String line = null;
                            while ((line = reader.readLine()) != null) {
                                final String finalLine = line;
                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        int id = getResources().getIdentifier(finalLine, "id", "com.sssemil.sonyirremote.ir");
                                        //Log.i("SonyIRRemote", "name: " + finalLine + " id: " + id );
                                        Button button = ((Button) findViewById(id));
                                        try {
                                            button.setEnabled(false);
                                        } catch (Exception ex) {
                                        }
                                    }
                                });
                            }
                            reader.close();
                            //String ret = convertStreamToString(is);
                            is.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    } else {
                        for (int i = 0; i < 25; i++) {
                            final String btn = "button" + i;
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    int id = getResources().getIdentifier(btn, "id", "com.sssemil.sonyirremote.ir");
                                    //Log.i("SonyIRRemote", "name: " + finalLine + " id: " + id );
                                    Button button = ((Button) findViewById(id));
                                    try {
                                        button.setEnabled(true);
                                    } catch (Exception ex) {
                                    }
                                }
                            });
                        }
                    }
                    try {
                        Thread.sleep(500);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        };
        thread.start();
    }

    public static final String PREFS_NAME = "SIRR";

    public void firstRunChecker() {
        boolean isFirstRun = true;
        SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
        if (!settings.contains("isFirstRun")) {
            isFirstRun = true;
        } else {
            isFirstRun = settings.getBoolean("isFirstRun", false);
        }
        if (isFirstRun) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle(getString(R.string.welcome));
            builder.setMessage(getString(R.string.fr));
            builder.setPositiveButton("OK", null);
            AlertDialog dialog = builder.show();
            SharedPreferences.Editor editor = settings.edit();
            editor.putBoolean("isFirstRun", false);
            editor.commit();
        }
    }

    static {
        System.loadLibrary("jni_sonyopenir");
    }

    public void restartIR() {
        stopIR();
        startIR();
    }

    public native int startIR();

    public native int stopIR();

    public native int learnKey(String filename);

    public native int sendKey(String filename);

    public void errorT(String msg) {
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
    }

    private void learnKeyBool(final String filename) {
        new Thread(new Runnable() {
            public void run() {
                restartIR();
                state = learnKey(filename);
                Log.i("stateLearn", String.valueOf(state));
                if (state < 0) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            errorT(getString(R.string.failed_lk) + filename);
                        }
                    });
                }
            }
        }).start();
    }

    public int state = 0;

    private void sendKeyBool(final String filename) {
        new Thread(new Runnable() {
            public void run() {
                state = sendKey(filename);
                Log.i("stateSend", String.valueOf(state));
                if (state < 0) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            errorT(getString(R.string.failed_sk) + filename);
                        }
                    });
                }
            }
        }).start();
    }

    public String irpath = "/data/data/com.sssemil.sonyirremote.ir/ir/";

    public static String convertStreamToString(InputStream is) throws Exception {
        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        StringBuilder sb = new StringBuilder();
        String line = null;
        while ((line = reader.readLine()) != null) {
            sb.append(line).append("\n");
        }
        reader.close();
        return sb.toString();
    }

    ProgressDialog progress;

    public void prepIRKeys() {
        File f = new File(irpath);
        if (!f.isDirectory()) {
            f.mkdirs();
            //DownloadALL();
            //UnzipALL();
        }
    }


    Spinner spinner, spinner2, spinner6;

    private ArrayList localArrayList1, localArrayList2;

    public void prepItemBrandArray() {
        spinner = ((Spinner) findViewById(R.id.spinner2));
        localArrayList1 = new ArrayList();
        spinner2 = ((Spinner) findViewById(R.id.spinner));
        localArrayList2 = new ArrayList();
        boolean edited = false;

        for (File localFile1 : new File(this.irpath).listFiles()) {
            if (localFile1.isDirectory()) {
                if (!localArrayList1.contains(localFile1.getName())) {
                    localArrayList1.add(localFile1.getName());
                    edited = true;
                }
                for (File localFile2 : new File(localFile1.getPath() + "/").listFiles())
                    if (localFile2.isDirectory()) {
                        if (!localArrayList2.contains(localFile2.getName())) {
                            localArrayList2.add(localFile2.getName());
                            edited = true;
                        }
                    }
            }

            if (edited == true) {
                ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, localArrayList1);
                dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                spinner2.setAdapter(dataAdapter);

                ArrayAdapter<String> dataAdapter2 = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, localArrayList2);
                dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                spinner.setAdapter(dataAdapter2);
            }
        }
    }

    EditText brandN;
    EditText itemN;

    public void onAddDeviceClick(View paramView) {
        try {
            itemN = ((EditText) findViewById(R.id.editText));
            brandN = ((EditText) findViewById(R.id.editText2));
            File localFile1 = new File(irpath + brandN.getText().toString());
            if (!localFile1.isDirectory()) {
                localFile1.mkdirs();
            }
            File localFile2 = new File(irpath + brandN.getText().toString() + "/" + itemN.getText().toString());
            if (!localFile2.isDirectory()) {
                localFile2.mkdirs();
            }
            prepItemBrandArray();
            //Toast.makeText(this, this.irpath + this.brandN.getText().toString() + "/" + this.itemN.getText().toString(), 0).show();

        } catch (Exception ex) {
            Toast.makeText(this, "FAILED!!!", 0).show();
        }

        try {
            spinner = ((Spinner) findViewById(R.id.spinner2));
            localArrayList1 = new ArrayList();
            spinner2 = ((Spinner) findViewById(R.id.spinner));
            localArrayList2 = new ArrayList();


            localArrayList1.add(brandN);
            localArrayList2.add(itemN);

            ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, localArrayList1);
            dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            spinner2.setAdapter(dataAdapter);

            ArrayAdapter<String> dataAdapter2 = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, localArrayList2);
            dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            spinner.setAdapter(dataAdapter2);
        } catch (Exception ex) {
        }
    }

    public static boolean fixPermissionsForIr() {
        // IR Paths
        String[] irEnable = {"su", "-c", "chown system:sdcard_rw /sys/devices/platform/ir_remote_control/enable /dev/ttyHSL2"};
        String[] enablePermissions = {"su", "-c", "chmod 220 /sys/devices/platform/ir_remote_control/enable"};
        String[] devicePermissions = {"su", "-c", "chmod 660 /dev/ttyHSL2"};
        //String[] binPermissions = { "su", "-c", "chmod 660 /data/data/com.sssemil.ir/bin/irtest"};
        try {
            // Try to enable Infrared Devices
            Runtime.getRuntime().exec(irEnable);
            Runtime.getRuntime().exec(enablePermissions);
            Runtime.getRuntime().exec(devicePermissions);
            //Runtime.getRuntime().exec(binPermissions);
        } catch (IOException e) {
            // Elevating failed
            return false;
        } finally {
            return true;
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.ir, menu);
        return true;
    }

    private boolean isNetworkAvailable() {
        ConnectivityManager connectivityManager
                = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
        return activeNetworkInfo != null && activeNetworkInfo.isConnected();
    }

    public boolean resultat = false;
    public int numF;
    public boolean done = false;

    public static String readStream(InputStream in) throws IOException {
        StringBuffer out = new StringBuffer();
        byte[] b = new byte[4096];
        for (int n; (n = in.read(b)) != -1; ) {
            out.append(new String(b, 0, n));
        }
        return out.toString();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_settings) {
            setContentView(R.layout.settings_ir);

            final GetAwItems getAwItems1 = new GetAwItems(ir.this);
            getAwItems1.execute();

            spinner6 = ((Spinner) findViewById(R.id.spinner6));

            ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, ar);
            dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            spinner6.setAdapter(dataAdapter);

            prepItemBrandArray();

            return true;
        } else if (id == R.id.action_about) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle(getString(R.string.about));
            PackageInfo pInfo = null;
            String version = "?";
            try {
                pInfo = getPackageManager().getPackageInfo(getPackageName(), 0);
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }
            version = pInfo.versionName;
            builder.setMessage(getResources().getString(R.string.license1) + " v" + version + "\n" + getResources().getString(R.string.license2) + "\n" + getResources().getString(R.string.license3) + "\n" + getResources().getString(R.string.license4));
            builder.setPositiveButton("OK", null);
            AlertDialog dialog = builder.show();

// Must call show() prior to fetching text view
            TextView messageView = (TextView) dialog.findViewById(android.R.id.message);
            messageView.setGravity(Gravity.CENTER);
            return true;
        } else if (id == R.id.action_exit) {
            stopIR();
            System.exit(0);
            return true;
        } else if (id == R.id.action_update) {
            update();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public String brand;
    public String item;
    public boolean wrt = false;

    long lastPress;

    @Override
    public void onBackPressed() {
        long currentTime = System.currentTimeMillis();
        if (currentTime - lastPress > 5000) {
            Toast.makeText(getBaseContext(), "Press back again to exit", Toast.LENGTH_LONG).show();
            lastPress = currentTime;
        } else {
            stopIR();
            super.onBackPressed();
        }
        setContentView(R.layout.activity_ir);
        prepItemBrandArray();
        //super.onBackPressed();
    }

    public void onWrtClick(View view) {
        if (wrt) {
            wrt = false;
            final Button btntxt = (Button) findViewById(R.id.button2);
            btntxt.setText(getResources().getString(R.string.Write_signal));
            btntxt.setTextColor(Color.BLACK);
        } else if (!wrt) {
            wrt = true;
            final Button btntxt = (Button) findViewById(R.id.button2);
            btntxt.setText(getResources().getString(R.string.Send_signal));
            btntxt.setTextColor(Color.RED);

            File f = new File(irpath + brand + "/" + item);
            if (!f.isDirectory()) {
                f.mkdirs();
            }

            File f2 = new File(irpath + brand);
            if (!f2.isDirectory()) {
                f2.mkdirs();
            }
        }
    }


    public void onRemoveClick(View view) {
        Spinner spinner = (Spinner) findViewById(R.id.spinner);
        brand = spinner.getSelectedItem().toString();
        Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
        item = spinner2.getSelectedItem().toString();

        Toast.makeText(this, brand + "/" + item, Toast.LENGTH_SHORT).show();

        String[] remove = {"rm", "-rf", irpath + brand + "/" + item};
        try {
            Process p = Runtime.getRuntime().exec(remove);
            Log.i("rm", "Waiting... " + irpath + brand + "/" + item);
            p.waitFor();
            Log.i("rm", "Done! " + irpath + brand + "/" + item);
        } catch (Exception e) {
            Log.e("rm", "Failed! " + irpath + brand + "/" + item);
            e.printStackTrace();
        }

        File directory = new File(irpath + brand);
        File[] contents = directory.listFiles();
        if (contents.length == 0 && contents != null) {
            String[] remove2 = {"rm", "-rf", irpath + brand};
            try {
                Process p2 = Runtime.getRuntime().exec(remove2);
                Log.i("rm", "Waiting... " + irpath + brand);
                p2.waitFor();
                Log.i("rm", "Done! " + irpath + brand);
            } catch (Exception e) {
                Log.e("rm", "Failed! " + irpath + brand);
                e.printStackTrace();
            }
        }


        /*File dir = new File(irpath + brand + "/" + item);
        if (dir.isDirectory()) {
            String[] children = dir.list();
            for (int i = 0; i < children.length; i++) {
                new File(dir, children[i]).delete();
            }
        }

        File dir2 = new File(irpath + brand );
        if (dir2.isDirectory()) {
            String[] children = dir2.list();
            if(children.length < 1)
            {
                new File(dir2, children[0]).delete();
            }
        }*/

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Done!");
        builder.setMessage("Done removing " + brand + "/" + item + " files!");
        builder.setPositiveButton("OK", null);
        AlertDialog dialog = builder.show();

// Must call show() prior to fetching text view
        TextView messageView = (TextView) dialog.findViewById(android.R.id.message);
        messageView.setGravity(Gravity.CENTER);
    }

    public void onPowerClick(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "Power" + brand, Toast.LENGTH_SHORT).show();

            sendKeyBool(irpath + brand + "/" + item + "/power.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "Power" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();

            learnKeyBool(irpath + brand + "/" + item + "/power.bin");
        }
    }

    public void onChanelPlClick(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "ChanelPl" + brand, Toast.LENGTH_SHORT).show();

            sendKeyBool(irpath + brand + "/" + item + "/chanelPl.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "ChanelPl" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();

            learnKeyBool(irpath + brand + "/" + item + "/chanelPl.bin");
        }
    }

    public void onChanelMnSonClick(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "ChanelMn" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/chanelMn.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "ChanelMn" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/chanelMn.bin");
        }
    }

    public void onVolumePlClick(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "VolumePl" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/volPl.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "VolumePl" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/volPl.bin");
        }
    }

    public void onVolumeMnClick(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "VolumeMn" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/volMn.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "VolumeMn" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/volMn.bin");
        }
    }

    public void on1Click(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "1" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/1.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "1" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/1.bin");
        }
    }

    public void on2Click(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "2" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/2.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "2" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/2.bin");
        }
    }

    public void on3Click(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "3" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/3.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "3" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/3.bin");
        }
    }

    public void on4Click(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "4" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/4.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "4" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/4.bin");
        }
    }

    public void on5Click(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "5" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/5.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "5" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/5.bin");
        }
    }

    public void on6Click(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "6" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/6.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "6" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/6.bin");
        }
    }

    public void on7Click(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "7" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/7.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "7" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/7.bin");
        }
    }

    public void on8Click(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "8" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/8.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "8" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/8.bin");
        }
    }

    public void on9Click(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "9" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/9.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "9" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/9.bin");
        }
    }

    public void on0Click(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "0" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/0.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "0" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/0.bin");
        }
    }

    public void onUpClick(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "up" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/up.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "up" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/up.bin");
        }
    }

    public void onDownClick(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "down" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/down.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "down" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/down.bin");
        }
    }

    public void onLeftClick(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "left" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/left.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "left" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/left.bin");
        }
    }

    public void onRightClick(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "right" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/right.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "right" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/right.bin");
        }
    }

    public void onEnterClick(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "enter" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/enter.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "enter" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/enter.bin");
        }
    }


    public void onMuteClick(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "mute" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/mute.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "mute" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/mute.bin");
        }
    }


    public void onHomeClick(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "home" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/home.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "home" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/home.bin");
        }
    }


    public void onInputClick(View view) {
        if (!wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "input" + brand, Toast.LENGTH_SHORT).show();
            sendKeyBool(irpath + brand + "/" + item + "/input.bin");
        } else if (wrt) {
            Spinner spinner = (Spinner) findViewById(R.id.spinner);
            brand = spinner.getSelectedItem().toString();
            Spinner spinner2 = (Spinner) findViewById(R.id.spinner2);
            item = spinner2.getSelectedItem().toString();

            Toast.makeText(this, "input" + brand + " LEARNING!", Toast.LENGTH_SHORT).show();
            learnKeyBool(irpath + brand + "/" + item + "/input.bin");
        }
    }

    public void UnzipALL() {
        progress = ProgressDialog.show(this, "Please wait..",
                "Extracting files...", true);

        new Thread(new Runnable() {
            @Override
            public void run() {
                String zipFile = "/sdcard/sony-tv.zip";
                String unzipLocation = irpath;

                Decompress d = new Decompress(zipFile, unzipLocation);
                d.unzip();
                progress.cancel();
            }
        }).start();
    }

    ProgressDialog mProgressDialog;

    public void DownloadALL() {
        /*final ProgressDialog mProgressDialog = ProgressDialog.show(ir.this, "Please wait ...", "Downloading keys ...", true);

        final DownloadTask downloadTask = new DownloadTask(ir.this);
        downloadTask.execute("http://sssemil.or.gs/sony-tv.zip");*/

        mProgressDialog = new ProgressDialog(ir.this);
        mProgressDialog.setMessage("Downloading keys...");
        mProgressDialog.setIndeterminate(true);
        mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
        mProgressDialog.setCancelable(true);

        final DownloadTask downloadTask = new DownloadTask(ir.this);
        downloadTask.execute("http://sssemil.or.gs/sonyirremote/sony-tv.zip");

        mProgressDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
                downloadTask.cancel(true);
            }
        });
    }

    public ArrayList<String> ar = new ArrayList<String>();
    public String last_ver = "zirt";
    public String cur_ver;

    public String compare(String v1, String v2) {
        String s1 = normalisedVersion(v1);
        String s2 = normalisedVersion(v2);
        int cmp = s1.compareTo(s2);
        String cmpStr = cmp < 0 ? "<" : cmp > 0 ? ">" : "==";
        //System.out.printf("'%s' %s '%s'%n", v1, cmpStr, v2);
        return cmpStr;
    }

    public static String normalisedVersion(String version) {
        return normalisedVersion(version, ".", 4);
    }

    public static String normalisedVersion(String version, String sep, int maxWidth) {
        String[] split = Pattern.compile(sep, Pattern.LITERAL).split(version);
        StringBuilder sb = new StringBuilder();
        for (String s : split) {
            sb.append(String.format("%" + maxWidth + 's', s));
        }
        return sb.toString();
    }


    class DownloadApp extends AsyncTask<String, Integer, String> {

        private Context context;
        private PowerManager.WakeLock mWakeLock;

        public DownloadApp(Context context) {
            this.context = context;
        }

        protected String doInBackground(String... sUrl) {
            InputStream input = null;
            OutputStream output = null;
            HttpURLConnection connection = null;
            try {
                Log.v("DownloadApp", "Starting... ");
                URL url = new URL(sUrl[0]);

                connection = (HttpURLConnection) url.openConnection();
                connection.connect();

                // expect HTTP 200 OK, so we don't mistakenly save error report
                // instead of the file
                if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
                    return "Server returned HTTP " + connection.getResponseCode()
                            + " " + connection.getResponseMessage();
                }

                // this will be useful to display download percentage
                // might be -1: server did not report the length
                int fileLength = connection.getContentLength();

                // download the file
                input = connection.getInputStream();
                output = new FileOutputStream("/sdcard/upd.apk");
                Log.v("DownloadApp", "output " + "/sdcard/upd.apk");

                byte data[] = new byte[4096];
                long total = 0;
                int count;
                while ((count = input.read(data)) != -1) {
                    // allow canceling with back button
                    if (isCancelled()) {
                        input.close();
                        return null;
                    }
                    total += count;
                    // publishing the progress....
                    if (fileLength > 0) // only if total length is known
                        publishProgress((int) (total * 100 / fileLength));
                    output.write(data, 0, count);
                }
                Log.v("DownloadApp", "Done!");

                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setDataAndType(Uri.fromFile(new File("/sdcard/upd.apk")), "application/vnd.android.package-archive");
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);

                /*Log.v("pm", "pm install /sdcard/upd.apk");
                String[] pm = {"pm", "install -r", "/sdcard/upd.apk"};
                try {
                    Runtime.getRuntime().exec(pm);
                    Log.v("pm", "Done! pm install -r /sdcard/upd.apk");
                } catch (IOException e) {
                    Log.e("pm", e.getMessage());
                }*/
            } catch (Exception e) {
                Log.e("DownloadApp", e.getMessage());
                return e.toString();
            } finally {
                try {
                    if (output != null)
                        output.close();
                    if (input != null)
                        input.close();
                } catch (IOException ignored) {
                }

                if (connection != null)
                    connection.disconnect();
            }
            return null;
        }
    }

    public void update() {
        final GetLastVer getLastVer1 = new GetLastVer(ir.this);
        try {
            Log.i("Update", "last_ver : " + getLastVer1.execute().get() + " cur_ver : " + cur_ver);
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }
        if (last_ver == "zirt") {
            AlertDialog.Builder adb = new AlertDialog.Builder(this);
            adb.setTitle(getString(R.string.update));
            adb.setMessage(getString(R.string.ser3));
            adb.setIcon(android.R.drawable.ic_dialog_alert);
            adb.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    update();
                }
            });

            adb.setNegativeButton(getString(R.string.cancel), new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    //finish();
                }
            });
            adb.show();
        } else {
            String result = compare(cur_ver, last_ver);
            boolean doUpdate = false;
            Log.i("Compare", result);
            if (result == ">") {
                doUpdate = false;
            } else if (result == "<") {
                doUpdate = true;
            } else if (result == "==") {
                doUpdate = false;
            }


            if (doUpdate == true) {
                AlertDialog.Builder adb = new AlertDialog.Builder(this);
                adb.setTitle(getString(R.string.update));
                adb.setMessage(getString(R.string.new_version_available));
                adb.setIcon(android.R.drawable.ic_dialog_alert);
                adb.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        mProgressDialog = new ProgressDialog(ir.this);
                        mProgressDialog.setMessage(getString(R.string.downloading_new));
                        mProgressDialog.setIndeterminate(true);
                        mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
                        mProgressDialog.setCancelable(true);

                        final DownloadApp downloadApp1 = new DownloadApp(ir.this);
                        downloadApp1.execute("http://sssemil.or.gs/sonyirremote/download.php?v=last");

                        mProgressDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
                            @Override
                            public void onCancel(DialogInterface dialog) {
                                downloadApp1.cancel(true);
                            }
                        });
                    }
                });

                adb.setNegativeButton(getString(R.string.cancel), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                    }
                });
                adb.show();
            } else if (doUpdate == false) {
                AlertDialog.Builder builder = new AlertDialog.Builder(this);
                builder.setTitle(getString(R.string.update));
                builder.setMessage(getString(R.string.already_new));
                builder.setPositiveButton("OK", null);
                builder.show();
            }
        }
    }

    class GetLastVer extends AsyncTask<String, Integer, String> {

        private Context context;
        private PowerManager.WakeLock mWakeLock;

        DefaultHttpClient httpclient = new DefaultHttpClient();

        public GetLastVer(Context context) {
            this.context = context;
        }

        protected String doInBackground(String... sUrl) {
            try {
                Log.i("GetLastVer", "Starting with http://sssemil.or.gs/sonyirremote/last.php");
                HttpGet httppost = new HttpGet("http://sssemil.or.gs/sonyirremote/last.php");
                HttpResponse response = httpclient.execute(httppost);
                HttpEntity ht = response.getEntity();

                BufferedHttpEntity buf = new BufferedHttpEntity(ht);

                InputStream is = buf.getContent();

                BufferedReader r = new BufferedReader(new InputStreamReader(is));

                String line;
                last_ver = "";
                while ((line = r.readLine()) != null) {
                    last_ver += line;
                }
                Log.i("GetLastVer", last_ver);
                return last_ver;
            } catch (IOException ex) {
                Log.e("GetLastVer", ex.getMessage());
                return null;
            }
        }
    }

    class GetAwItems extends AsyncTask<String, Integer, String> {

        private Context context;
        private PowerManager.WakeLock mWakeLock;

        DefaultHttpClient httpclient = new DefaultHttpClient();

        public GetAwItems(Context context) {
            this.context = context;
        }

        protected String doInBackground(String... sUrl) {
            try {
                HttpGet httppost = new HttpGet("http://sssemil.or.gs/sonyirremote/files.txt");
                HttpResponse response = httpclient.execute(httppost);
                HttpEntity ht = response.getEntity();

                BufferedHttpEntity buf = new BufferedHttpEntity(ht);

                InputStream is = buf.getContent();

                BufferedReader r = new BufferedReader(new InputStreamReader(is));

                StringBuilder total = new StringBuilder();
                String line;
                ar.clear();
                while ((line = r.readLine()) != null) {
                    total.append(line + "\n");
                    ar.add(line);
                }

                return total.toString();
            } catch (IOException ex) {
                return null;
            }
        }
    }

    /*public void prepItemBrandArray() {
        spinner = ((Spinner) findViewById(R.id.spinner6));
        ArrayList localArrayList3 = new ArrayList();

        localArrayList1.add(localFile1.getName());
        ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, localArrayList3);
        dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner2.setAdapter(dataAdapter);
    }*/

    public void onDownItemsClick(View view) {
        spinner6 = ((Spinner) findViewById(R.id.spinner6));
        String test = spinner6.getSelectedItem().toString();
        String lastWord = test.substring(test.lastIndexOf(" ") + 1);
        /*AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Test");
        builder.setMessage(lastWord);
        builder.setPositiveButton("OK", null);
        AlertDialog dialog = builder.show();

// Must call show() prior to fetching text view
        TextView messageView = (TextView) dialog.findViewById(android.R.id.message);
        messageView.setGravity(Gravity.CENTER);*/
        if (!lastWord.isEmpty()) {
            mProgressDialog = new ProgressDialog(ir.this);
            mProgressDialog.setMessage(getString(R.string.down_keys));
            mProgressDialog.setIndeterminate(true);
            mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
            mProgressDialog.setCancelable(true);

// execute this when the downloader must be fired
            final DownloadTask downloadTask = new DownloadTask(ir.this);
            downloadTask.execute(lastWord);
            /*mProgressDialog = ProgressDialog.show(this, "Please wait..",
                    "Extracting files...", true);

            final String fileName = lastWord.substring(lastWord.lastIndexOf("/")+1);

            new Thread(new Runnable() {
                @Override
                public void run()
                {
                    String zipFile = "/sdcard/"+ fileName;
                    String unzipLocation = irpath;

                    Decompress d = new Decompress(zipFile, unzipLocation);
                    d.unzip();
                    mProgressDialog.cancel();
                }
            }).start();*/

            mProgressDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
                @Override
                public void onCancel(DialogInterface dialog) {
                    downloadTask.cancel(true);
                }
            });
        }
    }

    public void onGetAwItemsClick(View view) {
        mProgressDialog = new ProgressDialog(ir.this);
        mProgressDialog.setMessage("Getting  list...");
        mProgressDialog.setIndeterminate(true);
        mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
        mProgressDialog.setCancelable(true);

// execute this when the downloader must be fired
        final GetAwItems getAwItems1 = new GetAwItems(ir.this);
        getAwItems1.execute();

        spinner6 = ((Spinner) findViewById(R.id.spinner6));

        ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, ar);
        dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner6.setAdapter(dataAdapter);

        Toast.makeText(this, ar.toString(), Toast.LENGTH_SHORT).show();

        mProgressDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
                getAwItems1.cancel(true);
            }
        });
    }

    class DownloadTask extends AsyncTask<String, Integer, String> {

        private Context context;
        private PowerManager.WakeLock mWakeLock;

        public DownloadTask(Context context) {
            this.context = context;
        }

        protected String doInBackground(String... sUrl) {
            InputStream input = null;
            OutputStream output = null;
            HttpURLConnection connection = null;
            try {
                Log.v("DownloadTask", "Starting... ");
                URL url = new URL(sUrl[0]);
                String filePath = url.getFile();
                String fileName = filePath.substring(filePath.lastIndexOf("/") + 1);

                connection = (HttpURLConnection) url.openConnection();
                connection.connect();

                // expect HTTP 200 OK, so we don't mistakenly save error report
                // instead of the file
                if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
                    return "Server returned HTTP " + connection.getResponseCode()
                            + " " + connection.getResponseMessage();
                }

                // this will be useful to display download percentage
                // might be -1: server did not report the length
                int fileLength = connection.getContentLength();

                // download the file
                input = connection.getInputStream();
                output = new FileOutputStream("/sdcard/" + fileName);
                Log.v("DownloadTask", "output " + "/sdcard/" + fileName);

                byte data[] = new byte[4096];
                long total = 0;
                int count;
                while ((count = input.read(data)) != -1) {
                    // allow canceling with back button
                    if (isCancelled()) {
                        input.close();
                        return null;
                    }
                    total += count;
                    // publishing the progress....
                    if (fileLength > 0) // only if total length is known
                        publishProgress((int) (total * 100 / fileLength));
                    output.write(data, 0, count);
                }
                Log.v("DownloadTask", "Done!");
                //---------Unzip--------
                String zipFile = "/sdcard/" + fileName;
                String unzipLocation = irpath;

                Decompress d = new Decompress(zipFile, unzipLocation);
                d.unzip();
                //----------------------
            } catch (Exception e) {
                Log.e("DownloadTask", e.getMessage());
                return e.toString();
            } finally {
                try {
                    if (output != null)
                        output.close();
                    if (input != null)
                        input.close();
                } catch (IOException ignored) {
                }

                if (connection != null)
                    connection.disconnect();
            }
            return null;
        }
    }
}

