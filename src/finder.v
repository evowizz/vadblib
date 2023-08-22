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

import os

const (
	adb_filename       = get_platform_specific_adb_filename()
	possible_sdk_paths = get_platform_specific_paths()
)

pub fn find_adb() !string {
	if !is_os_supported() {
		return error('OS not supported')
	}

	sdk_root := get_sdk_path() or { return error('Could not find Android SDK') }
	platform_tools := os.join_path(sdk_root, 'platform-tools')
	adb_path := os.join_path(platform_tools, vadblib.adb_filename)

	if !os.exists(adb_path) {
		return error('Could not find adb at ${adb_path}')
	}

	if !os.is_executable(adb_path) {
		return error('adb found but is not executable')
	}

	return adb_path
}

fn get_sdk_path() ?string {
	for dir in vadblib.possible_sdk_paths {
		if os.exists(dir) && os.is_dir(dir) {
			return dir
		}
	}

	return none
}

fn is_os_supported() bool {
	$if windows || macos || linux {
		return true
	} $else {
		return false
	}
}

fn get_platform_specific_adb_filename() string {
	return $if windows {
		'adb.exe'
	} $else {
		'adb'
	}
}

fn get_platform_specific_paths() []string {
	return $if macos {
		[
			os.getenv('ANDROID_SDK_ROOT'),
			os.join_path(os.getenv('HOME'), 'Library', 'Android', 'sdk'),
		]
	} $else $if windows {
		[
			os.getenv('ANDROID_SDK_ROOT'),
			os.join_path(os.getenv('LOCALAPPDATA'), 'Android', 'Sdk'),
		]
	} $else $if linux {
		[
			os.getenv('ANDROID_SDK_ROOT'),
			os.join_path(os.getenv('HOME'), 'Android', 'Sdk'),
		]
	} $else {
		[
			os.getenv('ANDROID_SDK_ROOT'),
		]
	}
}
