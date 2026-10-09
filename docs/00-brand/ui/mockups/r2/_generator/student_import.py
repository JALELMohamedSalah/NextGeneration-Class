"""Release 2: import pupils from Excel or CSV (spec 02 "CSV import"): file, check every row, login details."""
from pathlib import Path

from contents import square  # also puts the R1 generator on the path

import common  # noqa: E402
from common import ACCENTS, avatar, badge, chip, icon, page, sidebar  # noqa: E402
from scan import frame  # noqa: E402
from teacher_notifications import bell  # noqa: E402

OUT = Path(__file__).resolve().parents[1]

common.ICONS.update({
    'filesheet': '<path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4M8 13h8M8 17h8M12 11v8"/>',
    'download': '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/>',
    'printer': '<path d="M6 9V2h12v7M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/>',
    'copy': '<rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>',
    'checksquare': '<rect x="3" y="3" width="18" height="18" rx="4"/><path d="m8 12 3 3 5-6"/>',
    'alert': '<circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/>',
    'link2': '<path d="M9 17H7A5 5 0 0 1 7 7h2M15 7h2a5 5 0 1 1 0 10h-2M8 12h8"/>',
    'arrowright': '<path d="M5 12h14M12 5l7 7-7 7"/>',
    'checkcircle': '<path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><path d="m9 11 3 3L22 4"/>',
})


def topbar():
    return f'''<div class="top">
  <div style="flex:1"></div>
  <span class="btn secondary" style="height:40px;padding:0 14px;font-size:13px;color:#4A4F72">FR · ع</span>
  {bell(44, 0)}
  <span class="btn primary">{icon('plus', 18, 2.4)}Créer</span>
</div>'''


def screen(title, content, height=900):
    body = f'''<div class="app" style="min-height:{height}px">{sidebar('Élèves')}<div class="main">{topbar()}{content}</div></div>'''
    return page(title, body, height=height)


def steps(active):
    labels = ['Fichier', 'Vérifier', 'Identifiants']
    out = ''
    for i, label in enumerate(labels, 1):
        done, on = i < active, i == active
        dot_bg = '#2B3990' if (done or on) else '#fff'
        dot_fg = '#fff' if (done or on) else '#6B7090'
        dot = icon('check', 14, 3) if done else str(i)
        border = '' if (done or on) else 'border:1.5px solid #CDD0DE;'
        out += (f'<div style="display:flex;align-items:center;gap:10px"><span style="width:28px;height:28px;border-radius:14px;background:{dot_bg};color:{dot_fg};{border}'
                f'display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:800">{dot}</span>'
                f'<span style="font-size:14px;font-weight:{800 if on else 600};color:{"#1A1D3A" if on else "#6B7090"}">{label}</span></div>')
        if i < len(labels):
            out += f'<span style="flex:0 0 48px;height:2px;background:{"#2B3990" if done else "#E6E8F0"}"></span>'
    return f'<div style="display:flex;align-items:center;gap:12px">{out}</div>'


def head(sub):
    return f'''<div style="display:flex;align-items:center;gap:8px" class="s13"><span style="color:#2B3990;font-weight:700;display:flex;align-items:center;gap:6px">{icon('arrowleft', 16)}Élèves</span></div>
  <div style="display:flex;align-items:flex-end;gap:16px;flex-wrap:wrap">
    <div style="flex:1;min-width:300px"><h1 class="ptitle">Importer des élèves</h1><div style="font-size:15px;color:#4A4F72;margin-top:6px">{sub}</div></div>
  </div>'''


# ── 1. The file ──

COLUMNS = [('Prénom', True, 'Yassine'), ('Nom', True, 'Ben Ali'), ('Niveau', False, '4ème année'), ('Groupe', False, '4ème année · Maths'),
           ('Prénom du parent', False, 'Sonia'), ('Nom du parent', False, 'Ben Ali'), ('Téléphone du parent', False, '22345678')]


