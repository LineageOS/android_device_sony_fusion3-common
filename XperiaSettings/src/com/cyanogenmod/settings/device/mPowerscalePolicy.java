/*
 * Copyright (C) 2012 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.cyanogenmod.settings.device;

import android.content.Context;

import android.content.SharedPreferences;
import android.util.AttributeSet;
import android.preference.Preference;
import android.preference.ListPreference;
import android.preference.Preference.OnPreferenceChangeListener;
import android.preference.PreferenceManager;

public class mPowerscalePolicy extends ListPreference implements OnPreferenceChangeListener {

    public mPowerscalePolicy(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.setOnPreferenceChangeListener(this);
    }

    private static final String FILE_POWERSCALE_POLICY = "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/pwrscale/policy";

    public static boolean isSupported() {
        return Utils.fileExists(FILE_POWERSCALE_POLICY);
    }

    /**
     * Restore powerscale policy setting from SharedPreferences. (Write to kernel.)
     * @param context       The context to read the SharedPreferences from
     */
    public static void restore(Context context) {
        if (!isSupported()) {
            return;
        }

        SharedPreferences sharedPrefs = PreferenceManager.getDefaultSharedPreferences(context);
        Utils.writeValue(FILE_POWERSCALE_POLICY, sharedPrefs.getString(DeviceSettings.KEY_POWERSCALE_POLICY, "conservative"));
    }

    public boolean onPreferenceChange(Preference preference, Object newValue) {
        String newPolicy = (String) newValue;
        Utils.writeValue(FILE_POWERSCALE_POLICY, newPolicy);

        PreferenceManager prefMan = preference.getPreferenceManager();
        if (newPolicy.compareTo("conservative") == 0) {
            prefMan.findPreference(DeviceSettings.KEY_CONSERVATIVE_POLLING).setEnabled(true);
        } else {
            prefMan.findPreference(DeviceSettings.KEY_CONSERVATIVE_POLLING).setEnabled(false);
        }

        return true;
    }
}
