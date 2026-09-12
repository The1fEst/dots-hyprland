#!/usr/bin/env python3
"""Set keys on one monitor block in a Hyprland lua monitor config.

Usage: hypr-monitor.py <file> <output> key=value [key=value ...]
       hypr-monitor.py <file> --primary <output>
       hypr-monitor.py --read <file>
       hypr-monitor.py --icc-profiles

Only the named keys of the named output are touched. Every other key of that
block, every other block and the layout of the file are left as they are, which
is what keeps hand-written settings such as the HDR ones on a monitor intact.
Values that look numeric are written bare, a value already in braces is written
as the lua table it is, and everything else is quoted. An output with no block
yet gets one appended.

Reading gives back what each block asks for rather than what Hyprland ended up
with, which is the difference between a colour profile of "auto" and the profile
auto resolved to.

Hyprland has no primary monitor, so the one Windows applications open on is an
environment variable rather than a rule, and it is written as one.
"""

import json
import os
import re
import sys

# A monitor rule's reserved area is a lua table, so a value runs to the end of the line
# unless it is braced.
VALUE = r'\{[^}]*\}|[^,\n]*'

PRIMARY_VARIABLE = 'WAYLANDDRV_PRIMARY_MONITOR'

ICC_DIRECTORIES = [
    os.path.expanduser('~/.local/share/icc'),
    os.path.expanduser('~/.color/icc'),
    '/usr/local/share/color/icc',
    '/usr/share/color/icc',
]


def is_number(value):
    try:
        float(value)
    except ValueError:
        return False
    return True


def render(value):
    if value.startswith('{'):
        return value
    return value if is_number(value) else '"%s"' % value


def icc_profiles():
    found = []
    for directory in ICC_DIRECTORIES:
        for root, _, names in os.walk(directory):
            found += [os.path.join(root, name) for name in names if name.lower().endswith(('.icc', '.icm'))]
    return sorted(found)


def blocks(text):
    for match in re.finditer(r'hl\.monitor\(\{.*?\}\)', text, re.DOTALL):
        yield match


def output_of(block):
    match = re.search(r'output\s*=\s*"([^"]+)"', block)
    return match.group(1) if match else None


def keys_of(block):
    pairs = re.findall(r'\n[ \t]*(\w+)[ \t]*=[ \t]*(%s)' % VALUE, block)
    return {key: value.strip().strip('"') for key, value in pairs}


def contents(path):
    try:
        with open(path) as handle:
            return handle.read()
    except FileNotFoundError:
        return ''


def primary_of(text):
    match = re.search(r'hl\.env\(\s*"%s"\s*,\s*"([^"]*)"' % PRIMARY_VARIABLE, text)
    return match.group(1) if match else ''


def read(path):
    text = contents(path)
    print(json.dumps({
        'monitors': {output_of(m.group(0)): keys_of(m.group(0)) for m in blocks(text) if output_of(m.group(0))},
        'primary': primary_of(text),
    }))


def set_primary(path, output):
    text = contents(path)
    pattern = re.compile(r'(hl\.env\(\s*"%s"\s*,\s*")[^"]*(")' % PRIMARY_VARIABLE)
    line = 'hl.env("%s", "%s")' % (PRIMARY_VARIABLE, output)
    if pattern.search(text):
        text = pattern.sub(lambda m: m.group(1) + output + m.group(2), text, count=1)
    else:
        text = text.rstrip('\n') + '\n' + line + '\n'

    with open(path, 'w') as handle:
        handle.write(text)


def set_key(block, key, value):
    pattern = re.compile(r'(\n\s*%s\s*=\s*)(%s)(,?)' % (re.escape(key), VALUE))
    if pattern.search(block):
        return pattern.sub(lambda m: m.group(1) + render(value) + (m.group(3) or ','), block, count=1)
    return block.replace('\n})', '\n\t%s = %s,\n})' % (key, render(value)), 1)


def main():
    if len(sys.argv) == 3 and sys.argv[1] == '--read':
        read(sys.argv[2])
        return 0

    if len(sys.argv) == 2 and sys.argv[1] == '--icc-profiles':
        print(json.dumps(icc_profiles()))
        return 0

    if len(sys.argv) == 4 and sys.argv[2] == '--primary':
        set_primary(sys.argv[1], sys.argv[3])
        return 0

    if len(sys.argv) < 4:
        print(__doc__, file=sys.stderr)
        return 2

    path, output = sys.argv[1], sys.argv[2]
    pairs = [arg.split('=', 1) for arg in sys.argv[3:]]

    try:
        with open(path) as handle:
            text = handle.read()
    except FileNotFoundError:
        text = ''

    target = next((m for m in blocks(text) if output_of(m.group(0)) == output), None)
    if target is None:
        lines = ['hl.monitor({', '\toutput = "%s",' % output]
        lines += ['\t%s = %s,' % (key, render(value)) for key, value in pairs]
        lines += ['})', '']
        text = text.rstrip('\n') + ('\n\n' if text.strip() else '') + '\n'.join(lines)
    else:
        block = target.group(0)
        for key, value in pairs:
            block = set_key(block, key, value)
        text = text[:target.start()] + block + text[target.end():]

    with open(path, 'w') as handle:
        handle.write(text)
    return 0


if __name__ == '__main__':
    sys.exit(main())
