#!/usr/bin/env python3
"""Read and set the applications that open each kind of file or link.

Usage: default-apps.py --read
       default-apps.py <mime type> <desktop entry>

The answer covers the kinds a desktop offers a choice for, each with the entry
that opens it now and the entries that say they can open it. Names come from the
desktop entries themselves, so they read the way the application calls itself.
"""

import json
import os
import re
import subprocess
import sys

ROLES = [
    ('web', 'Web', 'x-scheme-handler/http'),
    ('mail', 'Mail', 'x-scheme-handler/mailto'),
    ('calendar', 'Calendar', 'text/calendar'),
    ('music', 'Music', 'audio/mpeg'),
    ('video', 'Video', 'video/mp4'),
    ('photos', 'Photos', 'image/jpeg'),
    ('text', 'Text', 'text/plain'),
    ('files', 'Files', 'inode/directory'),
]

DEFAULT_LINE = re.compile(r'^Default application for .*:\s*(\S+)\s*$')


def run(command):
    try:
        return subprocess.run(command, capture_output=True, text=True, check=False,
                              env=dict(os.environ, LC_ALL='C')).stdout
    except FileNotFoundError:
        return ''


def application_directories():
    data_home = os.environ.get('XDG_DATA_HOME') or os.path.expanduser('~/.local/share')
    data_dirs = os.environ.get('XDG_DATA_DIRS') or '/usr/local/share:/usr/share'
    return [os.path.join(path, 'applications') for path in [data_home] + data_dirs.split(':')]


def entry_name(entry):
    for directory in application_directories():
        path = os.path.join(directory, entry)
        if not os.path.exists(path):
            continue
        with open(path, errors='replace') as handle:
            for line in handle:
                if line.startswith('Name='):
                    return line[len('Name='):].strip()
        break
    return entry[:-len('.desktop')] if entry.endswith('.desktop') else entry


def query(mime):
    reply = run(['gio', 'mime', mime])
    default = ''
    candidates = []
    section = ''
    for line in reply.splitlines():
        found = DEFAULT_LINE.match(line)
        if found:
            default = found.group(1)
            continue
        if line.endswith('applications:'):
            section = line
            continue
        entry = line.strip()
        if section.startswith('Registered') and entry.endswith('.desktop') and entry not in candidates:
            candidates.append(entry)
    if default and default not in candidates:
        candidates.insert(0, default)
    return default, candidates


def read():
    roles = []
    for key, title, mime in ROLES:
        default, candidates = query(mime)
        if not candidates:
            continue
        roles.append({
            'key': key,
            'title': title,
            'mime': mime,
            'default': default,
            'candidates': [{'entry': entry, 'name': entry_name(entry)} for entry in candidates],
        })
    print(json.dumps(roles))


def main():
    args = sys.argv[1:]
    if len(args) == 1 and args[0] == '--read':
        read()
        return 0

    if len(args) != 2:
        print(__doc__, file=sys.stderr)
        return 2

    run(['gio', 'mime', args[0], args[1]])
    return 0


if __name__ == '__main__':
    sys.exit(main())
