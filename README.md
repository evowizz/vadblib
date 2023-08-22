# VADBLIB - V ADB Library
VAdbLib allows you to use ADB commands in your V language projects.

## Installation
```bash
v install evowizz.vadblib
```

## Example
```v
import evowizz.vadblib

fn main() {
  // Find ADB, and create a new ADB instance
  adb_path := vadblib.find_adb() or { panic(err) }
  adb := vadblib.AndroidDebugBridge.new(adb_path) or { panic(err) }

  // Equivalent to `adb start-server`, you can also pass your own port
  adb.start() or { panic(err) }

  // Get the list of devices
  devices := adb.devices() or { panic(err) }

  if devices.len == 0 {
    println('No devices found')
    return
  }

  // Get the first device
  current := devices[0]

  // This is equivalent to `adb -s <serial> shell getprop ro.build.version.release`
  release := current.run_shell('getprop ro.build.version.release') or { panic(err) }
  println('Android ${release}')
}
```

## Documentation
VAdbLib is a simple wrapper around some of the most basic ADB commands. It is not meant to be a complete wrapper. Currently, the following commands are supported:

- `adb start-server`: `adb.start(<port>)`
- `adb kill-server`: `adb.kill()`

_Note: You can also restart the server with `adb.restart(<port>)`_

- `adb <target> <command>`: `adb.run(<command>, <serial>, <transport_id>, <usb>)`

_Note: If more than one target is provided (for example: `adb.run(command: "get-state", serial: "123", transport_id: "1", usb: true)`), serial will be prioritized, then transport_id, then usb._

- `adb -s <serial> pull <remote> <local>`: `device.pull(<sources>, <destination>, <keep_attributes>, <compression>)`
- `adb -s <serial> push <local> <remote>`: `device.push(<sources>, <destination>, <sync>, <compression>)`

- `adb devices -l`: `adb.devices()`
- `adb -s <serial> <command>`: `device.run(<command>)`
- `adb -s <serial> shell <command>`: `device.run_shell(<command>)`
- `adb -s <serial> install-multi-package <args> <files>`: `device.install(<files>, <replace>, <test>, <downgrade>, <partial>, <grant-permissions>)`  
- `adb -s <serial> install-multiple <args> <files>`: `device.install_multiple(<files>, <replace>, <test>, <downgrade>, <partial>, <grant-permissions>)`

_Note: `install-multi-package` is the same as `install`, but it allows you to optionally install multiple files at once. By passing a single file to `device.install`, it will work the same way `adb install` does._

VAdbLib may also run some additional commands in the background, such as `adb -s <serial> features`, allowing it to verify that some commands are supported by the device.

## License

[Apache License, Version 2.0](LICENSE)
```
Copyright 2023 Dylan Roussel

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```