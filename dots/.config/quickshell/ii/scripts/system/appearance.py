#!/usr/bin/env python3
"""Read and set the appearance settings every toolkit keeps its own copy of.

Usage: appearance.py --read
       appearance.py --families
       appearance.py cursor <theme> <size>
       appearance.py icons <theme>
       appearance.py font <role|all> [--family <name>] [--style <name>] [--size <n>]
       appearance.py theme --gtk <name> --qt <style>

A cursor lives in five places at once and an application picks whichever one its
toolkit knows about, which is why setting it in a single place leaves half the
session behind. The same holds for the interface font, which Qt reads from
kdeglobals and GTK from gsettings. Every writer here edits one key and leaves the
rest of the file as it is.

The Hyprland side goes to settings.lua, which Hyprland sources after its own
configuration and before the files in custom/, so the user keeps the last word.
"""

import json
import os
import re
import subprocess
import sys

HOME = os.path.expanduser('~')
GTK_SETTINGS = [os.path.join(HOME, '.config', d, 'settings.ini') for d in ('gtk-3.0', 'gtk-4.0')]
KDEGLOBALS = os.path.join(HOME, '.config', 'kdeglobals')
HYPR_SETTINGS = os.path.join(HOME, '.config', 'hypr', 'settings.lua')
ICON_DEFAULT = os.path.join(HOME, '.icons', 'default', 'index.theme')


def gsettings(key, value=None, schema='org.gnome.desktop.interface'):
    if value is None:
        out = run(['gsettings', 'get', schema, key])
        return out.strip().strip("'") if out else ''
    run(['gsettings', 'set', schema, key, value])
    return value


def run(command):
    try:
        return subprocess.run(command, capture_output=True, text=True, check=False).stdout
    except FileNotFoundError:
        return ''


def section_span(text, section):
    """The body of a [Section], which is where a key of that section may be read or
    written. kdeglobals carries the same key name under several sections."""
    head = re.search(r'^%s[ \t]*$' % re.escape(section), text, re.M)
    if not head:
        return None
    start = head.end()
    nxt = re.search(r'^\[[^\]]+\][ \t]*$', text[start:], re.M)
    return start, start + nxt.start() if nxt else len(text)


def read_ini_key(path, key, section='[Settings]'):
    try:
        with open(path) as handle:
            text = handle.read()
    except FileNotFoundError:
        return ''

    span = section_span(text, section)
    if span is None:
        return ''
    match = re.search(r'^%s[ \t]*=[ \t]*(.*)$' % re.escape(key), text[span[0]:span[1]], re.M)
    return match.group(1).strip() if match else ''


def set_ini_key(path, key, value, section='[Settings]'):
    try:
        with open(path) as handle:
            text = handle.read()
    except FileNotFoundError:
        text = section + '\n'

    span = section_span(text, section)
    if span is None:
        text = text.rstrip('\n') + '\n\n%s\n%s=%s\n' % (section, key, value)
    else:
        body = text[span[0]:span[1]]
        pattern = re.compile(r'^(%s[ \t]*=[ \t]*).*$' % re.escape(key), re.M)
        if pattern.search(body):
            body = pattern.sub(lambda m: m.group(1) + value, body, count=1)
        else:
            body = body.rstrip('\n') + '\n%s=%s\n' % (key, value)
            if span[1] < len(text):
                body += '\n'
        text = text[:span[0]] + body + text[span[1]:]

    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as handle:
        handle.write(text)


HYPR_HEADER = ('-- Written by the settings app. Hyprland sources it after its own configuration and\n'
               '-- before the files in custom/, so anything set here can still be overridden there.\n')


def read_hypr_settings():
    try:
        with open(HYPR_SETTINGS) as handle:
            return handle.read()
    except FileNotFoundError:
        return HYPR_HEADER


def write_hypr_settings(text):
    os.makedirs(os.path.dirname(HYPR_SETTINGS), exist_ok=True)
    with open(HYPR_SETTINGS, 'w') as handle:
        handle.write(text)


