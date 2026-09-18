#!/usr/bin/env python3
"""Read and set per-device input settings in a Hyprland lua config.

Usage: hypr-device.py --read <file>
       hypr-device.py <file> --set <device> <key> <value>
       hypr-device.py <file> --unset <device> <key>

A device setting owns one line, which is what makes it possible to take a single
override away again and leave the device following the general settings.
"""

import json
import re
import sys

SETTING = re.compile(
    r'^hl\.device\(\{\s*name\s*=\s*"(?P<device>[^"]*)"\s*,\s*(?P<key>\w+)\s*=\s*(?P<value>[^}]*?)\s*\}\)\s*$'
)


def render(value):
    if value in ('true', 'false'):
        return value
    try:
        float(value)
    except ValueError:
        return '"%s"' % value
    return value


def line_for(device, key, value):
    return 'hl.device({ name = "%s", %s = %s })' % (device, key, render(value))


def contents(path):
    try:
        with open(path) as handle:
            return handle.read()
    except FileNotFoundError:
        return ''


def is_setting(line, device, key):
    match = SETTING.match(line.strip())
    return bool(match) and match.group('device') == device and match.group('key') == key


def read(path):
    found = []
    for line in contents(path).splitlines():
        match = SETTING.match(line.strip())
        if not match:
            continue
        found.append({
            'device': match.group('device'),
            'key': match.group('key'),
            'value': match.group('value').strip('"'),
        })
    print(json.dumps(found))


def write(path, lines):
    with open(path, 'w') as handle:
        handle.write('\n'.join(lines).rstrip('\n') + '\n')


def set_setting(path, device, key, value):
    kept = [line for line in contents(path).splitlines() if not is_setting(line, device, key)]
    kept.append(line_for(device, key, value))
    write(path, kept)


def unset(path, device, key):
    write(path, [line for line in contents(path).splitlines() if not is_setting(line, device, key)])


def main():
    args = sys.argv[1:]
    if len(args) == 2 and args[0] == '--read':
        read(args[1])
        return 0

    if len(args) == 5 and args[1] == '--set':
        set_setting(args[0], args[2], args[3], args[4])
        return 0

    if len(args) == 4 and args[1] == '--unset':
        unset(args[0], args[2], args[3])
        return 0

    print(__doc__, file=sys.stderr)
    return 2


if __name__ == '__main__':
    sys.exit(main())
