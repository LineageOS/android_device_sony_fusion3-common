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

"""Custom OTA Package commands for fusion3"""

def FullOTA_InstallBegin(self):
  self.script.Mount("/system")
  self.script.AppendExtra('run_program("if ( ! grep -q ^ro.cm.version=10.2.* /system/build.prop ); then rm -rf /data/qcks; fi");')
  self.script.Unmount("/system")
