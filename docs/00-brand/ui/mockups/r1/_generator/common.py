"""Shared pieces of the Release 1 mockups: tokens, icons, sidebar, top bar (same values as the approved boards)."""

ICONS = {
    'calcheck': '<rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4M8 2v4M3 10h18M9 16l2 2 4-4"/>',
    'calendar': '<rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4M8 2v4M3 10h18"/>',
    'calplus': '<rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4M8 2v4M3 10h18M12 14v4M10 16h4"/>',
    'users': '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/>',
    'folder': '<path d="M4 20h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.93a2 2 0 0 1-1.66-.9l-.82-1.2A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13c0 1.1.9 2 2 2Z"/>',
    'clipboard': '<rect x="8" y="2" width="8" height="4" rx="1"/><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/>',
    'megaphone': '<path d="m3 11 18-5v12L3 14v-3z"/><path d="M11.6 16.8a3 3 0 1 1-5.8-1.6"/>',
    'sliders': '<path d="M4 21v-7M4 10V3M12 21v-9M12 8V3M20 21v-5M20 12V3M1 14h6M9 8h6M17 16h6"/>',
    'search': '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>',
    'plus': '<path d="M5 12h14M12 5v14"/>',
    'chevdown': '<path d="m6 9 6 6 6-6"/>',
    'chevleft': '<path d="m15 18-6-6 6-6"/>',
    'chevright': '<path d="m9 18 6-6-6-6"/>',
    'arrowleft': '<path d="M19 12H5M12 19l-7-7 7-7"/>',
    'video': '<path d="m22 8-6 4 6 4V8Z"/><rect x="2" y="6" width="14" height="12" rx="2"/>',
    'pin': '<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/>',
    'clock': '<circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/>',
    'lock': '<rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>',
    'pencil': '<path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/>',
    'archive': '<rect x="2" y="3" width="20" height="5" rx="1"/><path d="M4 8v11a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8M10 12h4"/>',
    'copy': '<rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>',
    'message': '<path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/>',
    'key': '<circle cx="7.5" cy="15.5" r="5.5"/><path d="m21 2-9.6 9.6M15.5 7.5l3 3L22 7l-3-3"/>',
    'phone': '<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92Z"/>',
    'x': '<path d="M18 6 6 18M6 6l12 12"/>',
    'info': '<circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/>',
    'check': '<path d="M20 6 9 17l-5-5"/>',
    'circlecheck': '<circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/>',
    'repeat': '<path d="m17 2 4 4-4 4"/><path d="M3 11v-1a4 4 0 0 1 4-4h14M7 22l-4-4 4-4"/><path d="M21 13v1a4 4 0 0 1-4 4H3"/>',
    'play': '<polygon points="6 3 20 12 6 21 6 3" fill="currentColor"/>',
    'filter': '<path d="M22 3H2l8 9.46V19l4 2v-8.54L22 3z"/>',
    'upload': '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M17 8l-5-5-5 5M12 3v12"/>',
    'user': '<circle cx="12" cy="8" r="4"/><path d="M20 21a8 8 0 0 0-16 0"/>',
    'ban': '<circle cx="12" cy="12" r="10"/><path d="m4.9 4.9 14.2 14.2"/>',
    'house': '<path d="M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"/><path d="M3 10a2 2 0 0 1 .709-1.528l7-6a2 2 0 0 1 2.582 0l7 6A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>',
    'book': '<path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2zM22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>',
    'chart': '<path d="M3 3v18h18M18 17V9M13 17V5M8 17v-3"/>',
    'dashboard': '<rect x="3" y="3" width="7" height="9" rx="1"/><rect x="14" y="3" width="7" height="5" rx="1"/><rect x="14" y="12" width="7" height="9" rx="1"/><rect x="3" y="16" width="7" height="5" rx="1"/>',
    'bell': '<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/>',
    'more': '<circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/>',
    'link': '<path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>',
    'palette': '<circle cx="13.5" cy="6.5" r="1.5"/><circle cx="17.5" cy="10.5" r="1.5"/><circle cx="8.5" cy="7.5" r="1.5"/><circle cx="6.5" cy="12.5" r="1.5"/><path d="M12 2a10 10 0 0 0 0 20c.9 0 1.6-.7 1.6-1.6 0-.4-.2-.8-.4-1.1-.3-.3-.4-.7-.4-1.1 0-.9.7-1.6 1.6-1.6H16a6 6 0 0 0 6-6c0-4.9-4.5-8.6-10-8.6Z"/>',
}


