/*
 * Copyright (C) 2014 The Android Open Source Project
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

#ifndef _BDROID_BUILDCFG_H
#define _BDROID_BUILDCFG_H

#if !defined(OS_GENERIC)
#include <cutils/properties.h>
#include <string.h>

static inline const char* getBTDefaultName()
{
    char device[PROPERTY_VALUE_MAX];
    property_get("ro.product.device", device, "");

    if (!strcmp("dogo", device)) {
        return "Xperia ZR";
    } else if (!strcmp("odin", device)) {
        return "Xperia ZL";
    } else if (!strcmp("pollux", device)) {
        return "Xperia Tablet Z LTE";
    } else if (!strcmp("pollux_windy", device)) {
        return "Xperia Tablet Z Wi-Fi";
    } else if (!strcmp("yuga", device)) {
        return "Xperia Z";
    }

    return "Xperia";
}

#define BTM_DEF_LOCAL_NAME getBTDefaultName()
#endif // OS_GENERIC

#define BTA_DISABLE_DELAY 1000
#define SC_MODE_INCLUDED FALSE
#undef PROPERTY_VALUE_MAX

#endif