def columns_card():
    heads = ''.join(f'<th style="text-align:start;padding:10px 12px;font-size:12px;font-weight:700;color:#4A4F72;border-bottom:1px solid #E6E8F0;white-space:nowrap">{c}{" *" if req else ""}</th>' for c, req, _ in COLUMNS)
    cells = ''.join(f'<td style="padding:10px 12px;font-size:13px;color:#1A1D3A;white-space:nowrap">{ex}</td>' for _, _, ex in COLUMNS)
    return f'''<section class="card" style="padding:22px">
  <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px"><div style="flex:1"><div style="font-size:17px;font-weight:800">Les colonnes attendues</div>
    <div class="s13" style="margin-top:2px">Une ligne par élève. Les noms de colonnes peuvent être en français ou en arabe. * obligatoire.</div></div>
    <span class="btn secondary sm">{icon('download', 15)}Télécharger le modèle</span></div>
  <div style="border:1px solid #E6E8F0;border-radius:14px;overflow:hidden"><table style="border-collapse:collapse;width:100%;background:#fff"><tr style="background:#F6F7FB">{heads}</tr><tr>{cells}</tr></table></div>
  <div style="display:flex;flex-direction:column;gap:6px;margin-top:14px">
    <div class="s13" style="display:flex;gap:8px;align-items:center">{icon('check', 15, color='#237A35')}Un parent qui a plusieurs enfants : le même téléphone sur chaque ligne, un seul accès est créé.</div>
    <div class="s13" style="display:flex;gap:8px;align-items:center">{icon('check', 15, color='#237A35')}Sans parent, l'élève est ajouté quand même ; vous ouvrirez un accès plus tard depuis sa fiche.</div>
  </div>
</section>'''


def file_page():
    drop = f'''<div style="border:2px dashed #9AA3D9;background:#F4F5FC;border-radius:20px;padding:34px;display:flex;flex-direction:column;align-items:center;gap:12px;text-align:center">
    {badge('filesheet', 'green', 56, 16, 26)}
    <div style="font-size:18px;font-weight:800">Choisissez votre fichier</div>
    <div class="s13" style="max-width:380px;line-height:1.5">Excel (.xlsx) ou CSV, 300 lignes au plus. Rien n'est créé avant la vérification.</div>
    <span class="btn primary">{icon('folder', 17)}Choisir un fichier</span>
  </div>'''
    options = f'''<section class="card" style="padding:22px;display:flex;flex-direction:column;gap:16px">
    <div style="font-size:17px;font-weight:800">Pour tous les élèves du fichier</div>
    <div class="field"><label>Ajouter au groupe <span class="s13" style="font-weight:500">· facultatif</span></label>
      <div class="input" style="justify-content:space-between"><span style="display:flex;align-items:center;gap:10px">{square('4A', 22)}4ème année · Maths · 3 élèves</span>{icon('chevdown', 18, color='#6B7090')}</div>
      <div class="hint">La colonne « Groupe » du fichier compte aussi.</div></div>
    <div class="field"><label>Niveau quand la colonne est vide</label>
      <div class="input" style="justify-content:space-between"><span>4ème année</span>{icon('chevdown', 18, color='#6B7090')}</div></div>
    <div style="display:flex;gap:12px;align-items:flex-start;padding:14px;border:1px solid #E6E8F0;border-radius:14px">
      <span style="width:42px;height:24px;border-radius:12px;background:#CDD0DE;position:relative;flex-shrink:0"><span style="position:absolute;top:3px;inset-inline-start:3px;width:18px;height:18px;border-radius:9px;background:#fff"></span></span>
      <div><div style="font-size:14px;font-weight:700">Créer aussi l'accès des élèves</div><div class="s13" style="margin-top:2px;line-height:1.45">Sinon, seuls les parents reçoivent un accès (avec leur téléphone). Vous pourrez ouvrir celui d'un élève depuis sa fiche.</div></div>
    </div>
  </section>'''
    content = f'''<main class="page" style="max-width:1176px">
  {head("Une classe entière d'un coup, depuis Excel : les élèves, leurs parents et leurs accès.")}
  {steps(1)}
  <div style="display:flex;gap:24px;align-items:flex-start">
    <div style="flex:7;display:flex;flex-direction:column;gap:24px">{drop}{columns_card()}</div>
    <div style="flex:5">{options}</div>
  </div>
</main>'''
    return screen('Importer des élèves', content, height=1000)


