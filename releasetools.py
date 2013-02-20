# Copyright (C) 2012 The Android Open Source Project
# Copyright (C) 2012 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Custom OTA Package commands for blue"""

import common
import os
import shutil

TARGET_DIR = os.getenv('OUT')

def FullOTA_Assertions(self):
  bootimage_path = os.path.join(TARGET_DIR, "boot.elf")
  prebuilt_dir = os.path.join(self.input_tmp, "BOOTABLE_IMAGES")
  prebuilt_path = os.path.join(prebuilt_dir, "boot.img")
  os.mkdir(prebuilt_dir)
  shutil.copyfile(bootimage_path, prebuilt_path)
