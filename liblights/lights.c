/*
 * Copyright (C) 2008 The Android Open Source Project
 * Copyright (C) 2014 The Linux Foundation. All rights reserved.
 * Copyright (C) 2017 The LineageOS Project
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

#define LOG_TAG "lights.fusion3"

#include <log/log.h>

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#ifdef ENABLE_GAMMA_CORRECTION
#include <math.h>
#endif

#include <sys/ioctl.h>
#include <sys/types.h>

#include <hardware/lights.h>

#include "lights.h"

/******************************************************************************/

static pthread_once_t g_init = PTHREAD_ONCE_INIT;
static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t g_lcd_lock = PTHREAD_MUTEX_INITIALIZER;
static struct light_state_t g_notification;
static struct light_state_t g_battery;

char const*const RED_LED_FILE
        = "/sys/devices/i2c-0/0-0036/leds/lm3533-red/brightness";

char const*const GREEN_LED_FILE
        = "/sys/devices/i2c-0/0-0036/leds/lm3533-green/brightness";

char const*const BLUE_LED_FILE
        = "/sys/devices/i2c-0/0-0036/leds/lm3533-blue/brightness";

char const*const RED_PATTERN_FILE
        = "/sys/devices/i2c-0/0-0036/leds/lm3533-red/pattern";

char const*const GREEN_PATTERN_FILE
        = "/sys/devices/i2c-0/0-0036/leds/lm3533-green/pattern";

char const*const BLUE_PATTERN_FILE
        = "/sys/devices/i2c-0/0-0036/leds/lm3533-blue/pattern";

char const*const SYNC_LVBANKS
        = "/sys/devices/i2c-0/0-0036/sync_lvbanks";

char const*const PATTERNOFF = "0,0,0,0";


/**
 * device methods
 */

void init_globals(void)
{
	// init the mutex
	pthread_mutex_init(&g_lock, NULL);
	pthread_mutex_init(&g_lcd_lock, NULL);
}

static int
write_int(char const* path, int value)
{
	int fd;
	static int already_warned = 0;

	fd = open(path, O_WRONLY);
	if (fd >= 0) {
        char buffer[20] = {0,};
        int bytes = snprintf(buffer, sizeof(buffer), "%d\n", value);
        ssize_t amt = write(fd, buffer, (size_t)bytes);
        close(fd);
        return amt == -1 ? -errno : 0;
	} else {
        if (already_warned == 0) {
            ALOGE("write_int failed to open %s\n", path);
            already_warned = 1;
        }
        return -errno;
	}
}

static int 
write_string(const char *path, const char *value) 
{
	int fd;
	static int already_warned = 0;

	fd = open(path, O_RDWR);
	if (fd < 0) {
        if (already_warned == 0) {
            ALOGE("write_string failed to open %s\n", path);
            already_warned = 1;
        }
        return -errno;
	}

	char buffer[20];
	int bytes = snprintf(buffer, sizeof(buffer), "%s\n", value);
	int written = write (fd, buffer, bytes);
	close(fd);

	return written == -1 ? -errno : 0;
}

static int
is_lit(struct light_state_t const* state)
{
	return state->color & 0x00ffffff;
}

static int
rgb_to_brightness(struct light_state_t const* state)
{
	int color = state->color & 0x00ffffff;
	return ((77 * ((color >> 16) & 0x00ff))
            + (150 * ((color >> 8) & 0x00ff)) + (29 * (color & 0x00ff))) >> 8;
}

#ifdef ENABLE_GAMMA_CORRECTION
static int 
brightness_apply_gamma (int brightness) 
{
    double floatbrt = (double) brightness;
    floatbrt /= 255.0;
    ALOGV("%s: brightness = %d, floatbrt = %f", __FUNCTION__, brightness, floatbrt);
    floatbrt = pow(floatbrt, 2.2);
    ALOGV("%s: gamma corrected floatbrt = %f", __FUNCTION__, floatbrt);
    floatbrt *= 255.0;
    brightness = (int) floatbrt;
    ALOGV("%s: gamma corrected brightness = %d", __FUNCTION__, brightness);
    return brightness;
}
#endif

static int
get_light_max_backlight() {

    char value[6];
    int fd, len, max_brightness;

    if ((fd = open(MAX_BRIGHTNESS_FILE, O_RDONLY)) < 0) {
        ALOGE("[%s]: Could not open max brightness file %s: %s", __FUNCTION__,
                MAX_BRIGHTNESS_FILE, strerror(errno));
        ALOGE("[%s]: Assume max brightness 255", __FUNCTION__);
        return 255;
    }

    if ((len = read(fd, value, sizeof(value))) <= 1) {
        ALOGE("[%s]: Could not read max brightness file %s: %s", __FUNCTION__,
                MAX_BRIGHTNESS_FILE, strerror(errno));
        ALOGE("[%s]: Assume max brightness 255", __FUNCTION__);
        close(fd);
        return 255;
    }

    max_brightness = strtol(value, NULL, 10);
    close(fd);

    return (unsigned int) max_brightness;
}

static int
set_light_backlight(struct light_device_t* dev,
        struct light_state_t const* state)
{
	int err = 0;
	int brightness = rgb_to_brightness(state);
	int max_brightness = get_light_max_backlight();

	if(!dev) {
        return -1;
	}

