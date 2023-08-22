module vadblib

import os

fn execute(target string, args ...string) !string {
	mut cmd_array := [target]
	cmd_array << args
	cmd := cmd_array.join(' ')

	res := os.execute(cmd)
	output := res.output.trim_space()
	if res.exit_code != 0 {
		return error(output)
	}

	return output
}
