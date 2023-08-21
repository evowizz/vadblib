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

import strings

struct Device {
	adb AndroidDebugBridge [required]
pub:
	serial   string       [required]
	state    string       [required]
	product  ?string
	model    ?string
	device   ?string
	features []AdbFeature [required]
}

// run executes an adb command while targeting this specific device.
pub fn (d Device) run(command string) !string {
	return d.adb.run(
		command: command
		serial: d.serial
	)!
}

pub fn (d Device) run_shell(command string) !string {
	return d.run('shell ${command}')!
}

pub fn (d Device) str() string {
	serial := d.serial
	state := d.state

	mut sb := strings.new_builder(128)

	sb.write_string('Serial: ')
	sb.write_string(serial)
	sb.write_string(', ')
	sb.write_string('State: ')
	sb.write_string(state)

	if product := d.product {
		sb.write_string(', ')
		sb.write_string('Product: ')
		sb.write_string(product)
	}

	if model := d.model {
		sb.write_string(', ')
		sb.write_string('Model: ')
		sb.write_string(model)
	}

	if device := d.device {
		sb.write_string(', ')
		sb.write_string('Device: ')
		sb.write_string(device)
	}

	sb.write_string(', ')
	sb.write_string('Features: ')
	sb.write_string(d.features.str())

	return sb.str()
}