def icon(name, size=20, stroke=2, color='currentColor', style=''):
    return (f'<svg width="{size}" height="{size}" viewBox="0 0 24 24" fill="none" stroke="{color}" '
            f'stroke-width="{stroke}" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0;{style}">'
            f'{ICONS[name]}</svg>')


CSS = """
*{box-sizing:border-box}
body{margin:0;font-family:'Plus Jakarta Sans',sans-serif;color:#1A1D3A;background:#F6F7FB}
[dir=rtl] body, body[dir=rtl]{font-family:'IBM Plex Sans Arabic',sans-serif}
a{color:#2B3990;text-decoration:none}
.app{display:flex;min-height:900px;align-items:stretch}
.side{width:264px;flex-shrink:0;background:#fff;border-inline-end:1px solid #E6E8F0;padding:24px 16px;display:flex;flex-direction:column;gap:28px}
.brand{display:flex;align-items:center;gap:10px;padding:0 8px}
.brand img{height:34px}
.brand div{font-size:17px;letter-spacing:-.3px;line-height:1.1;direction:ltr}
.nav{display:flex;flex-direction:column;gap:4px}
.nav a{display:flex;align-items:center;gap:12px;height:44px;padding:0 12px;border-radius:12px;color:#4A4F72;font-size:14px;font-weight:600}
.nav a.on{background:#EEF0FA;color:#2B3990;font-weight:700}
.over{padding:0 12px 6px;font-size:11px;font-weight:700;letter-spacing:1.2px;text-transform:uppercase;color:#6B7090}
.grp{display:flex;align-items:center;gap:12px;height:40px;padding:0 12px;border-radius:12px;color:#1A1D3A;font-size:14px;font-weight:600}
.sq{width:24px;height:24px;border-radius:7px;color:#fff;font-size:11px;font-weight:800;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.ucard{margin-top:auto;display:flex;align-items:center;gap:12px;padding:12px;border:1px solid #E6E8F0;border-radius:16px}
.av{border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:800;flex-shrink:0;direction:ltr}
.main{flex:1;min-width:0;display:flex;flex-direction:column}
.top{height:72px;flex-shrink:0;display:flex;align-items:center;gap:12px;padding:0 32px;background:#fff;border-bottom:1px solid #E6E8F0}
.search{flex:0 1 420px;display:flex;align-items:center;gap:10px;height:44px;padding:0 14px;background:#F6F7FB;border:1px solid #E6E8F0;border-radius:12px;color:#6B7090;font-size:14px}
.btn{height:44px;padding:0 18px;border:none;border-radius:12px;font-family:inherit;font-size:14px;font-weight:700;display:inline-flex;align-items:center;gap:8px;white-space:nowrap;cursor:pointer}
.primary{background:#2B3990;color:#fff}
.secondary{background:#fff;color:#1A1D3A;border:1px solid #E6E8F0}
.tonal{background:#EEF0FA;color:#2B3990;font-weight:800}
.ghost{background:transparent;color:#4A4F72}
.danger{background:#fff;color:#B42525;border:1px solid #F6C9C9}
.sm{height:38px;padding:0 14px;font-size:13px}
.page{width:100%;max-width:1240px;padding:32px;display:flex;flex-direction:column;gap:24px}
.ptitle{margin:0;font-size:38px;font-weight:800;letter-spacing:-1px}
.card{background:#fff;border:1px solid #E6E8F0;border-radius:24px;padding:24px}
.ch{display:flex;align-items:center;gap:10px;margin-bottom:16px}
.ch h2{margin:0;flex:1;font-size:18px;font-weight:800}
.count{padding:3px 9px;border-radius:999px;font-size:12px;font-weight:800}
.chip{display:inline-flex;align-items:center;gap:6px;padding:5px 10px;border-radius:999px;font-size:12px;font-weight:700;white-space:nowrap}
.dot{width:6px;height:6px;border-radius:3px}
.badge{display:flex;align-items:center;justify-content:center;flex-shrink:0}
.row{display:flex;align-items:center;gap:14px;padding:12px 0;border-top:1px solid #F0F1F6}
.t15{font-size:15px;font-weight:700}
.s13{font-size:13px;color:#6B7090}
.cap{font-size:12px;font-weight:700;color:#6B7090}
.tabs{display:inline-flex;padding:4px;background:#fff;border:1px solid #E6E8F0;border-radius:14px;gap:2px}
.tabs span{height:36px;padding:0 16px;border-radius:10px;display:flex;align-items:center;gap:8px;font-size:14px;font-weight:600;color:#6B7090}
.tabs span.on{background:#EEF0FA;color:#2B3990;font-weight:700}
.field{display:flex;flex-direction:column;gap:8px}
.field label{font-size:14px;font-weight:600}
.input{display:flex;align-items:center;gap:10px;min-height:48px;padding:0 14px;background:#F6F7FB;border:1px solid #E6E8F0;border-radius:14px;color:#1A1D3A;font-size:15px}
.input.focus{border:1.5px solid #2B3990}
.hint{font-size:12px;color:#6B7090}
.note{display:flex;gap:10px;align-items:flex-start;padding:12px 14px;border-radius:14px;background:#F6F7FB;font-size:13px;line-height:1.5;color:#4A4F72}
.scrim{position:absolute;inset:0;background:rgba(26,29,58,.28)}
.panel{position:absolute;top:0;bottom:0;inset-inline-end:0;width:520px;background:#fff;box-shadow:0 0 40px rgba(28,37,102,.18);display:flex;flex-direction:column}
.panel-h{display:flex;align-items:center;gap:12px;padding:22px 24px;border-bottom:1px solid #E6E8F0}
.panel-b{flex:1;overflow:hidden;padding:24px;display:flex;flex-direction:column;gap:20px}
.panel-f{display:flex;gap:10px;justify-content:flex-end;padding:18px 24px;border-top:1px solid #E6E8F0}
.seg{display:flex;padding:4px;background:#F6F7FB;border:1px solid #E6E8F0;border-radius:14px;gap:4px}
.seg span{flex:1;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center;gap:8px;font-size:14px;font-weight:600;color:#6B7090}
.seg span.on{background:#fff;color:#2B3990;font-weight:700;box-shadow:0 1px 3px rgba(26,29,58,.12)}
.ann{position:absolute;padding:6px 10px;border-radius:8px;background:#1A1D3A;color:#fff;font-size:12px;font-weight:700}
"""

