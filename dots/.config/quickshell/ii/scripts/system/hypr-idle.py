#!/usr/bin/env python3
"""Read and set the idle timeouts in a hypridle configuration.

Usage: hypr-idle.py --read <file>
       hypr-idle.py <file> <what>=<seconds> [<what>=<seconds> ...]

What is one of lock, screen or suspend, named after what the listener does when
it fires rather than after its place in the file. Zero seconds means never, and
takes the listener out; a listener that is not there yet is written from the
commands this desktop uses for that job.

Everything else in the file, the commands a person put on their listeners
included, is left alone.
"""

import json
import re
import sys

LOCK = 'lock'
SCREEN = 'screen'
SUSPEND = 'suspend'

SCREEN_OFF = 'hyprctl dispatch \'hl.dsp.dpms({ action = "disable" })\''
SCREEN_ON = 'hyprctl dispatch \'hl.dsp.dpms({ action = "enable" })\''

LISTENER = re.compile(r'\n*listener\s*\{.*?\n\}', re.DOTALL)


def what_of(block):
    fired = ' '.join(re.findall(r'on-timeout\s*=\s*(.*)', block)).lower()
    if 'dpms' in fired:
        return SCREEN
    if 'lock' in fired:
        return LOCK
    if 'suspend' in fired:
        return SUSPEND
    return None


def timeout_of(block):
    found = re.search(r'timeout\s*=\s*(\d+)', block)
    return int(found.group(1)) if found else None


def listeners(text):
    found = {}
    for match in LISTENER.finditer(text):
        what = what_of(match.group(0))
        if what and what not in found:
            found[what] = match
    return found


def block_for(what, seconds, text):
    if what == SCREEN:
        return 'listener {\n    timeout = %d\n    on-timeout = %s\n    on-resume = %s\n}' % (seconds, SCREEN_OFF, SCREEN_ON)
    if what == LOCK:
        command = '$lock_cmd' if '$lock_cmd' in text else 'loginctl lock-session'
        return 'listener {\n    timeout = %d\n    on-timeout = %s\n}' % (seconds, command)
    command = '$suspend_cmd' if '$suspend_cmd' in text else 'systemctl suspend || loginctl suspend'
    return 'listener {\n    timeout = %d\n    on-timeout = %s\n}' % (seconds, command)


def read(path):
    with open(path) as handle:
        text = handle.read()
    print(json.dumps({what: timeout_of(match.group(0)) for what, match in listeners(text).items()}))


def set_timeout(text, what, seconds):
    match = listeners(text).get(what)
    if match is None:
        if seconds <= 0:
            return text
        return text.rstrip('\n') + '\n\n' + block_for(what, seconds, text) + '\n'

    block = match.group(0)
    if seconds <= 0:
        return text[:match.start()] + text[match.end():]
    changed = re.sub(r'(timeout\s*=\s*)\d+[^\n]*', lambda m: m.group(1) + str(seconds), block, count=1)
    return text[:match.start()] + changed + text[match.end():]


def main():
    args = sys.argv[1:]
    if len(args) == 2 and args[0] == '--read':
        read(args[1])
        return 0

    if len(args) < 2:
        print(__doc__, file=sys.stderr)
        return 2

    path = args[0]
    with open(path) as handle:
        text = handle.read()

    for pair in args[1:]:
        what, _, seconds = pair.partition('=')
        text = set_timeout(text, what, int(seconds))

    with open(path, 'w') as handle:
        handle.write(text)
    return 0


if __name__ == '__main__':
    sys.exit(main())