def set_lua_env(name, value):
    """A line reading hl.env("NAME", "value")."""
    text = read_hypr_settings()
    pattern = re.compile(r'(hl\.env\(\s*"%s"\s*,\s*")[^"]*(")' % re.escape(name))
    if pattern.search(text):
        text = pattern.sub(lambda m: m.group(1) + value + m.group(2), text, count=1)
    else:
        text = text.rstrip('\n') + '\nhl.env("%s", "%s")\n' % (name, value)
    write_hypr_settings(text)


def set_lua_start_exec(prefix, command):
    """A command run once Hyprland is up, replaced by the tool it starts with."""
    text = read_hypr_settings()
    pattern = re.compile(r'hl\.exec_cmd\("%s[^"]*"\)' % re.escape(prefix))
    line = 'hl.exec_cmd("%s")' % command
    if pattern.search(text):
        text = pattern.sub(line, text, count=1)
    else:
        text = text.rstrip('\n') + '\nhl.on("hyprland.start", function()\n\t%s\nend)\n' % line
    write_hypr_settings(text)


def themes(kind):
    """Cursor themes carry a cursors/ directory, icon themes carry directories of icons
    beside an index.theme, and GTK themes carry a gtk-N.0/ one."""
    roots = [os.path.join(HOME, '.icons'), os.path.join(HOME, '.local/share/icons'), '/usr/share/icons']
    if kind == 'gtk':
        roots = [os.path.join(HOME, '.themes'), os.path.join(HOME, '.local/share/themes'), '/usr/share/themes']

    def keeps(path, entries):
        if kind == 'cursor':
            return os.path.isdir(os.path.join(path, 'cursors'))
        if kind == 'icon':
            # A cursor theme carries an index.theme too, and only an icon theme lists the
            # directories its icons are filed under.
            return bool(read_ini_key(os.path.join(path, 'index.theme'), 'Directories', '[Icon Theme]'))
        return any(entry.startswith('gtk-') for entry in entries)

    found = set()
    for root in roots:
        if not os.path.isdir(root):
            continue
        for name in os.listdir(root):
            path = os.path.join(root, name)
            # hicolor is the fallback every theme inherits, never a choice of its own.
            if not os.path.isdir(path) or name == 'hicolor':
                continue
            if keeps(path, os.listdir(path)):
                found.add(name)
    return sorted(found)


def qt_styles():
    found = set()
    for root in ('/usr/lib/qt6/plugins/styles', '/usr/lib/qt/plugins/styles'):
        if os.path.isdir(root):
            for name in os.listdir(root):
                found.add(re.sub(r'\d*\.so$', '', name).capitalize())
    return sorted(found | {'Fusion', 'Windows'})


# The roles KDE's font page exposes, and the kdeglobals key each one lives under.
ROLES = {
    'general': ('[General]', 'font'),
    'fixed': ('[General]', 'fixed'),
    'small': ('[General]', 'smallestReadableFont'),
    'toolbar': ('[General]', 'toolBarFont'),
    'menu': ('[General]', 'menuFont'),
    'title': ('[WM]', 'activeFont'),
}

# A monospaced face is picked for legibility rather than to match the interface, so the
# blanket change leaves it where it is, the way KDE's own Adjust All Fonts does.
ADJUSTABLE = [role for role in ROLES if role != 'fixed']

WEIGHTS = {
    'Thin': 100, 'Hairline': 100,
    'ExtraLight': 200, 'UltraLight': 200, 'Ultralight': 200,
    'Light': 300,
    'Regular': 400, 'Normal': 400, 'Book': 400, '': 400,
    'Medium': 500,
    'DemiBold': 600, 'SemiBold': 600, 'Semibold': 600, 'Demibold': 600,
    'Bold': 700,
    'ExtraBold': 800, 'UltraBold': 800, 'Ultrabold': 800,
    'Black': 900, 'Heavy': 900,
}