# ── 2. Check every row ──

STATES = {
    'ok': ('Prêt', 'green'),
    'known': ('Parent déjà inscrit', 'blue'),
    'exists': ('Déjà inscrit', 'amber'),
    'error': ('À corriger', 'red'),
}

ROWS = [  # line, initials, accent, pupil, level, group, parent, phone, state, note, checked
    (2, 'YB', 'indigo', 'Yassine Ben Ali', '4ème année', '4A', 'Sonia Ben Ali', '22 345 678', 'ok', None, True),
    (3, 'ET', 'turquoise', 'Eya Trabelsi', '4ème année', '4A', 'Nabil Trabelsi', '98 123 456', 'ok', None, True),
    (4, 'RK', 'violet', 'Rania Kefi', '4ème année', '4A', 'Sonia Kefi', '22 111 222', 'known', 'Sonia Kefi a déjà un accès : Rania rejoint ses enfants.', True),
    (5, 'AK', 'amber', 'Amine Kefi', '4ème année', '4A', 'Sonia Kefi', '22 111 222', 'exists', 'Amine Kefi est déjà dans vos élèves : la ligne est ignorée.', False),
    (6, 'MG', 'blue', 'Mohamed Aziz Gharsalli', '4ème année', '4A', 'Hela Gharsalli', '2234567', 'error', 'Téléphone du parent : 8 chiffres.', False),
    (7, 'FJ', 'orange', 'Firas Jebali', '7ème', '4A', 'Karim Jebali', '55 678 901', 'error', 'Niveau inconnu : « 7ème ». De la 1ère à la 6ème année.', False),
    (8, 'IM', 'green', 'Ines Mabrouk', '4ème année', '4A', None, None, 'ok', None, True),
]


def checkbox(on, disabled=False):
    if disabled:
        return '<span style="display:block;width:22px;height:22px;border:2px solid #E6E8F0;background:#F6F7FB;border-radius:6px;flex-shrink:0"></span>'
    if on:
        return f'<span style="color:#2B3990;display:flex">{icon("checksquare", 22)}</span>'
    return '<span style="display:block;width:22px;height:22px;border:2px solid #CDD0DE;border-radius:6px;flex-shrink:0"></span>'


