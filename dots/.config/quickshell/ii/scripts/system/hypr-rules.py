#!/usr/bin/env python3
"""Read and edit the per-application window rules in a Hyprland lua config.

Usage: hypr-rules.py --read <file>
       hypr-rules.py <file> --add <class> <rule> <value>
       hypr-rules.py <file> --remove <class> <rule>

A rule is one line holding one match and one setting, which is what makes it
possible to take a single rule away again. Lines a person wrote themselves, in
any other shape, are read but never rewritten.
"""

import json
import re
import sys

RULE = re.compile(
    r'^hl\.window_rule\(\{\s*match\s*=\s*\{\s*class\s*=\s*"\^\((?P<klass>[^"]*)\)\$"\s*\}\s*,\s*'
    r'(?P<rule>\w+)\s*=\s*(?P<value>[^}]*?)\s*\}\)\s*$'
)


def render(value):
    if value in ('true', 'false'):
        return value
    try:
        float(value)
    except ValueError:
        return '"%s"' % value
    return value


def line_for(klass, rule, value):
    return 'hl.window_rule({ match = { class = "^(%s)$" }, %s = %s })' % (klass, rule, render(value))


def contents(path):
    try:
        with open(path) as handle:
            return handle.read()
    except FileNotFoundError:
        return ''


def read(path):
    found = []
    for line in contents(path).splitlines():
        match = RULE.match(line.strip())
        if not match:
            continue
        found.append({
            'class': match.group('klass'),
            'rule': match.group('rule'),
            'value': match.group('value').strip('"'),
        })
    print(json.dumps(found))


def write(path, text):
    with open(path, 'w') as handle:
        handle.write(text)


def add(path, klass, rule, value):
    text = contents(path)
    kept = [line for line in text.splitlines() if not is_rule(line, klass, rule)]
    kept.append(line_for(klass, rule, value))
    write(path, '\n'.join(kept).rstrip('\n') + '\n')


def is_rule(line, klass, rule):
    match = RULE.match(line.strip())
    return bool(match) and match.group('klass') == klass and match.group('rule') == rule


def remove(path, klass, rule):
    text = contents(path)
    kept = [line for line in text.splitlines() if not is_rule(line, klass, rule)]
    write(path, '\n'.join(kept).rstrip('\n') + '\n')


def main():
    args = sys.argv[1:]
    if len(args) == 2 and args[0] == '--read':
        read(args[1])
        return 0

    if len(args) == 5 and args[1] == '--add':
        add(args[0], args[2], args[3], args[4])
        return 0

    if len(args) == 4 and args[1] == '--remove':
        remove(args[0], args[2], args[3])
        return 0

    print(__doc__, file=sys.stderr)
    return 2


if __name__ == '__main__':
    sys.exit(main())