ACCENTS = {
    'indigo': ('#2B3990', '#EEF0FA', '#2B3990'), 'turquoise': ('#12A39A', '#E3F6F4', '#0B6E68'),
    'amber': ('#FFB020', '#FFF4DC', '#9A6300'), 'violet': ('#7048E8', '#F1ECFD', '#5B34D6'),
    'blue': ('#3B5BDB', '#EAF0FF', '#2F4AC0'), 'red': ('#E03131', '#FDECEC', '#B42525'),
    'orange': ('#E8590C', '#FDEEE4', '#B5440A'), 'green': ('#2F9E44', '#E7F6EA', '#237A35'),
    'grey': ('#868E96', '#F1F3F5', '#868E96'),
}


def chip(label, accent, solid=False, dot=True):
    strong, soft, on = ACCENTS[accent]
    if solid:
        return f'<span class="chip" style="background:{strong};color:#fff">{label}</span>'
    d = f'<span class="dot" style="background:{strong}"></span>' if dot else ''
    return f'<span class="chip" style="background:{soft};color:{on}">{d}{label}</span>'


def badge(name, accent, size=40, radius=12, isize=20):
    strong, soft, on = ACCENTS[accent]
    return (f'<span class="badge" style="width:{size}px;height:{size}px;border-radius:{radius}px;background:{soft};color:{on}">'
            f'{icon(name, isize)}</span>')