def preview_page():
    def tile(value, label, accent):
        strong, _, _ = ACCENTS[accent]
        return (f'<div style="flex:1;padding:16px 18px;border-radius:20px;background:#fff;border:1px solid #E6E8F0;display:flex;align-items:center;gap:14px">'
                f'<span style="width:6px;height:40px;border-radius:3px;background:{strong}"></span>'
                f'<div><div style="font-size:28px;font-weight:800;line-height:1">{value}</div><div class="s13" style="margin-top:4px">{label}</div></div></div>')

    rows = ''
    for i, (line, ini, acc, pupil, level, grp, parent, phone, state, note, checked) in enumerate(ROWS):
        label, accent = STATES[state]
        err = state == 'error'
        parent_cell = (f'<div style="font-size:14px;font-weight:600">{parent}</div><div class="s13" style="direction:ltr;text-align:start;{"color:#B42525;font-weight:700" if "Téléphone" in (note or "") else ""}">{phone}</div>'
                       if parent else '<div class="s13">Aucun parent</div>')
        level_style = 'color:#B42525;font-weight:700' if 'Niveau' in (note or '') else ''
        note_html = (f'<div style="font-size:12px;margin-top:4px;color:{ACCENTS[accent][2]};font-weight:600">{note}</div>' if note else '')
        rows += f'''<div class="row" style="padding:12px 0;align-items:flex-start;{"border-top:none" if i == 0 else ""};{"background:#FFFAFA" if err else ""}">
  <div style="width:30px;padding-top:9px">{checkbox(checked, err)}</div>
  <div style="width:36px;padding-top:11px" class="s13">{line}</div>
  {avatar(ini, acc)}
  <div style="flex:1.4;min-width:0"><div class="t15">{pupil}</div><div class="s13" style="{level_style}">{level}</div>{note_html}</div>
  <div style="width:190px;padding-top:9px" class="s13"><span style="display:flex;align-items:center;gap:8px">{square(grp, 20)}<span style="color:#1A1D3A">4ème année · Maths</span></span></div>
  <div style="width:180px">{parent_cell}</div>
  <div style="width:170px;padding-top:7px">{chip(label, accent)}</div>
</div>'''
    content = f'''<main class="page" style="max-width:1176px;padding-bottom:110px">
  {head("classe-4A.xlsx · 7 lignes lues. Vérifiez avant de créer les élèves.")}
  {steps(2)}
  <div style="display:flex;gap:12px">{tile(4, 'Prêts à importer', 'green')}{tile(1, 'Parent déjà inscrit, lié', 'blue')}{tile(1, 'Déjà inscrit, ignoré', 'amber')}{tile(2, 'À corriger dans le fichier', 'red')}</div>
  <section class="card" style="padding:8px 24px">
    <div style="display:flex;gap:14px;padding:14px 0 10px;border-bottom:1px solid #F0F1F6" class="cap">
      <span style="width:30px"></span><span style="width:36px">LIGNE</span><span style="width:40px"></span><span style="flex:1.4">ÉLÈVE</span><span style="width:190px">GROUPE</span><span style="width:180px">PARENT</span><span style="width:170px">ÉTAT</span>
    </div>
    {rows}
  </section>
  <div class="note">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>Les lignes « À corriger » ne sont pas importées : corrigez-les dans votre fichier puis choisissez-le à nouveau, ou importez les autres maintenant et ajoutez ces élèves plus tard.</span></div>
</main>'''
    bar = f'''<div style="position:absolute;bottom:0;inset-inline-start:264px;inset-inline-end:0;height:84px;background:#fff;border-top:1px solid #E6E8F0;display:flex;align-items:center;gap:12px;padding:0 32px">
  <div style="flex:1" class="s13"><b style="color:#1A1D3A;font-size:15px">5 élèves</b> seront ajoutés à 4ème année · Maths, avec 2 nouveaux accès parents.</div>
  <span class="btn secondary">{icon('folder', 17)}Choisir un autre fichier</span>
  <span class="btn primary">Importer 5 élèves{icon('arrowright', 17)}</span>
</div>'''
    return page('Vérifier l\'import', f'''<div class="app" style="min-height:1200px">{sidebar('Élèves')}<div class="main">{topbar()}{content}</div></div>{bar}''', height=1200)


# ── 3. Login details ──

CREDENTIALS = [  # initials, accent, name, who, login, password
    ('SB', 'indigo', 'Sonia Ben Ali', 'Parent de Yassine', '22345678', 'kpra4827'),
    ('NT', 'turquoise', 'Nabil Trabelsi', 'Parent d\'Eya', '98123456', 'mhwe5932'),
]


def credentials_page():
    rows = ''.join(f'''<div class="row" style="padding:14px 0;{"border-top:none" if i == 0 else ""}">
  {avatar(ini, acc)}<div style="flex:1"><div class="t15">{name}</div><div class="s13">{who} · se connecte avec son téléphone</div></div>
  <div style="width:200px"><div class="cap" style="font-size:11px">IDENTIFIANT</div><div style="font-size:16px;font-weight:800;direction:ltr;text-align:start">{login}</div></div>
  <div style="width:220px"><div class="cap" style="font-size:11px">MOT DE PASSE TEMPORAIRE</div><div style="font-size:16px;font-weight:800;font-family:monospace;letter-spacing:1px">{pwd}</div></div>
  <span class="btn secondary sm">{icon('copy', 15)}Copier</span>
</div>''' for i, (ini, acc, name, who, login, pwd) in enumerate(CREDENTIALS))
    done = f'''<section class="card" style="display:flex;align-items:center;gap:16px;background:#E7F6EA;border-color:#C7E9CF">
  {badge('checkcircle', 'green', 52, 16, 24)}
  <div style="flex:1"><div style="font-size:20px;font-weight:800">5 élèves ajoutés à 4ème année · Maths</div>
    <div style="font-size:14px;color:#237A35;font-weight:600;margin-top:2px">2 nouveaux accès parents. Rania a rejoint les enfants de Sonia Kefi.</div></div>
</section>'''
    content = f'''<main class="page" style="max-width:1176px">
  {head("Envoyez-les maintenant : les mots de passe ne seront plus affichés.")}
  {steps(3)}
  {done}
  <section class="card" style="padding:20px 24px 8px">
    <div style="display:flex;align-items:center;gap:10px;padding-bottom:12px;border-bottom:1px solid #F0F1F6">
      <div style="flex:1;font-size:17px;font-weight:800">Identifiants créés <span class="count" style="background:#EEF0FA;color:#2B3990;margin-inline-start:6px">2</span></div>
      <span class="btn secondary sm">{icon('copy', 15)}Tout copier</span><span class="btn secondary sm">{icon('printer', 15)}Imprimer</span>
    </div>
    {rows}
  </section>
  <div class="note">{icon('lock', 16, color='#2B3990', style='margin-top:2px')}<span>Chacun choisit son propre mot de passe à la première connexion. « Imprimer » prépare une page par famille à découper et à donner en classe. Ines Mabrouk n'a pas de parent : ouvrez un accès depuis sa fiche si besoin.</span></div>
  <div style="display:flex;justify-content:flex-end;gap:10px"><span class="btn secondary">Importer un autre fichier</span><span class="btn primary">Voir mes élèves</span></div>
</main>'''
    return screen('Identifiants importés', content, height=900)


