// Copyright 2023 Dylan Roussel
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
module main

import vadblib

fn main() {
	adb := vadblib.AndroidDebugBridge.new() or { panic(err) }

	adb.start() or { panic(err) }
	devices := adb.devices() or { panic(err) }

	if devices.len == 0 {
		println('No devices found')
		return
	}

	current := devices[0]
	release := current.run_shell('getprop ro.build.version.release') or { panic(err) }
	println('Android ${release}')
}
