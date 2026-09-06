#!/usr/bin/env python3
"""Read Hyprland options and set them in a Hyprland lua config.

Usage: hypr-config.py --read <option> [option ...]
       hypr-config.py <file> <option>=<value> [<option>=<value> ...]

An option is named the way hyprctl names it, such as decoration:blur:enabled.
Reading asks the running Hyprland, so it answers with what is in force rather
than with what any one file asks for.

Each option owns one line of the file, holding the nested table its name spells
out. A line is rewritten in place, so the values a person put around it and the
order of the file survive; an option with no line yet gets one appended.
"""

import json
import re
import subprocess
import sys

def run(command):
    try:
        return subprocess.run(command, capture_output=True, text=True, check=False).stdout
    except FileNotFoundError:
        return ''


def read(options):
    state = {}
    for option in options:
        try:
            reply = json.loads(run(['hyprctl', 'getoption', option, '-j']) or '{}')
        except json.JSONDecodeError:
            continue
        for kind in ('int', 'float', 'bool', 'str', 'css', 'vec2'):
            if kind in reply:
                state[option] = reply[kind]
                break
    print(json.dumps(state))


def render(value):
    # A number stays a number: an option whose value is 1 is not the boolean true.
    if value in ('true', 'false'):
        return value
    try:
        float(value)
    except ValueError:
        return '"%s"' % value
    return value


def line_for(option, value):
    keys = option.split(':')
    body = '%s = %s' % (keys[-1], render(value))
    for key in reversed(keys[:-1]):
        body = '%s = { %s }' % (key, body)
    return 'hl.config({ %s })' % body


def prefix_for(option):
    return line_for(option, '').rsplit('=', 1)[0] + '='


def set_option(text, option, value):
    prefix = prefix_for(option)
    pattern = re.compile(r'^%s.*$' % re.escape(prefix), re.M)
    if pattern.search(text):
        return pattern.sub(line_for(option, value), text, count=1)
    return text.rstrip('\n') + '\n' + line_for(option, value) + '\n'


def main():
    args = sys.argv[1:]
    if len(args) > 1 and args[0] == '--read':
        read(args[1:])
        return 0

    if len(args) < 2:
        print(__doc__, file=sys.stderr)
        return 2

    path = args[0]
    try:
        with open(path) as handle:
            text = handle.read()
    except FileNotFoundError:
        text = ''

    for pair in args[1:]:
        option, _, value = pair.partition('=')
        text = set_option(text, option, value)

    with open(path, 'w') as handle:
        handle.write(text)
    return 0


if __name__ == '__main__':
    sys.exit(main())