# ── Phones ──

def phone_top(title, sub, lang='fr'):
    arrow = f'<span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center;{"transform:scaleX(-1)" if lang == "ar" else ""}">{icon("arrowleft", 20)}</span>'
    return f'''<div style="display:flex;align-items:center;gap:12px;padding:16px 18px;background:#fff;border-bottom:1px solid #E6E8F0">{arrow}
    <div style="flex:1;min-width:0"><div style="font-size:17px;font-weight:800">{title}</div><div class="s13">{sub}</div></div></div>'''


def phone_steps(active, labels):
    return '<div style="display:flex;gap:6px">' + ''.join(
        f'<div style="flex:1;height:5px;border-radius:3px;background:{"#2B3990" if i <= active else "#E6E8F0"}"></div>' for i in range(1, 4)) + '</div>' + (
        f'<div class="s13" style="margin-top:6px;font-weight:700;color:#2B3990">{labels}</div>')


def phone_file():
    body = f'''{phone_top('Importer des élèves', 'Étape 1 sur 3 · Fichier')}
  <div style="flex:1;overflow:hidden;padding:16px;display:flex;flex-direction:column;gap:14px">
    <div style="border:2px dashed #9AA3D9;background:#F4F5FC;border-radius:20px;padding:22px;display:flex;flex-direction:column;align-items:center;gap:10px;text-align:center">
      {badge('filesheet', 'green', 48, 14, 22)}<div style="font-size:16px;font-weight:800">Choisissez votre fichier</div>
      <div class="s13">Excel (.xlsx) ou CSV, 300 lignes au plus.</div>
      <span class="btn primary" style="width:100%;justify-content:center">{icon('folder', 17)}Choisir un fichier</span></div>
    <span class="btn secondary" style="justify-content:center">{icon('download', 16)}Télécharger le modèle</span>
    <div class="field"><label>Ajouter au groupe · facultatif</label><div class="input" style="justify-content:space-between"><span style="display:flex;align-items:center;gap:8px">{square('4A', 20)}4ème année · Maths</span>{icon('chevdown', 18, color='#6B7090')}</div></div>
    <div class="field"><label>Niveau quand la colonne est vide</label><div class="input" style="justify-content:space-between"><span>4ème année</span>{icon('chevdown', 18, color='#6B7090')}</div></div>
    <div style="display:flex;gap:10px;align-items:center;padding:12px;border:1px solid #E6E8F0;border-radius:14px;background:#fff">
      <span style="width:42px;height:24px;border-radius:12px;background:#CDD0DE;position:relative;flex-shrink:0"><span style="position:absolute;top:3px;inset-inline-start:3px;width:18px;height:18px;border-radius:9px;background:#fff"></span></span>
      <div style="font-size:14px;font-weight:700">Créer aussi l'accès des élèves</div></div>
  </div>'''
    return frame(body)


