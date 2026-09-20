#!/usr/bin/env python3
"""Read and set the applications that open each kind of file or link.

Usage: default-apps.py --read
       default-apps.py <mime type> <desktop entry>

The answer covers the kinds a desktop offers a choice for, each with the entry
that opens it now and the entries that say they can open it. Names come from the
desktop entries themselves, so they read the way the application calls itself.

Reading follows the association files the way the spec lays them out, in one pass
over them, rather than asking a tool per kind.
https://specifications.freedesktop.org/mime-apps-spec/latest/
"""

import json
import os
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


def run(command):
    try:
        return subprocess.run(command, capture_output=True, text=True, check=False,
                              env=dict(os.environ, LC_ALL='C')).stdout
    except FileNotFoundError:
        return ''


def data_directories():
    data_home = os.environ.get('XDG_DATA_HOME') or os.path.expanduser('~/.local/share')
    data_dirs = os.environ.get('XDG_DATA_DIRS') or '/usr/local/share:/usr/share'
    return [data_home] + data_dirs.split(':')


def application_directories():
    return [os.path.join(path, 'applications') for path in data_directories()]


def association_files():
    config_home = os.environ.get('XDG_CONFIG_HOME') or os.path.expanduser('~/.config')
    config_dirs = os.environ.get('XDG_CONFIG_DIRS') or '/etc/xdg'
    desktops = [name.lower() for name in (os.environ.get('XDG_CURRENT_DESKTOP') or '').split(':') if name]
    paths = []
    for directory in [config_home] + config_dirs.split(':') + application_directories():
        paths.extend(os.path.join(directory, f'{desktop}-mimeapps.list') for desktop in desktops)
        paths.append(os.path.join(directory, 'mimeapps.list'))
    return paths


def sections(path):
    found = {}
    current = None
    try:
        handle = open(path, errors='replace')
    except OSError:
        return found
    with handle:
        for line in handle:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if line.startswith('[') and line.endswith(']'):
                current = found.setdefault(line[1:-1], {})
                continue
            if current is None or '=' not in line:
                continue
            key, _, value = line.partition('=')
            current.setdefault(key.strip(), value.strip())
    return found


def entries(value):
    return [entry for entry in value.split(';') if entry]


def installed():
    known = {}
    for directory in application_directories():
        try:
            names = sorted(os.listdir(directory))
        except OSError:
            continue
        for name in names:
            if name.endswith('.desktop'):
                known.setdefault(name, os.path.join(directory, name))
    return known


def entry_name(entry, path):
    with open(path, errors='replace') as handle:
        for line in handle:
            if line.startswith('Name='):
                return line[len('Name='):].strip()
    return entry[:-len('.desktop')]


def subclasses():
    parents = {}
    for directory in data_directories():
        try:
            handle = open(os.path.join(directory, 'mime', 'subclasses'), errors='replace')
        except OSError:
            continue
        with handle:
            for line in handle:
                child, _, parent = line.strip().partition(' ')
                if child and parent:
                    parents.setdefault(child, []).append(parent)
    return parents


def family(mime, parents):
    chain = [mime]
    for kind in chain:
        chain.extend(parent for parent in parents.get(kind, []) if parent not in chain)
    return chain


def associations():
    registered = {}
    for directory in application_directories():
        for mime, value in sections(os.path.join(directory, 'mimeinfo.cache')).get('MIME Cache', {}).items():
            registered.setdefault(mime, []).extend(entries(value))

    defaults = {}
    removed = {}
    added = {}
    for path in association_files():
        found = sections(path)
        for mime, value in found.get('Default Applications', {}).items():
            defaults.setdefault(mime, []).extend(entries(value))
        for mime, value in found.get('Removed Associations', {}).items():
            removed.setdefault(mime, []).extend(entries(value))
        for mime, value in found.get('Added Associations', {}).items():
            added.setdefault(mime, []).extend(entries(value))
    return defaults, added, removed, registered


def read():
    known = installed()
    defaults, added, removed, registered = associations()
    parents = subclasses()
    roles = []
    for key, title, mime in ROLES:
        candidates = []
        for kind in family(mime, parents):
            gone = removed.get(kind, [])
            for entry in defaults.get(kind, []) + added.get(kind, []) + registered.get(kind, []):
                if entry in known and entry not in gone and entry not in candidates:
                    candidates.append(entry)
        if not candidates:
            continue
        default = next((entry for entry in defaults.get(mime, []) if entry in known), candidates[0])
        if default not in candidates:
            candidates.insert(0, default)
        roles.append({
            'key': key,
            'title': title,
            'mime': mime,
            'default': default,
            'candidates': [{'entry': entry, 'name': entry_name(entry, known[entry])} for entry in candidates],
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
