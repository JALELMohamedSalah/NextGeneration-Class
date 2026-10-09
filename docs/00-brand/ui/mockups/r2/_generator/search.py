"""Release 2: the search of the top bar ("Rechercher un élève, un contenu…", UI_DESIGN_SPEC AppTopBar)."""
from pathlib import Path

from contents import kind_badge, library, square  # also puts the R1 generator on the path

import common  # noqa: E402
from common import avatar, badge, chip, icon, page, sidebar  # noqa: E402
from scan import frame  # noqa: E402
from teacher_notifications import TEACHER_NAV, bell  # noqa: E402
from planning import phone  # noqa: E402

OUT = Path(__file__).resolve().parents[1]

common.ICONS.update({
    'corner': '<path d="M9 10 4 15l5 5"/><path d="M20 4v7a4 4 0 0 1-4 4H4"/>',
    'clipcheck': '<rect width="8" height="4" x="8" y="2" rx="1"/><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><path d="m9 14 2 2 4-4"/>',
})


def mark(text, q):
    """The typed letters in bold, as the results show them."""
    i = text.lower().find(q.lower())
    if i < 0:
        return text
    return f'{text[:i]}<b style="color:#1A1D3A;background:#FFF4DC;border-radius:3px">{text[i:i + len(q)]}</b>{text[i + len(q):]}'


def result(left, title, sub, active=False, q='frac'):
    bg = 'background:#EEF0FA;' if active else ''
    enter = f'<span class="cap" style="display:flex;align-items:center;gap:4px;color:#2B3990">{icon("corner", 14)}Entrée</span>' if active else ''
    return (f'<div style="display:flex;align-items:center;gap:12px;padding:9px 12px;border-radius:12px;{bg}">{left}'
            f'<div style="flex:1;min-width:0"><div style="font-size:14px;font-weight:700;color:#4A4F72">{mark(title, q)}</div>'
            f'<div class="s13" style="font-size:12px">{sub}</div></div>{enter}</div>')


def section(label):
    return f'<div class="cap" style="font-size:11px;letter-spacing:1px;text-transform:uppercase;padding:10px 12px 4px">{label}</div>'


def dropdown():
    return f'''<div style="position:absolute;top:66px;inset-inline-start:296px;width:560px;background:#fff;border:1px solid #E6E8F0;border-radius:18px;box-shadow:0 20px 50px rgba(28,37,102,.18);padding:8px;z-index:5">
  {section('Contenus')}
  {result(kind_badge('pdf', 34), 'Série 1 : les fractions', 'Série · Maths · 4ème année · Les fractions', active=True)}
  {result(kind_badge('pdf', 34), 'Leçon : les fractions simples', 'Cours · Maths · 4ème année · Les fractions')}
  {result(badge('folder', 'indigo', 34, 10, 17), 'Les fractions', 'Chapitre · Maths · 4ème année · 4 documents')}
  {section('Devoirs et évaluations')}
  {result(badge('clipboard', 'amber', 34, 10, 17), 'Série 1 : les fractions', 'Devoir · 4ème année · Maths · 1 à corriger')}
  {result(badge('clipcheck', 'violet', 34, 10, 17), 'Évaluation : les fractions', 'Évaluation · 4ème année · Maths · mercredi 7 octobre')}
  <div style="display:flex;align-items:center;gap:14px;padding:10px 12px 4px;border-top:1px solid #F0F1F6;margin-top:6px" class="s13">
    <span><b style="color:#4A4F72">↑ ↓</b> pour choisir</span><span><b style="color:#4A4F72">Entrée</b> pour ouvrir</span><span><b style="color:#4A4F72">Échap</b> pour fermer</span>
    <span style="flex:1"></span><span>Partout : <b style="color:#4A4F72">Ctrl K</b></span>
  </div>
</div>'''


def topbar(q):
    return f'''<div class="top">
  <div class="search" style="background:#fff;border:1.5px solid #2B3990;color:#1A1D3A;flex-basis:560px">{icon('search', 18, color='#2B3990')}<span style="flex:1">{q}<span style="display:inline-block;width:1.5px;height:18px;background:#2B3990;vertical-align:middle;margin-inline-start:1px"></span></span>{icon('x', 16, color='#6B7090')}</div>
  <div style="flex:1"></div>
  <span class="btn secondary" style="height:40px;padding:0 14px;font-size:13px;color:#4A4F72">FR · ع</span>
  {bell(44, 0)}
  <span class="btn primary">{icon('plus', 18, 2.4)}Créer</span>
</div>'''


def desktop():
    body = f'''<div class="app" style="min-height:900px">{sidebar('Contenus')}<div class="main">{topbar('frac')}{library()}</div></div>
<div style="position:absolute;inset:0;top:72px;inset-inline-start:264px;background:rgba(26,29,58,.08)"></div>{dropdown()}'''
    return page('Recherche', body)


# ── Phones ──

