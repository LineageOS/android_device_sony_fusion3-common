/*
 * Copyright (C) 2008 The Android Open Source Project
 * Copyright (C) 2013 Sony Mobile Communications AB
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

#include <cutils/log.h>
#include <stdint.h>
#include <limits.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdlib.h>
#include <pthread.h>

#include <sys/ioctl.h>
#include <sys/types.h>

#include <hardware/lights.h>

static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;

static struct light_state_t g_notification;
static struct light_state_t g_battery;
static struct light_state_t g_bluetooth;

enum led_class {
	LED_NONE,
	LED_RED,
	LED_GREEN,
	LED_BLUE,
	LED_BACKLIGHT,
};

struct led_desc {
	enum led_class led_class;
	int max_brightness;
	char brightness[PATH_MAX];
	char pattern[PATH_MAX];
	char als[PATH_MAX];
};

#define LED_DESC_CNT 10
static struct led_desc led_descs[LED_DESC_CNT];
static char sync_lvbanks[PATH_MAX];

static int write_string(const char *path, const char *value)
{
	static int already_warned = 0;
	int rc;
	int fd;

	fd = open(path, O_RDWR);
	if (fd < 0) {
		if (already_warned == 0) {
			ALOGE("write_string failed to open %s\n", path);
			already_warned = 1;
		}
		return -1;
	}

	rc = write(fd, value, strlen(value));
	close(fd);
	if (rc < 0)
		return -1;

	return 0;
}

static int write_int(const char *path, int value)
{
	char buffer[20];

	snprintf(buffer, sizeof(buffer), "%d\n", value);
	return write_string(path, buffer);
}

static int read_int(const char *path)
{
	static int already_warned = 0;
	char buffer[12];
	int fd, rc;

	fd = open(path, O_RDONLY);
	if (fd < 0) {
		if (already_warned == 0) {
			ALOGE("read_int failed to open %s\n", path);
			already_warned = 1;
		}
		return -1;
	}

	rc = read(fd, buffer, sizeof(buffer) - 1);
	close(fd);
	if (rc <= 0)
		return -1;

	buffer[rc] = 0;

	return strtol(buffer, 0, 0);
}

static void write_class_scaled(enum led_class cls, int brightness,
		const char *pattern)
{
	int i;

	for (i = 0; i < LED_DESC_CNT; ++i) {
		int scaled;

		if (led_descs[i].led_class == LED_NONE)
			break;
		if (led_descs[i].led_class != cls)
			continue;

		if (led_descs[i].max_brightness <= 0)
			scaled = brightness;
		else
			scaled = brightness * led_descs[i].max_brightness / 255;

		if (pattern && led_descs[i].pattern[0])
			write_string(led_descs[i].pattern, pattern);

		write_int(led_descs[i].brightness, scaled);
	}
}

#define BACKLIGHT_CLASS "/sys/class/backlight/lcd-backlight/"
static void led_desc_enumerate(void)
{
	static int enumerated = 0;
	char max_brightness[PATH_MAX];
	struct led_desc *desc;
	struct dirent *ent;
	int use_bl_class;
	DIR *dir;
	int fd;

	if (enumerated)
		return;
	enumerated = 1;

	dir = opendir("/sys/class/leds");
	if (dir == NULL)
		return;

	use_bl_class = 0;
	desc = &led_descs[0];
	fd = open(BACKLIGHT_CLASS "brightness", O_RDWR);
	if (fd >= 0) {
		desc->led_class = LED_BACKLIGHT;
		snprintf(desc->brightness, sizeof(desc->brightness),
				BACKLIGHT_CLASS "brightness");
		snprintf(max_brightness, sizeof(max_brightness),
				BACKLIGHT_CLASS "max_brightness");
		desc->max_brightness = read_int(max_brightness);
		if (desc->max_brightness <= 0 || desc->max_brightness == 255)
			desc->max_brightness = -1;
		desc++;
		use_bl_class = 1;
		close(fd);
	}

	while ((ent = readdir(dir)) != NULL) {
		if (strncmp(ent->d_name, "lm3533-", 7))
			continue;

		if (!strcmp(ent->d_name + 7, "red"))
			desc->led_class = LED_RED;
		else if (!strcmp(ent->d_name + 7, "green"))
			desc->led_class = LED_GREEN;
		else if (!strcmp(ent->d_name + 7, "blue"))
			desc->led_class = LED_BLUE;
		else if (use_bl_class)
			continue;
		else if (!strcmp(ent->d_name + 7, "lcd-bl"))
			desc->led_class = LED_BACKLIGHT;
		else if (!strncmp(ent->d_name + 7, "lcd-bl-", 7))
			desc->led_class = LED_BACKLIGHT;
		else
			continue;

		ALOGI("found light \"%s\"\n", ent->d_name);
		snprintf(desc->brightness, sizeof(desc->brightness),
				"/sys/class/leds/%s/brightness", ent->d_name);
		if (desc->led_class == LED_BACKLIGHT) {
			snprintf(desc->als, sizeof(desc->als),
					"/sys/class/leds/%s/als_enable",
					ent->d_name);
		} else {
			snprintf(desc->pattern, sizeof(desc->pattern),
					"/sys/class/leds/%s/pattern",
					ent->d_name);
		}
		if (sync_lvbanks[0] == 0) {
			snprintf(sync_lvbanks, sizeof(sync_lvbanks),
					"/sys/class/leds/%s/device/sync_lvbanks",
					ent->d_name);
		}
		snprintf(max_brightness, sizeof(max_brightness),
				"/sys/class/leds/%s/max_brightness",
				ent->d_name);
		desc->max_brightness = read_int(max_brightness);
		if (desc->max_brightness <= 0 || desc->max_brightness == 255)
			desc->max_brightness = -1;
		desc++;
		if (desc - &led_descs[0] >= LED_DESC_CNT)
			break;
	}

	closedir(dir);
}

static int is_lit(struct light_state_t const* state)
{
	return state->color & 0x00ffffff;
}

static int rgb_to_brightness(struct light_state_t const* state)
{
	int color = state->color & 0x00ffffff;
	return ((77*((color>>16)&0x00ff))
			+ (150*((color>>8)&0x00ff)) + (29*(color&0x00ff))) >> 8;
}

static int set_light_backlight(struct light_device_t *dev, struct light_state_t const *state)
{
	int brightness = rgb_to_brightness(state);

	pthread_mutex_lock(&g_lock);
	write_class_scaled(LED_BACKLIGHT, brightness, NULL);
	pthread_mutex_unlock(&g_lock);

	return 0;
}

static void set_shared_light_locked(struct light_device_t *dev, struct light_state_t *state)
{
	char pattern[44];
	int delayOff;
	int delayOn;
	int i;

	if (state->flashMode != LIGHT_FLASH_NONE) {
		delayOn = state->flashOnMS;
		delayOff = state->flashOffMS;
	} else {
		delayOn = 0;
		delayOff = 0;
	}

	snprintf(pattern, sizeof(pattern), "%u,%u,%u,%u",
		delayOn, delayOff, delayOn / 4, delayOff / 4);

	write_class_scaled(LED_RED, (state->color >> 16) & 0xFF, pattern);
	write_class_scaled(LED_GREEN, (state->color >> 8) & 0xFF, pattern);
	write_class_scaled(LED_BLUE, (state->color) & 0xFF, pattern);
	/* Sync the patterns, so it's possible to blink with white color */
	write_int(sync_lvbanks, 1);
}