def avatar(initials, accent='indigo', size=40, solid=False):
    strong, soft, on = ACCENTS[accent]
    bg, fg = (strong, '#fff') if solid else (soft, on)
    fs = 14 if size >= 40 else 13
    return f'<span class="av" style="width:{size}px;height:{size}px;background:{bg};color:{fg};font-size:{fs}px">{initials}</span>'


GROUPS = [('7A', '7ème A · Math', '#2B3990', '#fff', 8), ('9B', '9ème B · Math', '#12A39A', '#fff', 6),
          ('BM', 'Bac Math', '#FFB020', '#1A1D3A', 5), ('CP', 'Cours particuliers', '#7048E8', '#fff', 3)]

NAV = [('calcheck', 'Ma journée'), ('calendar', 'Planning'), ('users', 'Élèves'), ('folder', 'Contenus'),
       ('clipboard', 'Devoirs'), ('megaphone', 'Annonces'), ('sliders', 'Paramètres')]


def sidebar(active):
    items = ''.join(
        f'<a class="{"on" if label == active else ""}">{icon(i)}{label}</a>' for i, label in NAV)
    groups = ''.join(
        f'<a class="grp"><span class="sq" style="background:{bg};color:{fg}">{code}</span><span style="flex:1">{name}</span>'
        f'<span class="cap" style="font-weight:500">{n}</span></a>' for code, name, bg, fg, n in GROUPS)
    return f'''<nav class="side">
  <div class="brand"><img src="ng-symbol.png" alt=""><div><span style="font-weight:800;color:#2B3990">NextGeneration</span><br><span style="font-weight:500;color:#12A39A">Class</span></div></div>
  <div class="nav">{items}</div>
  <div class="nav"><div class="over">Mes groupes</div>{groups}</div>
  <div class="ucard">{avatar('IH', 'indigo', 40, True)}<div style="flex:1"><div style="font-size:14px;font-weight:700">Ines Haddad</div><div class="cap" style="font-weight:500">Enseignante</div></div>{icon('chevdown', 18, color='#6B7090')}</div>
</nav>'''


def topbar(search='Rechercher un élève, un contenu…'):
    return f'''<div class="top">
  <div class="search">{icon('search', 18)}{search}</div>
  <div style="flex:1"></div>
  <span class="btn secondary" style="height:40px;padding:0 14px;font-size:13px;color:#4A4F72">FR · ع</span>
  <span class="btn secondary" style="width:44px;padding:0;justify-content:center;position:relative;color:#4A4F72">{icon('bell')}<span style="position:absolute;top:9px;inset-inline-end:10px;width:9px;height:9px;border-radius:5px;background:#FFB020;border:2px solid #fff"></span></span>
  <span class="btn primary">{icon('plus', 18, 2.4)}Créer</span>
</div>'''


def page(title, body, width=1440, height=900, lang='fr'):
    d = ' dir="rtl"' if lang == 'ar' else ''
    return f'''<!doctype html>
<html lang="{lang}"{d}>
<head><meta charset="utf-8"><title>{title}</title>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>{CSS}</style></head>
<body{d} style="width:{width}px;min-height:{height}px;position:relative">
{body}
</body></html>
'''


def teacher(title, active, content, overlay='', height=900):
    return page(title, f'''<div class="app" style="min-height:{height}px">{sidebar(active)}<div class="main">{topbar()}{content}</div></div>{overlay}''', height=height)
