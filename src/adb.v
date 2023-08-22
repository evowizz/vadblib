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
)

struct AndroidDebugBridge {
	executable string
pub:
	version       string
	build_version string
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

pub fn AndroidDebugBridge.new(path string) !AndroidDebugBridge {
	if !os.exists(path) {
		return error('Executable does not exist')
	}

	if !os.is_executable(path) {
		return error('Executable is not executable')
	}

	// Check the adb version.
	output := execute(path, 'version')!
	if output.trim_space().len == 0 {
		return error('Failed to get adb version')
	}

	// The output may have 3 or more lines. But we only need the first 2 lines.
	// Example:
	// Android Debug Bridge version 1.0.41
	// Version 31.0.3-7562133
	lines := output.split_into_lines()

	version := lines[0].split(' ').last()
	build_version := lines[1].fields().last()

	return AndroidDebugBridge{
		executable: path
		version: version
		build_version: build_version
	}
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
	return execute(adb.executable, ...args)
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

fn execute(target string, args ...string) !string {
	mut sb := strings.new_builder(vadblib.initial_execute_size)
	sb.write_string(target)
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
