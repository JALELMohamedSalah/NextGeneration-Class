"""Release 2, step 1: the content library ("Contenus") and the pupil's "Cours", in the approved R1 style."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'r1' / '_generator'))

import common  # noqa: E402
from common import ACCENTS, avatar, badge, chip, icon, page, teacher  # noqa: E402
from planning import phone  # noqa: E402

OUT = Path(__file__).resolve().parents[1]

common.ICONS.update({
    'filetext': '<path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4M10 9H8M16 13H8M16 17H8"/>',
    'image': '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-3.09-3.09a2 2 0 0 0-2.82 0L6 21"/>',
    'fileword': '<path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4M8 12l1.5 6 2.5-4 2.5 4L16 12"/>',
    'download': '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/>',
    'share': '<circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><path d="m8.59 13.51 6.83 3.98M15.41 6.51l-6.82 3.98"/>',
    'zoomin': '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3M11 8v6M8 11h6"/>',
    'zoomout': '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3M8 11h6"/>',
    'camera': '<path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"/><circle cx="12" cy="13" r="3"/>',
    'folderplus': '<path d="M12 10v6M9 13h6"/><path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z"/>',
    'checksquare': '<rect x="3" y="3" width="18" height="18" rx="4"/><path d="m8 12 3 3 5-6"/>',
})

MATHS, LECTURE, EVEIL, PRIVATE = '#2B3990', '#12A39A', '#FFB020', '#7048E8'
common.GROUPS[:] = [('4A', '4ème année · Maths', MATHS, '#fff', 6), ('4L', '4ème année · Lecture', LECTURE, '#fff', 5),
                    ('6E', '6ème année · Éveil', EVEIL, '#1A1D3A', 4), ('SB', 'Sara Ben Amor · Lecture', PRIVATE, '#fff', 1)]

KIND = {  # icon, accent, label
    'pdf': ('filetext', 'red', 'PDF'),
    'image': ('image', 'turquoise', 'Image'),
    'word': ('fileword', 'blue', 'Word'),
}
TAG = {'Série': 'indigo', 'Cours': 'turquoise', 'Corrigé': 'violet', 'Autre': 'grey'}

ITEMS = [  # kind, title, detail, tag, published, shared, edited
    ('pdf', 'Leçon : les fractions simples', 'PDF · 2 pages · 640 Ko', 'Cours', True, ['4A'], '28 sept.'),
    ('pdf', 'Série 2 : les fractions', 'PDF · 3 pages · 1,2 Mo', 'Série', True, ['4A'], 'Hier'),
    ('pdf', 'Corrigé de la série 2', 'PDF · 3 pages · 1,1 Mo', 'Corrigé', False, [], 'Hier'),
    ('image', 'Photo du tableau, 2 octobre', 'JPG · 380 Ko', 'Autre', True, ['4A'], '2 oct.'),
    ('word', 'Fiche de révision', 'Word · 96 Ko · à télécharger', 'Autre', True, [], '25 sept.'),
]


def square(code, size=24):
    color, fg = {'4A': (MATHS, '#fff'), '4L': (LECTURE, '#fff'), '6E': (EVEIL, '#1A1D3A'), 'SB': (PRIVATE, '#fff')}[code]
    return (f'<span class="sq" style="width:{size}px;height:{size}px;background:{color};color:{fg};font-size:{11 if size >= 24 else 10}px">'
            f'{code}</span>')


def checkbox(on, size=22):
    if on:
        return f'<span style="color:#2B3990;display:flex">{icon("checksquare", size)}</span>'
    return f'<span style="display:block;width:{size}px;height:{size}px;border:2px solid #CDD0DE;border-radius:6px;flex-shrink:0"></span>'


def kind_badge(kind, size=40):
    name, accent, _ = KIND[kind]
    return badge(name, accent, size, 12 if size >= 40 else 10, 20 if size >= 40 else 17)


def tree():
    def chapter(label, n, on=False):
        style = 'background:#EEF0FA;color:#2B3990;font-weight:700' if on else 'color:#1A1D3A'
        return (f'<div style="display:flex;align-items:center;gap:10px;height:38px;padding:0 10px 0 12px;border-radius:10px;font-size:14px;{style}">'
                f'<span style="flex:1">{label}</span><span class="cap" style="font-weight:600">{n}</span></div>')

    def level(label, n, open_=False, body=''):
        return (f'<div style="display:flex;align-items:center;gap:8px;height:36px;padding:0 6px;font-size:13px;font-weight:700;color:#4A4F72">'
                f'{icon("chevdown" if open_ else "chevright", 16)}<span style="flex:1">{label}</span><span class="cap" style="font-weight:600">{n}</span></div>'
                f'<div style="padding-inline-start:18px;display:flex;flex-direction:column;gap:2px">{body}</div>')

    def subject(color, label, n, open_=False, body=''):
        return (f'<div style="display:flex;align-items:center;gap:10px;height:40px;font-size:15px;font-weight:800">'
                f'<span style="width:12px;height:12px;border-radius:4px;background:{color}"></span><span style="flex:1">{label}</span>'
                f'<span class="cap" style="font-weight:600">{n}</span>{icon("chevdown" if open_ else "chevright", 16, color="#6B7090")}</div>{body}')

    maths = (level('4ème année', 10, True, chapter('Les fractions', 5, True) + chapter('La multiplication', 3) + chapter('Les mesures de longueur', 2)
                   + chapter('<span style="color:#6B7090">Sans chapitre</span>', 1))
             + level('5ème année', 6))
    return f'''<section class="card" style="width:300px;flex-shrink:0;padding:18px;display:flex;flex-direction:column;gap:6px;align-self:flex-start">
  {subject(MATHS, 'Mathématiques', 17, True, maths)}
  <div style="height:1px;background:#F0F1F6;margin:6px 0"></div>
  {subject(LECTURE, 'Lecture', 5)}
  {subject(EVEIL, 'Éveil scientifique', 2)}
  <div style="height:1px;background:#F0F1F6;margin:6px 0"></div>
  <span class="btn ghost sm" style="padding:0 6px;color:#2B3990">{icon('folderplus', 16)}Nouveau chapitre</span>
</section>'''


def rows():
    out = ''
    for i, (kind, title, detail, tag, published, shared, edited) in enumerate(ITEMS):
        status = chip('Publié', 'green') if published else chip('Brouillon', 'grey')
        groups = ''.join(square(c) for c in shared) if shared else '<span class="s13">Non partagé</span>'
        out += f'''<div class="row" style="padding:14px 0;{"border-top:none" if i == 0 else ""}">
  {kind_badge(kind)}
  <div style="flex:1;min-width:0"><div class="t15">{title}</div><div class="s13">{detail}</div></div>
  <div style="width:96px">{chip(tag, TAG[tag], dot=False)}</div>
  <div style="width:104px">{status}</div>
  <div style="width:110px;display:flex;gap:6px;align-items:center">{groups}</div>
  <div style="width:72px" class="s13">{edited}</div>
  <span style="color:#6B7090">{icon('more', 20)}</span>
</div>'''
    return out


def library():
    return f'''<main class="page" style="max-width:1176px">
  <div style="display:flex;align-items:flex-end;gap:12px">
    <div style="flex:1"><h1 class="ptitle">Contenus</h1>
      <div style="font-size:15px;color:#4A4F72;margin-top:6px">Vos documents, rangés par matière, niveau et chapitre.</div></div>
    <span class="btn secondary">{icon('folderplus', 18)}Nouveau chapitre</span>
    <span class="btn primary">{icon('upload', 18)}Importer un document</span>
  </div>
  <div style="display:flex;gap:24px;align-items:flex-start">
    {tree()}
    <section class="card" style="flex:1;min-width:0;padding:22px 24px">
      <div style="display:flex;align-items:center;gap:12px;margin-bottom:6px">
        <div style="flex:1"><div class="cap" style="letter-spacing:1px">MATHÉMATIQUES · 4ÈME ANNÉE</div>
          <div style="font-size:22px;font-weight:800;margin-top:2px">Les fractions</div></div>
        <span class="btn secondary sm">{icon('share', 16)}Partager le chapitre</span>
        <span class="btn secondary sm" style="width:38px;padding:0;justify-content:center">{icon('more', 18)}</span>
      </div>
      <div style="display:flex;gap:10px;align-items:center;margin:14px 0 8px">
        <div class="search" style="flex:0 1 300px;height:40px;background:#fff">{icon('search', 16)}Rechercher un titre</div>
        <span class="btn secondary sm">{icon('filter', 15)}Étiquette : toutes</span>
        <span class="btn secondary sm">Statut : tous</span>
        <span style="flex:1"></span><span class="s13">5 documents</span>
      </div>
      <div style="display:flex;gap:14px;padding:10px 0;border-bottom:1px solid #F0F1F6" class="cap">
        <span style="width:40px"></span><span style="flex:1">DOCUMENT</span><span style="width:96px">ÉTIQUETTE</span><span style="width:104px">STATUT</span>
        <span style="width:110px">PARTAGÉ AVEC</span><span style="width:72px">MODIFIÉ</span><span style="width:20px"></span>
      </div>
      {rows()}
    </section>
  </div>
</main>'''


def import_panel():
    groups = ''.join(
        f'<div style="display:flex;align-items:center;gap:12px;padding:10px 12px;border:1px solid {"#2B3990" if on else "#E6E8F0"};border-radius:14px;{"background:#F4F5FC" if on else ""}">'
        f'{checkbox(on, 20)}'
        f'{square(code)}<span style="flex:1;font-size:14px;font-weight:600">{name}</span><span class="s13">{n} élèves</span></div>'
        for code, name, n, on in [('4A', '4ème année · Maths', 6, True), ('4L', '4ème année · Lecture', 5, False)])
    seg = ''.join(f'<span class="{"on" if t == "Série" else ""}">{t}</span>' for t in ['Série', 'Cours', 'Corrigé', 'Autre'])
    return f'''<div class="scrim"></div>
<div class="panel">
  <div class="panel-h">{badge('upload', 'indigo', 44, 14, 20)}<div style="flex:1"><div style="font-size:20px;font-weight:800">Importer un document</div>
    <div class="s13">PDF, photo ou Word. Il est rangé dans un chapitre, puis partagé quand vous voulez.</div></div>{icon('x', 22, color='#6B7090')}</div>
  <div class="panel-b" style="gap:16px">
    <div style="display:flex;align-items:center;gap:12px;padding:12px 14px;border:1.5px dashed #9AA3D9;border-radius:16px;background:#F4F5FC">
      {kind_badge('pdf')}<div style="flex:1"><div class="t15">serie2_fractions.pdf</div><div class="s13">PDF · 3 pages · 1,2 Mo</div>
        <div style="height:6px;border-radius:3px;background:#DCE0F5;margin-top:8px"><div style="width:100%;height:6px;border-radius:3px;background:#2F9E44"></div></div></div>
      <span class="btn ghost sm" style="color:#2B3990">Changer</span>
    </div>
    <div class="field"><label>Titre</label><div class="input focus">Série 2 : les fractions</div><div class="hint">Pris du nom du fichier. Les élèves voient ce titre.</div></div>
    <div style="display:flex;gap:12px">
      <div class="field" style="flex:1"><label>Matière et niveau</label><div class="input" style="justify-content:space-between">Maths · 4ème année{icon('chevdown', 18, color='#6B7090')}</div></div>
      <div class="field" style="flex:1"><label>Chapitre</label><div class="input" style="justify-content:space-between">Les fractions{icon('chevdown', 18, color='#6B7090')}</div></div>
    </div>
    <div class="field"><label>Étiquette</label><div class="seg">{seg}</div></div>
    <div class="field"><label>Partager avec <span class="s13" style="font-weight:500">· facultatif</span></label>{groups}
      <div class="hint">Les élèves de ces groupes le voient dans Cours. Vous pourrez partager plus tard.</div></div>
    <div style="display:flex;align-items:center;gap:12px;padding:12px 14px;border:1px solid #E6E8F0;border-radius:14px">
      <div style="flex:1"><div style="font-size:14px;font-weight:700">Garder en brouillon</div><div class="s13">Un brouillon n'est jamais visible par les élèves.</div></div>
      <span style="width:46px;height:28px;border-radius:14px;background:#DDE0EA;position:relative"><span style="position:absolute;top:3px;inset-inline-start:3px;width:22px;height:22px;border-radius:11px;background:#fff;box-shadow:0 1px 3px rgba(0,0,0,.2)"></span></span>
    </div>
  </div>
  <div class="panel-f"><span class="btn ghost">Annuler</span><span class="btn primary">{icon('upload', 17)}Importer</span></div>
</div>'''


def share_dialog():
    def option(code, name, sub, on, dim=False):
        box = checkbox(on)
        return (f'<div style="display:flex;align-items:center;gap:12px;padding:12px 14px;border:1px solid {"#2B3990" if on else "#E6E8F0"};border-radius:14px;'
                f'{"background:#F4F5FC;" if on else ""}{"opacity:.55;" if dim else ""}">{box}{square(code)}'
                f'<div style="flex:1"><div style="font-size:14px;font-weight:700">{name}</div><div class="s13">{sub}</div></div></div>')

    return f'''<div class="scrim"></div>
<div style="position:absolute;top:120px;left:50%;transform:translateX(-50%);width:560px;background:#fff;border-radius:28px;box-shadow:0 30px 80px rgba(28,37,102,.25);padding:26px;display:flex;flex-direction:column;gap:16px">
  <div style="display:flex;align-items:center;gap:14px">{badge('share', 'indigo', 46, 14, 21)}<div style="flex:1"><div style="font-size:20px;font-weight:800">Partager « Série 2 : les fractions »</div>
    <div class="s13">Les élèves des groupes cochés le voient dans leur onglet Cours.</div></div></div>
  <div class="cap" style="letter-spacing:1px;margin-top:4px">GROUPES DE 4ÈME ANNÉE</div>
  {option('4A', '4ème année · Maths', '6 élèves · déjà partagé le 5 octobre', True)}
  {option('4L', '4ème année · Lecture', '5 élèves', False)}
  <div class="cap" style="letter-spacing:1px;margin-top:4px">AUTRES GROUPES</div>
  {option('SB', 'Sara Ben Amor · Lecture', 'Cours particulier · 3ème année', False)}
  {option('6E', '6ème année · Éveil', '4 élèves', False)}
  <div class="note">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>Décocher un groupe retire le document de son onglet Cours. Rien n'est supprimé.</span></div>
  <div style="display:flex;gap:10px;justify-content:flex-end"><span class="btn ghost">Annuler</span><span class="btn primary">Enregistrer</span></div>
</div>'''


def worksheet(scale=1.0, lang='fr'):
    """A primary school worksheet page, drawn in HTML."""
    s = scale

    def px(v):
        return f'{v * s:.0f}px'

    lines = ''.join(f'<div style="height:{px(2)};background:#E3E5EE;margin-top:{px(26)}"></div>' for _ in range(3))
    pies = ''.join(
        f'<div style="width:{px(64)};height:{px(64)};border-radius:50%;border:{px(3)} solid #1A1D3A;background:conic-gradient(#9AA3D9 0 {p}%, #fff {p}% 100%)"></div>'
        for p in (25, 50, 75))
    return f'''<div dir="ltr" style="background:#fff;width:{px(560)};padding:{px(44)} {px(48)};box-shadow:0 8px 30px rgba(28,37,102,.12);border-radius:{px(6)};font-family:'Plus Jakarta Sans';color:#1A1D3A">
  <div style="display:flex;justify-content:space-between;font-size:{px(12)};color:#6B7090"><span>4ème année · Mathématiques</span><span>Nom : ..................</span></div>
  <div style="font-size:{px(24)};font-weight:800;margin-top:{px(18)}">Série 2 : les fractions</div>
  <div style="font-size:{px(15)};font-weight:700;margin-top:{px(22)}">Exercice 1</div>
  <div style="font-size:{px(14)};margin-top:{px(6)}">Écris la fraction coloriée sous chaque disque.</div>
  <div style="display:flex;gap:{px(40)};margin-top:{px(16)}">{pies}</div>
  <div style="font-size:{px(15)};font-weight:700;margin-top:{px(26)}">Exercice 2</div>
  <div style="font-size:{px(14)};margin-top:{px(6)}">Range du plus petit au plus grand : 3/4 ; 1/4 ; 2/4.</div>
  {lines}
  <div style="font-size:{px(15)};font-weight:700;margin-top:{px(26)}">Exercice 3</div>
  <div style="font-size:{px(14)};margin-top:{px(6)}">Sami mange 2/8 d'une pizza. Quelle part reste-t-il ?</div>
  {lines}
</div>'''


def viewer():
    info = [('Matière', 'Mathématiques'), ('Niveau', '4ème année'), ('Chapitre', 'Les fractions'), ('Étiquette', chip('Série', 'indigo', dot=False)),
            ('Statut', chip('Publié', 'green')), ('Partagé avec', f'<span style="display:flex;gap:6px;align-items:center">{square("4A")}<span style="font-size:14px">4ème année · Maths</span></span>'),
            ('Fichier', 'serie2_fractions.pdf · 1,2 Mo'), ('Ajouté', 'lundi 5 octobre')]
    rows_ = ''.join(f'<div style="display:flex;flex-direction:column;gap:4px;padding:10px 0;border-top:1px solid #F0F1F6"><span class="cap">{k}</span><span style="font-size:14px;font-weight:600">{v}</span></div>'
                    for k, v in info)
    body = f'''<div style="display:flex;flex-direction:column;height:900px">
  <div class="top" style="gap:14px;padding:0 24px">
    <span class="btn secondary" style="width:44px;padding:0;justify-content:center">{icon('arrowleft', 20)}</span>
    {kind_badge('pdf')}
    <div style="flex:1"><div style="font-size:18px;font-weight:800">Série 2 : les fractions</div><div class="s13">Mathématiques · 4ème année · Les fractions</div></div>
    <span class="btn secondary">{icon('download', 18)}Télécharger</span>
    <span class="btn primary">{icon('share', 18)}Partager</span>
    <span class="btn secondary" style="width:44px;padding:0;justify-content:center">{icon('more', 20)}</span>
  </div>
  <div style="flex:1;display:flex;min-height:0">
    <div style="flex:1;background:#E9EBF3;display:flex;flex-direction:column;align-items:center;padding:28px 0 0;gap:18px;overflow:hidden;position:relative">
      {worksheet(1.0)}
      <div style="position:absolute;bottom:24px;display:flex;align-items:center;gap:6px;padding:6px;background:#1A1D3A;border-radius:14px;color:#fff;font-size:13px;font-weight:700">
        <span style="padding:6px 8px">{icon('chevleft', 18)}</span><span style="padding:0 6px">Page 1 sur 3</span><span style="padding:6px 8px">{icon('chevright', 18)}</span>
        <span style="width:1px;height:20px;background:#ffffff40"></span><span style="padding:6px 8px">{icon('zoomout', 18)}</span><span>100 %</span><span style="padding:6px 8px">{icon('zoomin', 18)}</span>
      </div>
    </div>
    <aside style="width:320px;background:#fff;border-inline-start:1px solid #E6E8F0;padding:22px 24px;display:flex;flex-direction:column">
      <div style="font-size:16px;font-weight:800;margin-bottom:8px">Détails</div>{rows_}
      <span class="btn secondary sm" style="margin-top:16px;align-self:flex-start">{icon('pencil', 15)}Modifier les détails</span>
    </aside>
  </div>
</div>'''
    return page('Document', body)


# ── Phones ──

TEACHER_NAV = [('calcheck', 'Journée'), ('calendar', 'Planning'), ('users', 'Élèves'), ('folder', 'Contenus'), ('more', 'Plus')]


def phone_header(initials='IH', accent='indigo'):
    return f'''<div style="display:flex;align-items:center;gap:10px">
  <img src="../ng-symbol.png" style="height:26px" alt=""><span style="flex:1;font-family:'Plus Jakarta Sans';font-size:15px;font-weight:700;color:#2B3990">NG Class</span>
  <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center;color:#4A4F72">{icon('bell', 20)}</span>
  {avatar(initials, accent, 40, True)}
</div>'''


def card(kind, title, sub, extra='', new=False, lang='fr'):
    new_chip = chip('Nouveau' if lang == 'fr' else 'جديد', 'amber') if new else ''
    return (f'<div style="display:flex;align-items:center;gap:12px;padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px">'
            f'{kind_badge(kind, 44)}<div style="flex:1;min-width:0"><div style="font-size:16px;font-weight:700">{title}</div>'
            f'<div style="font-size:14px;color:#6B7090;margin-top:2px">{sub}</div>{extra}</div>{new_chip}</div>')


def teacher_phone():
    chips = ''.join(
        f'<span class="chip" style="padding:8px 12px;font-size:13px;{"background:#1A1D3A;color:#fff" if on else "background:#fff;border:1px solid #E6E8F0;color:#1A1D3A"}">{t} <span style="opacity:.7">{n}</span></span>'
        for t, n, on in [('Les fractions', 5, True), ('La multiplication', 3, False), ('Les mesures', 2, False)])
    shared = f'<div style="display:flex;gap:6px;align-items:center;margin-top:8px">{chip("Série", "indigo", dot=False)}{square("4A", 22)}</div>'
    draft = f'<div style="display:flex;gap:6px;align-items:center;margin-top:8px">{chip("Corrigé", "violet", dot=False)}{chip("Brouillon", "grey")}</div>'
    return phone(f'''
    {phone_header()}
    <div style="display:flex;align-items:center;gap:10px"><div style="flex:1;font-size:26px;font-weight:800;letter-spacing:-.5px">Contenus</div>
      <span class="btn primary" style="height:42px">{icon('upload', 17)}Importer</span></div>
    <div class="input" style="background:#fff;justify-content:space-between;font-weight:700"><span style="display:flex;align-items:center;gap:10px"><span style="width:12px;height:12px;border-radius:4px;background:{MATHS}"></span>Mathématiques · 4ème année</span>{icon('chevdown', 18, color='#6B7090')}</div>
    <div style="display:flex;gap:8px;overflow:hidden;white-space:nowrap">{chips}</div>
    {card('pdf', 'Leçon : les fractions simples', 'PDF · 2 pages', f'<div style="display:flex;gap:6px;align-items:center;margin-top:8px">{chip("Cours", "turquoise", dot=False)}{square("4A", 22)}</div>')}
    {card('pdf', 'Série 2 : les fractions', 'PDF · 3 pages', shared)}
    {card('pdf', 'Corrigé de la série 2', 'PDF · 3 pages', draft)}
    {card('image', 'Photo du tableau, 2 octobre', 'JPG', f'<div style="display:flex;gap:6px;align-items:center;margin-top:8px">{chip("Autre", "grey", dot=False)}{square("4A", 22)}</div>')}
    ''', TEACHER_NAV, 'fr', 3)


def pupil_cours(lang='fr'):
    if lang == 'fr':
        t = dict(title='Mes cours', sub='Ce qui a été partagé avec toi, par matière.', all='Tout', maths='Maths', lecture='Lecture',
                 m='MATHÉMATIQUES', l='LECTURE', lesson='Leçon · 2 pages', series='Série · 3 pages', photo='Photo', text='Texte · 1 page')
        nav = [('house', 'Accueil'), ('book', 'Cours'), ('calendar', 'Planning')]
        bdi = lambda x: x  # noqa: E731
    else:
        t = dict(title='دروسي', sub='ما تمّت مشاركته معك، حسب المادة.', all='الكل', maths='الرياضيات', lecture='القراءة',
                 m='الرياضيات', l='القراءة', lesson='درس · صفحتان', series='سلسلة · 3 صفحات', photo='صورة', text='نص · صفحة واحدة')
        nav = [('house', 'الرئيسية'), ('book', 'الدروس'), ('calendar', 'الجدول')]
        bdi = lambda x: f'<bdi>{x}</bdi>'  # noqa: E731
    chips = ''.join(
        f'<span class="chip" style="padding:8px 14px;font-size:14px;{"background:#1A1D3A;color:#fff" if on else "background:#fff;border:1px solid #E6E8F0;color:#1A1D3A"}">{x}</span>'
        for x, on in [(t['all'], True), (t['maths'], False), (t['lecture'], False)])

    def section(color, label, chapter, items):
        return (f'<div style="display:flex;flex-direction:column;gap:10px"><div style="display:flex;align-items:center;gap:8px">'
                f'<span style="width:10px;height:10px;border-radius:3px;background:{color}"></span>'
                f'<span style="font-size:12px;font-weight:800;letter-spacing:{1 if lang == "fr" else 0}px;color:#4A4F72">{label}</span></div>'
                f'<div style="font-size:18px;font-weight:800">{bdi(chapter)}</div>{items}</div>')

    return phone(f'''
    {phone_header('AG')}
    <div><div style="font-size:26px;font-weight:800;letter-spacing:-.5px">{t['title']}</div><div style="font-size:15px;color:#4A4F72;margin-top:4px">{t['sub']}</div></div>
    <div style="display:flex;gap:8px">{chips}</div>
    {section(MATHS, t['m'], 'Les fractions',
             card('pdf', bdi('Série 2 : les fractions'), t['series'], new=True, lang=lang) + card('pdf', bdi('Leçon : les fractions simples'), t['lesson'], lang=lang)
             + card('image', bdi('Photo du tableau, 2 octobre'), t['photo'], lang=lang))}
    {section(LECTURE, t['l'], 'Contes et fables', card('pdf', bdi('Le corbeau et le renard'), t['text'], lang=lang))}
    ''', nav, lang, 1)


def pupil_document():
    return phone(f'''
    <div style="display:flex;align-items:center;gap:12px">
      <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center">{icon('arrowleft', 20)}</span>
      <div style="flex:1;min-width:0"><div style="font-size:17px;font-weight:800">Série 2 : les fractions</div><div class="s13" style="font-size:13px">Maths · Les fractions</div></div>
    </div>
    <div style="flex:1;margin:0 -18px;background:#E9EBF3;display:flex;justify-content:center;padding-top:18px;overflow:hidden">{worksheet(0.62)}</div>
    <div style="display:flex;align-items:center;gap:10px">
      <span class="btn secondary" style="width:48px;height:48px;padding:0;justify-content:center">{icon('chevleft', 20)}</span>
      <div style="flex:1;text-align:center;font-size:15px;font-weight:700">Page 1 sur 3</div>
      <span class="btn secondary" style="width:48px;height:48px;padding:0;justify-content:center">{icon('chevright', 20)}</span>
    </div>
    <span class="btn tonal" style="height:50px;justify-content:center">{icon('download', 18)}Télécharger</span>
    ''', [('house', 'Accueil'), ('book', 'Cours'), ('calendar', 'Planning')], 'fr', 1)


def parent_cours():
    kids = ''.join(
        f'<span class="chip" style="padding:8px 14px;font-size:13px;{"background:#1A1D3A;color:#fff" if on else "background:#fff;border:1px solid #E6E8F0;color:#1A1D3A"}">{x}</span>'
        for x, on in [('Adam · 4ème année', True), ('Lina · 6ème année', False)])
    return phone(f'''
    {phone_header('MG', 'turquoise')}
    <div><div style="font-size:26px;font-weight:800;letter-spacing:-.5px">Cours d'Adam</div><div style="font-size:15px;color:#4A4F72;margin-top:4px">Les documents partagés par l'enseignante.</div></div>
    <div style="display:flex;gap:8px">{kids}</div>
    <div style="display:flex;align-items:center;gap:8px"><span style="width:10px;height:10px;border-radius:3px;background:{MATHS}"></span><span style="font-size:12px;font-weight:800;letter-spacing:1px;color:#4A4F72">MATHÉMATIQUES · LES FRACTIONS</span></div>
    {card('pdf', 'Série 2 : les fractions', 'Série · partagée hier', new=True)}
    {card('pdf', 'Leçon : les fractions simples', 'Leçon · 28 septembre')}
    {card('image', 'Photo du tableau, 2 octobre', 'Photo · 2 octobre')}
    <div class="note">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>Adam n'a pas de compte : vous ouvrez ses documents ici et vous pouvez les imprimer.</span></div>
    ''', [('dashboard', 'Aperçu'), ('book', 'Cours'), ('calendar', 'Planning'), ('bell', 'Notifications')], 'fr', 1)


NOTES = [
    ('Rangement', 'Matière, puis niveau, puis chapitre. Un document sans chapitre va dans « Sans chapitre ». Les chapitres se créent et se renomment dans la colonne de gauche.'),
    ('Importer', 'PDF, photo (JPG, PNG, HEIC) ou Word, 20 Mo au plus. Le titre est pris du nom du fichier. Une photo est réduite sur le téléphone avant l\'envoi.'),
    ('Étiquette', 'Série, Cours, Corrigé ou Autre, pour retrouver vite un document.'),
    ('Brouillon', 'Un brouillon n\'est jamais visible par les élèves, ni partagé. Par défaut un document importé est publié.'),
    ('Partager', 'Un document ou tout un chapitre (les documents ajoutés ensuite aussi). Décocher un groupe retire l\'accès, rien n\'est supprimé.'),
    ('Lire dans l\'application', 'PDF et images s\'ouvrent dans l\'application, page par page. Word se télécharge seulement : exportez en PDF depuis Word.'),
    ('Élève : onglet Cours', 'Ce qui est partagé avec ses groupes, par matière et chapitre. « Nouveau » tant qu\'il ne l\'a pas ouvert.'),
    ('Parent : onglet Cours (proposition)', 'La plupart des élèves n\'ont pas de compte : le parent ouvre et imprime les documents de son enfant.'),
    ('Ensuite', 'Étape 2 : scanner des feuilles avec l\'appareil photo en un seul PDF. Puis les devoirs. Les leçons, exercices et quiz créés dans l\'application viennent avec la version 3.'),
]


def board():
    def column(label, content):
        return f'<div style="display:flex;flex-direction:column;gap:14px;align-items:center"><div class="cap" style="font-size:13px">{label}</div>{content}</div>'

    notes = ''.join(
        f'<div style="display:flex;gap:12px"><span style="width:26px;height:26px;border-radius:13px;background:#2B3990;color:#fff;font-size:13px;font-weight:800;display:flex;align-items:center;justify-content:center;flex-shrink:0">{i}</span>'
        f'<div><div style="font-size:15px;font-weight:800">{title}</div><div style="font-size:14px;color:#4A4F72;line-height:1.5;margin-top:2px">{text}</div></div></div>'
        for i, (title, text) in enumerate(NOTES, 1))
    body = f'''<div style="padding:48px;display:flex;flex-direction:column;gap:40px;background:#EEF0FA">
  <div style="display:flex;gap:40px;justify-content:center;align-items:flex-start">
    {column('ENSEIGNANTE · CONTENUS', teacher_phone())}
    {column('ÉLÈVE · COURS', pupil_cours('fr'))}
    {column('ÉLÈVE · UN DOCUMENT', pupil_document())}
  </div>
  <div style="display:flex;gap:40px;justify-content:center;align-items:flex-start">
    {column('ÉLÈVE · ARABE · الدروس', pupil_cours('ar'))}
    {column('PARENT · COURS', parent_cours())}
    <div style="width:390px;background:#fff;border:1px solid #E6E8F0;border-radius:24px;padding:26px;display:flex;flex-direction:column;gap:16px">
      <div style="font-size:22px;font-weight:800">Contenus, étape 1</div>
      <div style="font-size:14px;color:#6B7090;line-height:1.5">Importer, ranger, lire et partager des documents. Données inventées, mardi 6 octobre.</div>
      {notes}
    </div>
  </div>
</div>'''
    return page('Contenus sur téléphone', body, width=1440, height=2160)


if __name__ == '__main__':
    lib = library()
    (OUT / 'Contenus.html').write_text(teacher('Contenus', 'Contenus', lib))
    (OUT / 'Importer.html').write_text(teacher('Importer un document', 'Contenus', lib, import_panel()))
    (OUT / 'Partager.html').write_text(teacher('Partager', 'Contenus', lib, share_dialog()))
    (OUT / 'Document.html').write_text(viewer())
    (OUT / 'ContenusPhone.html').write_text(board())
    print('Contenus, Importer, Partager, Document, ContenusPhone')