def phone_search(lang='fr'):
    fr = lang == 'fr'
    T = lambda f, a: f if fr else a  # noqa: E731
    q = 'ben' if fr else 'ben'
    arrow = f'<span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center;{"" if fr else "transform:scaleX(-1)"}">{icon("arrowleft", 20)}</span>'

    def row(left, title, sub):
        return (f'<div style="display:flex;align-items:center;gap:12px;padding:10px 4px">{left}<div style="flex:1;min-width:0">'
                f'<div style="font-size:15px;font-weight:700;color:#4A4F72"><bdi>{mark(title, q)}</bdi></div><div class="s13">{sub}</div></div></div>')
    body = f'''
  <div style="display:flex;align-items:center;gap:10px;padding:14px 16px;background:#fff;border-bottom:1px solid #E6E8F0">{arrow}
    <div class="input" style="flex:1;border:1.5px solid #2B3990;background:#fff;min-height:44px">{icon('search', 18, color='#2B3990')}<span style="flex:1">{q}</span>{icon('x', 16, color='#6B7090')}</div></div>
  <div style="flex:1;overflow:hidden;padding:6px 14px;display:flex;flex-direction:column">
    {section(T('Élèves', 'التلاميذ'))}
    {row(avatar('YB', 'amber', 38), 'Yassine Ben Ali', T('4ème année · 4ème année · Maths', '<bdi>4ème année · Maths</bdi> · السنة الرابعة'))}
    {row(avatar('MB', 'orange', 38), 'Malek Ben Ali', T('4ème année · 4ème année · Maths', '<bdi>4ème année · Maths</bdi> · السنة الرابعة'))}
    {row(avatar('SB', 'violet', 38), 'Sara Ben Amor', T('3ème année · cours particulier', 'السنة الثالثة · درس خصوصي'))}
    {section(T('Parents', 'الأولياء'))}
    {row(avatar('SB', 'indigo', 38), 'Sonia Ben Ali', T('Parent de Yassine et Malek · 22345671', 'وليّ <bdi>Yassine</bdi> و<bdi>Malek</bdi> · <span style="direction:ltr;display:inline-block">22345671</span>'))}
    {section(T('Groupes', 'المجموعات'))}
    {row(square('SB', 30), 'Sara Ben Amor · Lecture', T('Cours particulier · 1 élève', 'درس خصوصي · تلميذ واحد'))}
  </div>'''
    return frame(body, lang)


def phone_empty():
    body = f'''
  <div style="display:flex;align-items:center;gap:10px;padding:14px 16px;background:#fff;border-bottom:1px solid #E6E8F0"><span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center">{icon("arrowleft", 20)}</span>
    <div class="input" style="flex:1;border:1.5px solid #2B3990;background:#fff;min-height:44px">{icon('search', 18, color='#2B3990')}<span style="flex:1">géométrie</span>{icon('x', 16, color='#6B7090')}</div></div>
  <div style="flex:1;padding:16px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:12px;text-align:center">
    {badge('search', 'grey', 56, 16, 26)}
    <div style="font-size:16px;font-weight:800">Rien pour « géométrie »</div>
    <div class="s13" style="max-width:260px;line-height:1.5">Cherchez un élève (nom, identifiant, téléphone d'un parent), un groupe, un document, un chapitre, un devoir ou une évaluation.</div>
  </div>'''
    return frame(body)


def phone_header_search():
    return phone(f'''
    <div style="display:flex;align-items:center;gap:10px">
      <img src="../ng-symbol.png" style="height:26px" alt=""><span style="flex:1;font-family:'Plus Jakarta Sans';font-size:15px;font-weight:700;color:#2B3990">NG Class</span>
      <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center;background:#EEF0FA;border-color:#C9CEEC;color:#2B3990">{icon('search', 20)}</span>
      {bell(44, 0)}
      {avatar('IH', 'indigo', 40, True)}
    </div>
    <div><div class="s13" style="font-weight:600">Jeudi 8 octobre</div><div style="font-size:26px;font-weight:800;letter-spacing:-.5px">Bonjour Ines</div></div>
    <div class="note">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>Sur téléphone, la loupe à côté de la cloche ouvre la recherche en plein écran.</span></div>
    ''', TEACHER_NAV, 'fr', 0)


NOTES = [
    ('Où', 'Dans la barre du haut de l\'enseignante, à la place prévue par la maquette approuvée. Sur téléphone, une loupe à côté de la cloche ouvre la recherche en plein écran. Ctrl K (⌘ K sur Mac) la place sous le curseur depuis n\'importe quelle page.'),
    ('Ce qu\'elle trouve', 'Élèves (nom, prénom, identifiant, téléphone), parents (nom, téléphone : ils mènent à l\'enfant), groupes et cours particuliers, documents et chapitres de Contenus, devoirs et évaluations. Les archives n\'y sont pas.'),
    ('Comment', 'Dès deux lettres, sans tenir compte des accents ni des majuscules (« eleve » trouve « Élève »). Cinq résultats au plus par famille, les mieux placés d\'abord ; les lettres tapées en évidence.'),
    ('Ouvrir', 'Un clic ou Entrée ouvre la fiche de l\'élève, la page du groupe, le document, le devoir ou l\'évaluation. ↑ ↓ pour choisir, Échap pour fermer.'),
    ('Rien trouvé', '« Rien pour … » avec ce qu\'on peut chercher. Seul ce qui appartient à l\'enseignante connectée est cherché.'),
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
    {column('TÉLÉPHONE · LA LOUPE', phone_header_search())}
    {column('RÉSULTATS · « ben »', phone_search('fr'))}
    {column('ARABE · البحث', phone_search('ar'))}
  </div>
  <div style="display:flex;gap:40px;justify-content:center;align-items:flex-start">
    {column('RIEN TROUVÉ', phone_empty())}
    <div style="width:820px;background:#fff;border:1px solid #E6E8F0;border-radius:24px;padding:26px;display:flex;flex-direction:column;gap:16px">
      <div style="font-size:22px;font-weight:800">La recherche</div>
      <div style="font-size:14px;color:#6B7090;line-height:1.5">UI_DESIGN_SPEC « AppTopBar » (Search field, R2). Données inventées, jeudi 8 octobre.</div>
      {notes}
    </div>
  </div>
</div>'''
    return page('Recherche sur téléphone', body, width=1440, height=1900)


if __name__ == '__main__':
    (OUT / 'Recherche.html').write_text(desktop())
    (OUT / 'RecherchePhone.html').write_text(phone_board())
    print('Recherche, RecherchePhone')
