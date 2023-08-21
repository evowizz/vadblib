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

[params]
pub struct InstallParams {
	files             []string
	replace           bool // -r
	test              bool // -t
	downgrade         bool // -d
	partial           bool // -p
	grant_permissions bool // -g
}

pub fn (d Device) install(params InstallParams) ! {
	files := verify_params(params, d.features)!

	// We use `install-multi-package` even if there is only one file
	// because unlike `install`, it supports one or more files.
	cmd := format_command('install-multi-package', files, params)
	d.run(cmd)!
}

pub fn (d Device) install_multiple(params InstallParams) ! {
	files := verify_params(params, d.features)!
	cmd := format_command('install-multiple', files, params)
	d.run(cmd)!
}

fn verify_params(params InstallParams, features []AdbFeature) ![]string {
	files := params.files
	if files.len == 0 {
		return error('Files cannot be empty')
	}

	supports_apex := features.contains(AdbFeature.apex)
	trimmed_files := files.map(it.trim_space())

	for file in trimmed_files {
		if !file.ends_with('.apex') && !file.ends_with('.apk') {
			return error('All files must be .apk or .apex')
		}

		is_apex := file.ends_with('.apex')
		if is_apex && !supports_apex {
			return error('Device does not support APEX packages')
		}

		if !os.exists(file) {
			return error('File does not exist: ' + file)
		}
	}

	if params.partial && trimmed_files.len == 1 {
		return error('Partial install requires multiple files')
	}

	return trimmed_files
}

fn format_command(base string, files []string, params InstallParams) string {
	mut cmd := [base]
	if params.replace {
		cmd << '-r'
	}

	if params.test {
		cmd << '-t'
	}

	if params.downgrade {
		cmd << '-d'
	}

	if params.partial {
		cmd << '-p'
	}

	if params.grant_permissions {
		cmd << '-g'
	}

	cmd << files.map(os.quoted_path(it))

	return cmd.join(' ')
}