SIZES = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18, 20, 22, 24, 26, 28, 32, 36, 40, 48, 56, 64, 72]


def families():
    """Every installed family with the styles it ships, as fontconfig reports them."""
    catalogue = {}
    for line in run(['fc-list', ':', 'family', 'style']).splitlines():
        family, _, style = line.partition(':style=')
        # A family can be listed under several aliases separated by commas.
        name = family.split(',')[0].strip()
        if not name:
            continue
        styles = catalogue.setdefault(name, set())
        for one in style.split(','):
            if one.strip():
                styles.add(one.strip())
    return {name: sorted(styles, key=style_order) for name, styles in sorted(catalogue.items())}


def style_order(style):
    base, italic = style_parts(style)
    return (italic, WEIGHTS.get(base, 400), style)


def style_parts(style):
    words = [w for w in style.split() if w]
    italic = any(w in ('Italic', 'Oblique') for w in words)
    base = ' '.join(w for w in words if w not in ('Italic', 'Oblique'))
    return base, italic


def spec(family, style, size):
    base, italic = style_parts(style)
    weight = WEIGHTS.get(base.replace(' ', ''), WEIGHTS.get(base, 400))
    return '%s,%s,-1,5,%d,%d,0,0,0,0,0,0,0,0,0,1,%s,0,0' % (family, size, weight, 1 if italic else 0, style or 'Regular')


def weight_name(weight):
    for name, value in (('Thin', 100), ('ExtraLight', 200), ('Light', 300), ('Regular', 400),
                        ('Medium', 500), ('SemiBold', 600), ('Bold', 700), ('ExtraBold', 800), ('Black', 900)):
        if value == weight:
            return name
    return 'Regular'


def split_family(family, installed):
    """Older specs bake the style into the family name, the way "SF Pro Text Medium"
    does. Fontconfig knows no such family, so the trailing words come back off."""
    if family in installed:
        return family, ''
    words = family.split()
    for cut in range(1, min(3, len(words)) + 1):
        head = ' '.join(words[:-cut])
        tail = ' '.join(words[-cut:])
        if head in installed and tail in installed[head]:
            return head, tail
    return family, ''


def read_font(role, installed):
    section, key = ROLES[role]
    parts = [p.strip() for p in read_ini_key(KDEGLOBALS, key, section).split(',')]
    if parts and parts[0]:
        size = int(parts[1]) if len(parts) > 1 and parts[1].isdigit() else 10
        style = ''
        if len(parts) > 16 and parts[16] and not parts[16].isdigit():
            style = parts[16]
        elif len(parts) > 5:
            style = weight_name(int(parts[4]) if parts[4].isdigit() else 400)
            if parts[5] == '1':
                style = (style + ' Italic').strip()
        family, baked = split_family(parts[0], installed)
        return {'family': family, 'style': baked or style, 'size': size}

    font = gsettings('font-name')
    family, _, size = font.rpartition(' ')
    family, baked = split_family(family or font, installed)
    return {'family': family, 'style': baked, 'size': int(size) if size.isdigit() else 11}


def read():
    installed = families()
    print(json.dumps({
        'cursorTheme': gsettings('cursor-theme'),
        'cursorSize': int(gsettings('cursor-size') or 24),
        'fonts': {role: read_font(role, installed) for role in ROLES},
        'iconTheme': read_ini_key(KDEGLOBALS, 'Theme', '[Icons]') or gsettings('icon-theme'),
        'gtkTheme': gsettings('gtk-theme'),
        'qtStyle': read_ini_key(KDEGLOBALS, 'widgetStyle', '[KDE]'),
        'cursorThemes': themes('cursor'),
        'iconThemes': themes('icon'),
        'gtkThemes': themes('gtk'),
        'qtStyles': qt_styles(),
        'sizes': SIZES,
    }))