def phone_preview_ar():
    def card(pupil, parent, phone, label, accent, note=None, checked=True, disabled=False):
        n = f'<div style="font-size:12px;margin-top:6px;color:{ACCENTS[accent][2]};font-weight:600">{note}</div>' if note else ''
        p = f'<div class="s13"><bdi>{parent}</bdi> · <span style="direction:ltr;display:inline-block">{phone}</span></div>' if parent else '<div class="s13">بلا وليّ</div>'
        return (f'<div style="display:flex;gap:12px;padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px;align-items:flex-start">'
                f'<div style="padding-top:2px">{checkbox(checked, disabled)}</div><div style="flex:1;min-width:0">'
                f'<div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap"><span class="t15"><bdi>{pupil}</bdi></span>{chip(label, accent)}</div>{p}{n}</div></div>')
    body = f'''{phone_top('استيراد التلاميذ', 'الخطوة 2 من 3 · التثبّت', 'ar')}
  <div style="flex:1;overflow:hidden;padding:16px;display:flex;flex-direction:column;gap:10px">
    <div style="display:flex;gap:8px;flex-wrap:wrap">{chip('4 جاهزون', 'green')}{chip('1 مُسجّل', 'amber')}{chip('2 للتصحيح', 'red')}</div>
    {card('Yassine Ben Ali', 'Sonia Ben Ali', '22 345 678', 'جاهز', 'green')}
    {card('Rania Kefi', 'Sonia Kefi', '22 111 222', 'وليّ مُسجّل', 'blue', 'حساب <bdi>Sonia Kefi</bdi> موجود: تُضاف <bdi>Rania</bdi> إلى أبنائها.')}
    {card('Amine Kefi', 'Sonia Kefi', '22 111 222', 'مُسجّل', 'amber', 'هو ضمن تلاميذك: يُتجاهل السطر.', checked=False)}
    {card('Mohamed Aziz Gharsalli', 'Hela Gharsalli', '2234567', 'للتصحيح', 'red', 'هاتف الوليّ: 8 أرقام.', checked=False, disabled=True)}
  </div>
  <div style="padding:12px 16px 16px;background:#fff;border-top:1px solid #E6E8F0"><span class="btn primary" style="height:52px;justify-content:center;width:100%">استيراد 5 تلاميذ</span></div>'''
    return frame(body, 'ar')


def phone_credentials():
    body = f'''{phone_top('Importer des élèves', 'Étape 3 sur 3 · Identifiants')}
  <div style="flex:1;overflow:hidden;padding:16px;display:flex;flex-direction:column;gap:12px">
    <div style="display:flex;gap:12px;align-items:center;padding:14px;border-radius:18px;background:#E7F6EA">{badge('checkcircle', 'green', 40, 12, 20)}<div><div style="font-size:15px;font-weight:800">5 élèves ajoutés</div><div class="s13" style="color:#237A35">2 nouveaux accès parents</div></div></div>
    {''.join(f"""<div style="padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px;display:flex;flex-direction:column;gap:10px">
      <div style="display:flex;align-items:center;gap:10px">{avatar(ini, acc)}<div style="flex:1"><div class="t15">{name}</div><div class="s13">{who}</div></div><span class="btn secondary sm" style="width:38px;padding:0;justify-content:center">{icon('copy', 15)}</span></div>
      <div style="display:flex;gap:8px"><div style="flex:1;padding:10px;background:#F6F7FB;border-radius:12px"><div class="cap" style="font-size:10px">IDENTIFIANT</div><div style="font-size:15px;font-weight:800">{login}</div></div>
      <div style="flex:1;padding:10px;background:#F6F7FB;border-radius:12px"><div class="cap" style="font-size:10px">MOT DE PASSE</div><div style="font-size:15px;font-weight:800;font-family:monospace">{pwd}</div></div></div></div>""" for ini, acc, name, who, login, pwd in CREDENTIALS)}
    <div style="display:flex;gap:8px"><span class="btn secondary" style="flex:1;justify-content:center">{icon('copy', 16)}Tout copier</span><span class="btn secondary" style="flex:1;justify-content:center">{icon('printer', 16)}Imprimer</span></div>
  </div>
  <div style="padding:12px 16px 16px;background:#fff;border-top:1px solid #E6E8F0"><span class="btn primary" style="height:52px;justify-content:center;width:100%">Voir mes élèves</span></div>'''
    return frame(body)


