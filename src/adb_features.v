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

// Adb features based on:
// https://android.googlesource.com/platform/packages/modules/adb/+/36c8520873d5bd62e3a022bbed0e8832ce6f3047/transport.cpp#77
pub enum AdbFeature {
	shell_v2
	cmd
	stat_v2
	ls_v2
	libusb
	push_sync
	apex
	fixed_push_mkdir
	abb
	fixed_push_symlink_timestamp
	abb_exec
	remount_shell
	track_app
	sendrecv_v2
	sendrecv_v2_brotli
	sendrecv_v2_lz4
	sendrecv_v2_zstd
	sendrecv_v2_dry_run_send
	delayed_ack
	openscreen_mdns
}

pub fn adb_feature_from_string(feature string) !AdbFeature {
	return match feature {
		'shell_v2' { .shell_v2 }
		'cmd' { .cmd }
		'stat_v2' { .stat_v2 }
		'ls_v2' { .ls_v2 }
		'libusb' { .libusb }
		'push_sync' { .push_sync }
		'apex' { .apex }
		'fixed_push_mkdir' { .fixed_push_mkdir }
		'abb' { .abb }
		'fixed_push_symlink_timestamp' { .fixed_push_symlink_timestamp }
		'abb_exec' { .abb_exec }
		'remount_shell' { .remount_shell }
		'track_app' { .track_app }
		'sendrecv_v2' { .sendrecv_v2 }
		'sendrecv_v2_brotli' { .sendrecv_v2_brotli }
		'sendrecv_v2_lz4' { .sendrecv_v2_lz4 }
		'sendrecv_v2_zstd' { .sendrecv_v2_zstd }
		'sendrecv_v2_dry_run_send' { .sendrecv_v2_dry_run_send }
		'delayed_ack' { .delayed_ack }
		'openscreen_mdns' { .openscreen_mdns }
		else { return error('Unknown feature: ${feature}') }
	}
}

fn (adb AndroidDebugBridge) find_features(serial string) ![]AdbFeature {
	output := adb.run(
		command: 'features'
		serial: serial
	)!
	return parse_features(output)
}

fn parse_features(input string) []AdbFeature {
	raw_features := input.split_into_lines()

	mut features := []AdbFeature{}
	for feature in raw_features {
		features << adb_feature_from_string(feature) or { continue }
	}

	return features
}
