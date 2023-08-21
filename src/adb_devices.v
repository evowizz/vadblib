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
module vadblib

pub fn (adb AndroidDebugBridge) devices() ![]Device {
	output := adb.run(command: 'devices -l')!
	return parse_devices(output, adb)
}

fn parse_devices(ro string, adb AndroidDebugBridge) ![]Device {
	// The first line is "List of devices attached"
	lines := ro.split_into_lines()[1..]

	mut results := [][]string{}
	for line in lines {
		parts := line.fields()
		results << parts
	}

	mut devices := []Device{}

	for res in results {
		serial := res[0]

		devices << Device{
			adb: adb
			features: adb.find_features(serial)!
			serial: serial
			state: res[1]
			product: find_result(res, 'product:')
			model: find_result(res, 'model:')
			device: find_result(res, 'device:')
		}
	}

	return devices
}

fn find_result(a []string, str string) ?string {
	for s in a {
		if s.starts_with(str) {
			return s.substr(str.len, s.len)
		}
	}

	return none
}
