/*
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

#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>

#define LOG_TAG "libals-lm3533"

#define ALS_LOC "/sys/devices/i2c-0/0-0036"
#define ALS_ENABLE ALS_LOC "/als_enable"
#define ALS_RESULT ALS_LOC "/als_result"

static int als_enabled = 0;

static int als_enable_write(int on)
{
	int rc;
	int fd;

	fd = open(ALS_ENABLE, O_RDWR);
	if (fd < 0)
		return -errno;
	rc = write(fd, on ? "1\n" : "0\n", 2);
	close(fd);
	if (rc <= 0)
		return -errno;
	als_enabled = on;
	return 0;
}

static int als_result_read(void)
{
	char buf[12];
	int rc;
	int fd;

	fd = open(ALS_RESULT, O_RDONLY);
	if (fd < 0)
		return -errno;
	rc = read(fd, buf, sizeof(buf) - 1);
	close(fd);
	if (rc <= 0)
		return -errno;
	buf[rc] = 0;
	return strtol(buf, 0, 0);
}

int als_enable(void)
{
	return als_enable_write(1);
}

int als_disable(void)
{
	return als_enable_write(0);
}

int als_getlux(float *data)
{
	int rc;

	if (!als_enabled) {
		rc = als_enable();
		if (rc)
			return rc;
	}

	rc = als_result_read();
	if (rc < 0)
		return rc;
	*data = rc;

	return 0;
}
