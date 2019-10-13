/*
 * Copyright (C) 2018-2019 The LineageOS Project
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

#define LOG_TAG "android.hardware.light@2.0-service.fusion3"

#include <android-base/logging.h>
#include <hidl/HidlTransportSupport.h>
#include <utils/Errors.h>

#include <hwbinder/ProcessState.h>

#include "Light.h"
#include "light.h"

// libhwbinder:
using android::hardware::configureRpcThreadpool;
using android::hardware::joinRpcThreadpool;

// Generated HIDL files
using android::hardware::light::V2_0::ILight;
using android::hardware::light::V2_0::implementation::Light;

const static std::string kRedLedPath = "/sys/devices/i2c-0/0-0036/leds/lm3533-red/brightness";
const static std::string kGreenLedPath = "/sys/devices/i2c-0/0-0036/leds/lm3533-green/brightness";
const static std::string kBlueLedPath = "/sys/devices/i2c-0/0-0036/leds/lm3533-blue/brightness";
const static std::string kRedPatternPath = "/sys/devices/i2c-0/0-0036/leds/lm3533-red/pattern";
const static std::string kGreenPatternPath = "/sys/devices/i2c-0/0-0036/leds/lm3533-green/pattern";
const static std::string kBluePatternPath = "/sys/devices/i2c-0/0-0036/leds/lm3533-blue/pattern";
const static std::string kSyncLVBanksPath = "/sys/devices/i2c-0/0-0036/sync_lvbanks";

android::status_t registerLightService() {
    uint32_t lcdMaxBrightness = 255;

    std::ofstream lcdBacklight(kLcdBacklightPath);
    if (!lcdBacklight) {
        LOG(ERROR) << "Failed to open " << kLcdBacklightPath << ", error=" << errno
                   << " (" << strerror(errno) << ")";
        return -errno;
    }

#ifdef SECONDARY_BACKLIGHT
    std::ofstream lcdSecondaryBacklight(kLcdSecondaryBacklightPath);
    if (!lcdSecondaryBacklight) {
        LOG(ERROR) << "Failed to open " << kLcdSecondaryBacklightPath << ", error=" << errno
                   << " (" << strerror(errno) << ")";
        return -errno;
    }
#endif

    std::ifstream lcdMaxBacklight(kLcdMaxBacklightPath);
    if (!lcdMaxBacklight) {
        LOG(ERROR) << "Failed to open " << kLcdMaxBacklightPath << ", error=" << errno
                   << " (" << strerror(errno) << ")";
        return -errno;
    } else {
        lcdMaxBacklight >> lcdMaxBrightness;
    }

    std::ofstream redLed(kRedLedPath);
    if (!redLed) {
        LOG(ERROR) << "Failed to open " << kRedLedPath << ", error=" << errno
                   << " (" << strerror(errno) << ")";
        return -errno;
    }

    std::ofstream greenLed(kGreenLedPath);
    if (!greenLed) {
        LOG(ERROR) << "Failed to open " << kGreenLedPath << ", error=" << errno
                   << " (" << strerror(errno) << ")";
        return -errno;
    }

    std::ofstream blueLed(kBlueLedPath);
    if (!blueLed) {
        LOG(ERROR) << "Failed to open " << kBlueLedPath << ", error=" << errno
                   << " (" << strerror(errno) << ")";
        return -errno;
    }

    std::ofstream redPattern(kRedPatternPath);
    if (!redPattern) {
        LOG(ERROR) << "Failed to open " << kRedPatternPath << ", error=" << errno
                   << " (" << strerror(errno) << ")";
        return -errno;
    }

    std::ofstream greenPattern(kGreenPatternPath);
    if (!greenPattern) {
        LOG(ERROR) << "Failed to open " << kGreenPatternPath << ", error=" << errno
                   << " (" << strerror(errno) << ")";
        return -errno;
    }

    std::ofstream bluePattern(kBluePatternPath);
    if (!bluePattern) {
        LOG(ERROR) << "Failed to open " << kBluePatternPath << ", error=" << errno
                   << " (" << strerror(errno) << ")";
        return -errno;
    }

    std::ofstream syncLVBanks(kSyncLVBanksPath);
    if (!syncLVBanks) {
        LOG(ERROR) << "Failed to open " << kSyncLVBanksPath << ", error=" << errno
                   << " (" << strerror(errno) << ")";
        return -errno;
    }

    android::sp<ILight> light = new Light(
            {std::move(lcdBacklight), lcdMaxBrightness},
#ifdef SECONDARY_BACKLIGHT
            std::move(lcdSecondaryBacklight),
#endif
            std::move(redLed), std::move(greenLed), std::move(blueLed),
            std::move(redPattern), std::move(greenPattern), std::move(bluePattern),
            std::move(syncLVBanks));

    return light->registerAsService();
}


int main() {
    android::status_t status;

    android::hardware::ProcessState::initWithMmapSize((size_t)(32768));

    configureRpcThreadpool(1, true /*willJoinThreadpool*/);

    status = registerLightService();
    if (status != android::OK) {
        LOG(ERROR) << "Could not register service for Light HAL (" << status << ")";
        goto shutdown;
    }

    LOG(INFO) << "Light HAL service is ready.";
    joinRpcThreadpool();

shutdown:
    // In normal operation, we don't expect the thread pool to exit
    LOG(ERROR) << "Light HAL service is shutting down.";
    return 1;
}