	if(brightness > 0) {
#ifdef ENABLE_GAMMA_CORRECTION
        brightness = brightness_apply_gamma(brightness);
#endif
        brightness = (max_brightness * brightness) / 255;
        if (brightness < LCD_BRIGHTNESS_MIN) {
            brightness = LCD_BRIGHTNESS_MIN;
        }
	}

	pthread_mutex_lock(&g_lcd_lock);
    err |= write_int(LCD_FILE, brightness);
#ifdef SECONDARY_BACKLIGHT
    err |= write_int(LCD2_FILE, brightness);
#endif
	pthread_mutex_unlock(&g_lcd_lock);
	return err;
}

static int
set_speaker_light_locked(struct light_device_t* dev,
        struct light_state_t const* state)
{
	int red, green, blue;
	int flashMode;
	int onMS, offMS;
	char *pattern = NULL;
	char delayOn[8], delayOff[8];
	unsigned int colorRGB;

	if(!dev) {
        return -1;
	}

	colorRGB = state->color;

	write_int(SYNC_LVBANKS, 1);

	red = (colorRGB >> 16) & 0xFF;
	green = (colorRGB >> 8) & 0xFF;
	blue = colorRGB & 0xFF;

	onMS = state->flashOnMS;
	offMS = state->flashOffMS;

	flashMode = state->flashMode;

	if(state->flashOnMS == 1) {
        flashMode = LIGHT_FLASH_NONE;
	} else {
        sprintf(delayOn,"%d", onMS);
        sprintf(delayOff,"%d", offMS);
        asprintf(&pattern,"%s,%s,100,100", delayOn, delayOff);
	}

#if 0
	ALOGD("set_speaker_light_locked mode %d, colorRGB=%08X, onMS=%d, offMS=%d\n",
            flashMode, colorRGB, onMS, offMS);
#endif

	switch (flashMode) {
        case LIGHT_FLASH_TIMED:
            write_string(RED_PATTERN_FILE, pattern);
            write_string(GREEN_PATTERN_FILE, pattern);
            write_string(BLUE_PATTERN_FILE, pattern);
            break;
        case LIGHT_FLASH_NONE:
        default:
            write_string(RED_PATTERN_FILE, PATTERNOFF);
            write_string(GREEN_PATTERN_FILE, PATTERNOFF);
            write_string(BLUE_PATTERN_FILE, PATTERNOFF);
            break;
	}

	write_int(RED_LED_FILE, red);
	write_int(GREEN_LED_FILE, green);
	write_int(BLUE_LED_FILE, blue);

	return 0;
}

static void
handle_speaker_battery_locked(struct light_device_t* dev)
{
	if (is_lit(&g_battery)) {
        set_speaker_light_locked(dev, &g_battery);
	} else {
        set_speaker_light_locked(dev, &g_notification);
	}
}

static int
set_light_battery(struct light_device_t* dev,
        struct light_state_t const* state)
{
	if(!dev) {
        return -1;
	}

	pthread_mutex_lock(&g_lock);
	g_battery = *state;
	handle_speaker_battery_locked(dev);
	pthread_mutex_unlock(&g_lock);
	return 0;
}

static int
set_light_notifications(struct light_device_t* dev,
        struct light_state_t const* state)
{
	if(!dev) {
        return -1;
	}

	pthread_mutex_lock(&g_lock);
	g_notification = *state;
	handle_speaker_battery_locked(dev);
	pthread_mutex_unlock(&g_lock);
	return 0;
}

/** Close the lights device */
static int
close_lights(struct light_device_t *dev)
{
	if (dev) {
        free(dev);
	}
	return 0;
}


/******************************************************************************/

/**
 * module methods
 */

/** Open a new instance of a lights device using name */
static int open_lights(const struct hw_module_t* module, char const* name,
        struct hw_device_t** device)
{
	int (*set_light)(struct light_device_t* dev,
        	struct light_state_t const* state);

	if (0 == strcmp(LIGHT_ID_BACKLIGHT, name))
        set_light = set_light_backlight;
	else if (0 == strcmp(LIGHT_ID_BATTERY, name))
        set_light = set_light_battery;
	else if (0 == strcmp(LIGHT_ID_NOTIFICATIONS, name))
        set_light = set_light_notifications;
	else
        return -EINVAL;

	pthread_once(&g_init, init_globals);

	struct light_device_t *dev = malloc(sizeof(struct light_device_t));

	if(!dev)
        return -ENOMEM;

	memset(dev, 0, sizeof(*dev));

	dev->common.tag = HARDWARE_DEVICE_TAG;
	dev->common.version = LIGHTS_DEVICE_API_VERSION_1_0;
	dev->common.module = (struct hw_module_t*)module;
	dev->common.close = (int (*)(struct hw_device_t*))close_lights;
	dev->set_light = set_light;

	*device = (struct hw_device_t*)dev;
	return 0;
}

static struct hw_module_methods_t lights_module_methods = {
	.open =  open_lights,
};

/*
 * The lights Module
 */
struct hw_module_t HAL_MODULE_INFO_SYM = {
	.tag = HARDWARE_MODULE_TAG,
	.version_major = 1,
	.version_minor = 0,
	.id = LIGHTS_HARDWARE_MODULE_ID,
	.name = "Fusion3 Lights Module",
	.author = "Google, Sony Mobile, Chippa_a",
	.methods = &lights_module_methods,
};
