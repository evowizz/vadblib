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

enum TransferCompression {
	@none
	any
	brotli
	lz4
	zstd
}

fn (t TransferCompression) to_param() string {
	return match t {
		.@none { '-Z' }
		.any { '-z any' }
		.brotli { '-z brotli' }
		.lz4 { '-z lz4' }
		.zstd { '-z zstd' }
	}
}

[params]
pub struct PullParams {
	sources         []string            [required]
	destination     string              [required]
	keep_attributes bool
	compression     TransferCompression = .@none
}

pub fn (d Device) pull(params PullParams) ! {
	mut cmd := ['pull']

	if params.keep_attributes {
		cmd << '-a'
	}

	cmd << params.compression.to_param()
	cmd << params.sources
	cmd << params.destination

	d.run(cmd.join(' '))!
}

[params]
pub struct PushParams {
	sources     []string            [required]
	destination string              [required]
	sync        bool
	compression TransferCompression = .@none
}

pub fn (d Device) push(params PushParams) ! {
	mut cmd := ['push']

	if params.sync {
		cmd << '--sync'
	}

	cmd << params.compression.to_param()
	cmd << params.sources
	cmd << params.destination

	d.run(cmd.join(' '))!
}