NOTES = [
    ('Où', 'Élèves › « Importer » (le bouton existe déjà, il disait « bientôt »). Une page en trois étapes : Fichier, Vérifier, Identifiants.'),
    ('Le fichier', 'Excel (.xlsx) ou CSV (virgule ou point-virgule), 300 lignes au plus. Colonnes en français ou en arabe : Prénom et Nom obligatoires ; Niveau, Groupe, parent (prénom, nom, téléphone) facultatifs. « Télécharger le modèle » donne un fichier prêt à remplir.'),
    ('Pour tous', 'Un groupe où ajouter tout le monde (facultatif), le niveau quand la colonne est vide, et l\'accès des élèves (non par défaut : les parents suivent).'),
    ('Vérifier', 'Chaque ligne lue avant de créer quoi que ce soit : « Prêt », « Parent déjà inscrit » (le même téléphone : l\'enfant rejoint ses frères et sœurs, pas de nouvel accès), « Déjà inscrit » (même prénom et nom : décoché, vous pouvez le cocher), « À corriger » (téléphone, niveau ou groupe inconnu, nom manquant : jamais importé).'),
    ('Importer', 'Tout ou rien : les élèves cochés et leurs parents sont créés ensemble. Les identifiants des élèves suivent la règle habituelle (prenom.nom, un chiffre si déjà pris).'),
    ('Identifiants', 'Les accès créés, une seule fois : « Copier » pour une famille, « Tout copier », « Imprimer » (un PDF, une carte par famille à découper). Chacun choisit son mot de passe à la première connexion.'),
    ('Téléphone et arabe', 'Les mêmes étapes en une colonne, de droite à gauche en arabe ; les noms français et les numéros gardent leur sens de lecture.'),
]


def phone_board():
    def column(label, content):
        return f'<div style="display:flex;flex-direction:column;gap:14px;align-items:center"><div class="cap" style="font-size:13px">{label}</div>{content}</div>'
    notes = ''.join(
        f'<div style="display:flex;gap:12px"><span style="width:26px;height:26px;border-radius:13px;background:#2B3990;color:#fff;font-size:13px;font-weight:800;display:flex;align-items:center;justify-content:center;flex-shrink:0">{i}</span>'
        f'<div><div style="font-size:15px;font-weight:800">{title}</div><div style="font-size:14px;color:#4A4F72;line-height:1.5;margin-top:2px">{text}</div></div></div>'
        for i, (title, text) in enumerate(NOTES, 1))
    body = f'''<div style="padding:48px;display:flex;flex-direction:column;gap:40px;background:#EEF0FA">
  <div style="display:flex;gap:40px;justify-content:center;align-items:flex-start">
    {column('TÉLÉPHONE · FICHIER', phone_file())}
    {column('ARABE · التثبّت', phone_preview_ar())}
    {column('TÉLÉPHONE · IDENTIFIANTS', phone_credentials())}
  </div>
  <div style="background:#fff;border:1px solid #E6E8F0;border-radius:24px;padding:26px;display:flex;flex-direction:column;gap:16px;max-width:1260px;margin:0 auto">
    <div style="font-size:22px;font-weight:800">Importer des élèves depuis Excel</div>
    <div style="font-size:14px;color:#6B7090;line-height:1.5">Spec 02 « CSV import », question client Q12. Données inventées, jeudi 8 octobre.</div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px 32px">{notes}</div>
  </div>
</div>'''
    return page('Importer des élèves sur téléphone', body, width=1440, height=1700)


if __name__ == '__main__':
    (OUT / 'ImportEleves.html').write_text(file_page())
    (OUT / 'ImportElevesVerifier.html').write_text(preview_page())
    (OUT / 'ImportElevesIdentifiants.html').write_text(credentials_page())
    (OUT / 'ImportElevesPhone.html').write_text(phone_board())
    print('ImportEleves, ImportElevesVerifier, ImportElevesIdentifiants, ImportElevesPhone')
