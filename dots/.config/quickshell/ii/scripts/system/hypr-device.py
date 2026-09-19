#!/usr/bin/env python3
"""Read and set per-device input settings in a Hyprland lua config.

Usage: hypr-device.py --read <file>
       hypr-device.py <file> [--set <device> <key> <value> | --unset <device> <key>]...

A device setting owns one line, which is what makes it possible to take a single
override away again and leave the device following the general settings.

Several changes in one call are applied to one reading of the file, so a caller
taking three overrides away does not lose two of them to the other two writes.
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


def main():
    args = sys.argv[1:]
    if len(args) == 2 and args[0] == '--read':
        read(args[1])
        return 0

    if not args:
        print(__doc__, file=sys.stderr)
        return 2

    path, rest = args[0], args[1:]
    lines = contents(path).splitlines()
    while rest:
        if rest[0] == '--set' and len(rest) >= 4:
            device, key, value = rest[1:4]
            lines = [line for line in lines if not is_setting(line, device, key)]
            lines.append(line_for(device, key, value))
            rest = rest[4:]
        elif rest[0] == '--unset' and len(rest) >= 3:
            device, key = rest[1:3]
            lines = [line for line in lines if not is_setting(line, device, key)]
            rest = rest[3:]
        else:
            print(__doc__, file=sys.stderr)
            return 2

    write(path, lines)
    return 0


if __name__ == '__main__':
    sys.exit(main())
