/*
 * Copyright (C) 2016 The CyanogenMod Project
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

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdarg.h>
#include <string.h>

/*
 * This pathname is hardcoded in the proprietary mpdecision binary; it was used
 * on Android versions before 5.1.
 */
static const char old_path[] = "/dev/cpuctl/apps/cpu.notify_on_migrate";

/*
 * This pathname is actually used by the system since Android 5.1 - the "apps"
 * cgroup was removed, and foreground apps are placed in the root cgroup.
 */
static const char new_path[] = "/dev/cpuctl/cpu.notify_on_migrate";

int open(const char *pathname, int flags, ...)
{
    mode_t mode = 0;

    if (flags & O_CREAT) {
        va_list ap;
        va_start(ap, flags);
        mode = va_arg(ap, int);
        va_end(ap);
    }

    if (strcmp(pathname, old_path) == 0)
        pathname = new_path;

    return openat(AT_FDCWD, pathname, flags, mode);
}