static void handle_shared_battery_locked(struct light_device_t *dev)
{
	if (is_lit(&g_notification))
		set_shared_light_locked(dev, &g_notification);
	else if (is_lit(&g_battery))
		set_shared_light_locked(dev, &g_battery);
	else
		set_shared_light_locked(dev, &g_bluetooth);
}

static int set_light_bluetooth(struct light_device_t *dev, struct light_state_t const* state)
{
	pthread_mutex_lock (&g_lock);
	g_bluetooth = *state;
	handle_shared_battery_locked(dev);
	pthread_mutex_unlock (&g_lock);
	return 0;
}

static int set_light_battery(struct light_device_t *dev, struct light_state_t const* state)
{
	pthread_mutex_lock (&g_lock);
	g_battery = *state;
	handle_shared_battery_locked(dev);
	pthread_mutex_unlock (&g_lock);
	return 0;
}

static int set_light_notifications(struct light_device_t *dev, struct light_state_t const* state)
{
	pthread_mutex_lock (&g_lock);
	g_notification = *state;
	handle_shared_battery_locked(dev);
	pthread_mutex_unlock (&g_lock);
	return 0;
}

static int close_lights(struct light_device_t *dev)
{
	free(dev);
	return 0;
}

static int open_lights(const struct hw_module_t* module, char const* name,
						struct hw_device_t** device)
{
	struct light_state_t light_off = { 0 };
	struct light_device_t *dev;
	int (*set_light)(struct light_device_t* dev,
					 struct light_state_t const *state);

	if (strcmp(name, LIGHT_ID_BACKLIGHT) == 0) {
		set_light = set_light_backlight;
	} else if (strcmp(name, LIGHT_ID_BATTERY) == 0) {
		set_light = set_light_battery;
	} else if (strcmp(name, LIGHT_ID_BLUETOOTH) == 0) {
		set_light = set_light_bluetooth;
	} else if (strcmp(name, LIGHT_ID_NOTIFICATIONS) == 0) {
		set_light = set_light_notifications;
	} else {
		ALOGD("don't have light \"%s\"\n", name);
		return -EINVAL;
	}

	led_desc_enumerate();

	ALOGI("registering light \"%s\"\n", name);

	dev = calloc(1, sizeof(struct light_device_t));
	if (dev == NULL)
		return -ENOMEM;

	dev->common.tag		= HARDWARE_DEVICE_TAG;
	dev->common.version	= 0;
	dev->common.module	= (struct hw_module_t*)module;
	dev->common.close	= (int (*)(struct hw_device_t*))close_lights;
	dev->set_light		= set_light;

	if (set_light != set_light_backlight)
		(* set_light)(dev, &light_off);

	*device = (struct hw_device_t*)dev;
	return 0;
}

static struct hw_module_methods_t lights_module_methods = {
	.open = open_lights,
};


struct hw_module_t HAL_MODULE_INFO_SYM = {
	.tag = HARDWARE_MODULE_TAG,
	.version_major = 1,
	.version_minor = 0,
	.id = LIGHTS_HARDWARE_MODULE_ID,
	.name = "C5503/C6503/C6603 lights module",
	.author = "Bjorn Andersson <bjorn.andersson@sonymobile.com>",
	.methods = &lights_module_methods,
};