def set_cursor(theme, size):
    gsettings('cursor-theme', theme)
    gsettings('cursor-size', size)
    for path in GTK_SETTINGS:
        set_ini_key(path, 'gtk-cursor-theme-name', theme)
        set_ini_key(path, 'gtk-cursor-theme-size', size)
    set_lua_env('XCURSOR_THEME', theme)
    set_lua_env('XCURSOR_SIZE', size)
    set_lua_env('HYPRCURSOR_SIZE', size)
    set_lua_start_exec('hyprctl setcursor', 'hyprctl setcursor %s %s' % (theme, size))
    set_ini_key(ICON_DEFAULT, 'Inherits', theme, '[Icon Theme]')
    run(['hyprctl', 'setcursor', theme, size])


def set_icons(theme):
    gsettings('icon-theme', theme)
    for path in GTK_SETTINGS:
        set_ini_key(path, 'gtk-icon-theme-name', theme)
    set_ini_key(KDEGLOBALS, 'Theme', theme, '[Icons]')
    # Qt reads its icons through the platform theme and Quickshell through its own
    # variable, and neither picks up kdeglobals without being told which theme to use.
    set_lua_env('QT_ICON_THEME', theme)
    set_lua_env('QS_ICON_THEME', theme)


def variations(pango):
    """The ` @axis=value,...` tail a variable font carries in a Pango description."""
    marker = pango.rfind('@')
    return ' ' + pango[marker:] if marker > 0 else ''


def set_font(role, family=None, style=None, size=None, installed=None):
    current = read_font(role, families() if installed is None else installed)
    same_family = family is None or family == current['family']
    family = current['family'] if family is None else family
    style = current['style'] if style is None else style
    size = current['size'] if size is None else size

    section, key = ROLES[role]
    set_ini_key(KDEGLOBALS, key, spec(family, style, size), section)

    pango = ' '.join(part for part in (family, style if style not in ('', 'Regular') else '', str(size)) if part)

    # The roles GTK has an equivalent for; the rest are Qt's alone.
    if role == 'general':
        axes = variations(gsettings('font-name')) if same_family else ''
        gsettings('font-name', pango + axes)
        for path in GTK_SETTINGS:
            set_ini_key(path, 'gtk-font-name', pango + axes)
    elif role == 'fixed':
        axes = variations(gsettings('monospace-font-name')) if same_family else ''
        gsettings('monospace-font-name', pango + axes)


def set_theme(gtk, qt):
    if gtk:
        gsettings('gtk-theme', gtk)
        for path in GTK_SETTINGS:
            set_ini_key(path, 'gtk-theme-name', gtk)
    if qt:
        set_ini_key(KDEGLOBALS, 'widgetStyle', qt, '[KDE]')


def main():
    args = sys.argv[1:]
    if not args:
        print(__doc__, file=sys.stderr)
        return 2
    if args[0] == '--read':
        read()
    elif args[0] == '--families':
        print(json.dumps(families()))
    elif args[0] == 'cursor' and len(args) == 3:
        set_cursor(args[1], args[2])
    elif args[0] == 'icons' and len(args) == 2:
        set_icons(args[1])
    elif args[0] == 'font' and len(args) > 1 and (args[1] in ROLES or args[1] == 'all'):
        parts = {name: args[args.index('--' + name) + 1] for name in ('family', 'style', 'size') if '--' + name in args}
        if not parts:
            return 2
        installed = families()
        for role in (ADJUSTABLE if args[1] == 'all' else [args[1]]):
            set_font(role, installed=installed, **parts)
    elif args[0] == 'theme':
        gtk = args[args.index('--gtk') + 1] if '--gtk' in args else None
        qt = args[args.index('--qt') + 1] if '--qt' in args else None
        set_theme(gtk, qt)
    else:
        print(__doc__, file=sys.stderr)
        return 2
    return 0


if __name__ == '__main__':
    sys.exit(main())
