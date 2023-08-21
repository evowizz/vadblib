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
import os

const (
	// 54 should be enough for most cases.
	initial_execute_size = 54
	raw_header_size      = 4
)

struct AndroidDebugBridge {
	executable string
}

// RunParams specifies the parameters for the `run` function.
[params]
pub struct RunParams {
pub:
	command      string
	serial       string
	transport_id string
	usb          bool
}

pub fn AndroidDebugBridge.new() !AndroidDebugBridge {
	path := find_adb()!
	return AndroidDebugBridge{
		executable: path
	}
}

fn (adb AndroidDebugBridge) execute(args ...string) !string {
	mut sb := strings.new_builder(vadblib.initial_execute_size)
	sb.write_string(adb.executable)
	for arg in args {
		sb.write_string(' ')
		sb.write_string(arg)
	}
	cmd := sb.str()

	res := os.execute(cmd)
	output := res.output.trim_space()
	if res.exit_code != 0 {
		return error(output)
	}

	return output
}

// run executes adb with the given `command`, and returns the output.
// A target may be specified by `serial`, `transport_id` or `usb`.
pub fn (adb AndroidDebugBridge) run(params RunParams) !string {
	command := params.command.trim_space()
	if command.len == 0 {
		return error('Command is empty')
	}

	if command == 'shell' {
		return error('Command "shell" is not allowed')
	}

	mut args := []string{}
	args << find_target(params.serial, params.usb, params.transport_id)
	args << command
	return adb.execute(...args)
}

fn find_target(serial string, usb bool, transport_id string) string {
	if serial.len > 0 {
		return '-s ${serial}'
	}

	if transport_id.len > 0 {
		return '-t ${transport_id}'
	}

	if usb {
		return '-d'
	}

	return ''
}
