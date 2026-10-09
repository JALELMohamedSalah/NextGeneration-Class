"""Release 3, step 1: formulas, exercises and series built in the app (spec 05, client question Q3: default kept)."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'r2' / '_generator'))

from contents import kind_badge, square  # noqa: E402  (also puts the R1 generator on the path)

import common  # noqa: E402
from common import ACCENTS, avatar, badge, chip, icon, page, sidebar  # noqa: E402
from planning import phone  # noqa: E402
from scan import frame  # noqa: E402
from teacher_notifications import bell  # noqa: E402

OUT = Path(__file__).resolve().parents[1]

common.ICONS.update({
    'layers': '<path d="m12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.9a1 1 0 0 0 0-1.83Z"/><path d="m22 17.65-9.17 4.16a2 2 0 0 1-1.66 0L2 17.65M22 12.65l-9.17 4.16a2 2 0 0 1-1.66 0L2 12.65"/>',
    'grip': '<circle cx="9" cy="6" r="1"/><circle cx="9" cy="12" r="1"/><circle cx="9" cy="18" r="1"/><circle cx="15" cy="6" r="1"/><circle cx="15" cy="12" r="1"/><circle cx="15" cy="18" r="1"/>',
    'eye': '<path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>',
    'library': '<path d="m16 6 4 14M12 6v14M8 8v12M4 4v16"/>',
    'image': '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-3.09-3.09a2 2 0 0 0-2.82 0L6 21"/>',
    'check2': '<path d="M20 6 9 17l-5-5"/>',
    'sigma': '<path d="M18 7V4H6l6 8-6 8h12v-3"/>',
    'more': '<circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/>',
    'send': '<path d="m22 2-7 20-4-9-9-4Z"/><path d="M22 2 11 13"/>',
    'camera': '<path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"/><circle cx="12" cy="13" r="3"/>',
})

KATEX = '''<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/auto-render.min.js"
  onload="renderMathInElement(document.body,{delimiters:[{left:'$',right:'$',display:false}],ignoredClasses:['src']})"></script>
<style>.katex{font-size:1.08em}.src{font-family:'JetBrains Mono',Menlo,monospace;font-size:14px}</style>'''

DIFF = {'Facile': 'green', 'Moyen': 'amber', 'Difficile': 'red'}

EXERCISES = [  # statement (rendered), difficulty, points, corrected
    ('Calcule et simplifie : $\\dfrac{3}{4} + \\dfrac{1}{2}$ ; $\\dfrac{5}{6} - \\dfrac{1}{3}$ ; $\\dfrac{2}{5} \\times 10$.', 'Facile', 4, True),
    ('Compare $\\dfrac{3}{5}$ et $\\dfrac{4}{7}$. Écris le bon signe : $<$, $>$ ou $=$.', 'Moyen', 4, True),
    ('Ahmed a mangé $\\dfrac{2}{8}$ d\'une pizza et Lina $\\dfrac{3}{8}$. Quelle fraction de la pizza reste-t-il ?', 'Difficile', 4, False),
]


def topbar():
    return f'''<div class="top">
  <div style="flex:1"></div>
  <span class="btn secondary" style="height:40px;padding:0 14px;font-size:13px;color:#4A4F72">FR · ع</span>
  {bell(44, 0)}
  <span class="btn primary">{icon('plus', 18, 2.4)}Créer</span>
</div>'''


def screen(title, content, overlay='', height=900):
    body = f'''{KATEX}<div class="app" style="min-height:{height}px">{sidebar('Contenus')}<div class="main">{topbar()}{content}</div></div>{overlay}'''
    return page(title, body, height=height)


def exercise_card(n, statement, difficulty, points, corrected, first=False):
    return f'''<div style="display:flex;gap:12px;padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px;align-items:flex-start">
  <span style="color:#ADB1C6;padding-top:4px">{icon('grip', 18)}</span>
  <span style="width:30px;height:30px;border-radius:10px;background:#EEF0FA;color:#2B3990;font-weight:800;font-size:14px;display:flex;align-items:center;justify-content:center;flex-shrink:0">{n}</span>
  <div style="flex:1;min-width:0;display:flex;flex-direction:column;gap:8px">
    <div style="font-size:15px;line-height:1.7">{statement}</div>
    <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">{chip(difficulty, DIFF[difficulty])}<span class="chip" style="background:#F1F3F5;color:#4A4F72">{points} points</span>
      {chip('Corrigé', 'violet', dot=False) if corrected else '<span class="s13">Sans corrigé</span>'}</div>
  </div>
  <span class="btn ghost sm" style="width:36px;padding:0;justify-content:center">{icon('more', 18)}</span>
</div>'''


def sheet(scale=1.0):
    """The series as the pupils see it (and as the worksheet will print)."""
    items = ''.join(
        f'<div style="display:flex;gap:10px"><b style="color:#2B3990">Exercice {i}</b><span class="s13">· {p} points</span></div>'
        f'<div style="font-size:14px;line-height:1.75;margin:4px 0 14px">{s}</div>'
        for i, (s, _, p, _) in enumerate(EXERCISES, 1))
    return f'''<div style="background:#fff;border-radius:6px;box-shadow:0 10px 30px rgba(28,37,102,.14);padding:28px 30px;font-size:14px">
  <div style="display:flex;align-items:center;gap:10px;border-bottom:2px solid #2B3990;padding-bottom:10px;margin-bottom:16px">
    <img src="../ng-symbol.png" style="height:22px" alt=""><div style="flex:1"><div style="font-size:17px;font-weight:800">Série 3 : les fractions</div>
    <div class="s13">Mathématiques · 4ème année · Les fractions · 12 points</div></div></div>
  {items}
</div>'''


def series_page():
    cards = ''.join(exercise_card(i, s, d, p, c, i == 1) for i, (s, d, p, c) in enumerate(EXERCISES, 1))
    return f'''<main class="page" style="max-width:1240px">
  <div class="s13" style="color:#2B3990;font-weight:700;display:flex;align-items:center;gap:6px">{icon('arrowleft', 16)}Contenus</div>
  <div style="display:flex;align-items:flex-end;gap:12px;flex-wrap:wrap">
    <div style="flex:1;min-width:300px;display:flex;align-items:center;gap:14px">{badge('layers', 'turquoise', 52, 16, 24)}
      <div><h1 class="ptitle" style="font-size:32px">Nouvelle série</h1><div style="display:flex;gap:8px;margin-top:6px">{chip('Brouillon', 'grey')}<span class="s13">Enregistrée il y a 1 min</span></div></div></div>
    <span class="btn secondary">{icon('eye', 17)}Aperçu élève</span>
    <span class="btn primary">{icon('check2', 17)}Publier</span>
  </div>
  <div style="display:flex;gap:24px;align-items:flex-start">
    <div style="flex:7;display:flex;flex-direction:column;gap:16px">
      <section class="card" style="display:flex;flex-direction:column;gap:14px">
        <div class="field"><label>Titre</label><div class="input focus">Série 3 : les fractions</div></div>
        <div style="display:flex;gap:12px">
          <div class="field" style="flex:1"><label>Matière</label><div class="input" style="justify-content:space-between">Mathématiques{icon('chevdown', 18, color='#6B7090')}</div></div>
          <div class="field" style="flex:1"><label>Niveau</label><div class="input" style="justify-content:space-between">4ème année{icon('chevdown', 18, color='#6B7090')}</div></div>
          <div class="field" style="flex:1.3"><label>Chapitre</label><div class="input" style="justify-content:space-between">Les fractions{icon('chevdown', 18, color='#6B7090')}</div></div>
        </div>
      </section>
      <div style="display:flex;align-items:center;gap:10px">
        <div style="flex:1;font-size:18px;font-weight:800">Exercices <span class="count" style="background:#EEF0FA;color:#2B3990">3</span> <span class="s13" style="font-weight:600;margin-inline-start:6px">12 points en tout</span></div>
        <span class="btn secondary sm">{icon('library', 15)}Depuis la bibliothèque</span>
        <span class="btn tonal sm">{icon('plus', 15)}Nouvel exercice</span>
      </div>
      {cards}
    </div>
    <div style="flex:5;display:flex;flex-direction:column;gap:10px">
      <div class="cap" style="display:flex;align-items:center;gap:6px">{icon('eye', 15)}CE QUE VOIENT LES ÉLÈVES</div>
      {sheet()}
    </div>
  </div>
</main>'''


def series_screen():
    return screen('Nouvelle série', series_page(), height=1100)


# ── The exercise panel and its formula toolbar ──

TOOLS = [  # label (rendered), what it inserts
    ('<b>ƒx</b>', 'Formule'), ('$\\frac{a}{b}$', 'a/b'), ('$x^n$', 'x^n'), ('$x_1$', 'x_1'), ('$\\sqrt{x}$', 'sqrt(x)'),
    ('$\\sqrt[n]{x}$', 'root(n,x)'), ('$(\\,)$', '( )'), ('$\\le$', '<='), ('$\\ge$', '>='), ('$\\ne$', '!='),
    ('$\\times$', '*'), ('$\\div$', ':'), ('$\\pi$', 'pi'), ('$\\vec{AB}$', 'vec(AB)'), ('$\\widehat{ABC}$', 'angle(ABC)'),
    ('$^\\circ$', 'deg'), ('$\\begin{cases}\\cdot\\\\\\cdot\\end{cases}$', 'system'),
]


def toolbar(compact=False):
    tools = TOOLS[:9] if compact else TOOLS
    buttons = ''.join(
        f'<span title="{t}" style="min-width:{38 if i else 54}px;height:36px;padding:0 8px;border-radius:10px;background:{"#2B3990" if i == 0 else "#fff"};color:{"#fff" if i == 0 else "#1A1D3A"};'
        f'border:1px solid {"#2B3990" if i == 0 else "#E6E8F0"};display:flex;align-items:center;justify-content:center;font-size:13px">{label}</span>'
        for i, (label, t) in enumerate(tools))
    more = '<span style="min-width:38px;height:36px;border-radius:10px;background:#F6F7FB;border:1px solid #E6E8F0;display:flex;align-items:center;justify-content:center">' + icon('more', 16) + '</span>' if compact else ''
    return f'<div style="display:flex;gap:6px;flex-wrap:{"nowrap" if compact else "wrap"};overflow:hidden">{buttons}{more}</div>'


def formula_field(label, source, preview, hint=None, lang='fr'):
    d = ' dir="rtl"' if lang == 'ar' else ''
    hint_html = f'<div class="hint">{hint}</div>' if hint else ''
    return f'''<div class="field"{d}><label>{label}</label>
  {toolbar()}
  <div class="input focus src" style="min-height:74px;align-items:flex-start;padding-top:12px;line-height:1.6;white-space:pre-wrap">{source}<span style="display:inline-block;width:1.5px;height:17px;background:#2B3990;vertical-align:middle"></span></div>
  <div style="padding:12px 14px;border:1px dashed #C9CEEC;border-radius:14px;background:#FBFBFE">
    <div class="cap" style="font-size:11px;margin-bottom:4px">APERÇU</div>
    <div style="font-size:15px;line-height:1.75">{preview}</div></div>
  {hint_html}
</div>'''


def exercise_panel():
    seg = lambda items, on: '<div class="seg">' + ''.join(f'<span class="{"on" if i == on else ""}">{t}</span>' for i, t in enumerate(items)) + '</div>'  # noqa: E731
    return f'''<div class="scrim"></div>
<div class="panel" style="width:600px">
  <div class="panel-h">{badge('sigma', 'turquoise', 44, 14, 20)}<div style="flex:1"><div style="font-size:20px;font-weight:800">Nouvel exercice</div>
    <div class="s13">Il rejoint « Série 3 : les fractions » et la bibliothèque du chapitre.</div></div>{icon('x', 22, color='#6B7090')}</div>
  <div class="panel-b" style="gap:16px">
    {formula_field('Énoncé', 'Calcule et simplifie : $3/4 + 1/2$ ; $5/6 - 1/3$ ; $2/5 * 10$.',
                   'Calcule et simplifie : $\\dfrac{3}{4} + \\dfrac{1}{2}$ ; $\\dfrac{5}{6} - \\dfrac{1}{3}$ ; $\\dfrac{2}{5} \\times 10$.',
                   'Écrivez le texte normalement. ƒx ouvre une formule entre deux <span class="src" style="font-family:inherit;font-size:12px">$</span> : 3/4 devient une vraie fraction, * un ×, <= un ≤.')}
    <div style="display:flex;gap:12px">
      <div class="field" style="flex:1.4"><label>Difficulté</label>{seg(['Facile', 'Moyen', 'Difficile'], 0)}</div>
      <div class="field" style="flex:1"><label>Points</label><div class="input">4</div></div>
    </div>
    <div class="field"><label>Réponse attendue <span class="s13" style="font-weight:500">· facultatif</span></label><div class="input src">$5/4$ ; $1/2$ ; $4$</div></div>
    <div class="field"><label>Corrigé <span class="s13" style="font-weight:500">· facultatif · visible quand vous le partagez</span></label>
      <div class="input src" style="min-height:52px;align-items:flex-start;padding-top:12px;line-height:1.6">$3/4 + 1/2 = 3/4 + 2/4 = 5/4$</div>
      <div style="display:flex;gap:8px"><span class="btn secondary sm">{icon('image', 15)}Ajouter une image</span><span class="btn secondary sm">{icon('camera', 15)}Prendre en photo</span></div></div>
  </div>
  <div class="panel-f"><span class="btn ghost">Annuler</span><span class="btn primary">{icon('plus', 17)}Ajouter à la série</span></div>
</div>'''


def panel_screen():
    return screen('Nouvel exercice', series_page(), exercise_panel(), height=1100)


# ── Phones ──

def phone_editor():
    body = f'''
  <div style="display:flex;align-items:center;gap:12px;padding:14px 16px;background:#fff;border-bottom:1px solid #E6E8F0">
    <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center">{icon('x', 20)}</span>
    <div style="flex:1;font-size:17px;font-weight:800">Nouvel exercice</div><span class="btn primary sm">Ajouter</span></div>
  <div style="flex:1;overflow:hidden;padding:14px;display:flex;flex-direction:column;gap:12px">
    <div class="field"><label>Énoncé</label>
      <div class="input focus src" style="min-height:80px;align-items:flex-start;padding-top:10px;line-height:1.6">Compare $3/5$ et $4/7$. Écris le bon signe.</div>
      <div style="padding:10px 12px;border:1px dashed #C9CEEC;border-radius:14px;background:#FBFBFE;font-size:15px;line-height:1.7">Compare $\\dfrac{{3}}{{5}}$ et $\\dfrac{{4}}{{7}}$. Écris le bon signe.</div></div>
    <div style="display:flex;gap:10px"><div class="field" style="flex:1"><label>Difficulté</label><div class="input" style="justify-content:space-between">Moyen{icon('chevdown', 16, color='#6B7090')}</div></div>
      <div class="field" style="width:96px"><label>Points</label><div class="input">4</div></div></div>
  </div>
  <div style="padding:8px 10px;background:#F6F7FB;border-top:1px solid #E6E8F0">{toolbar(compact=True)}</div>
  <div style="height:200px;background:#D1D5DB;display:grid;grid-template-columns:repeat(10,1fr);gap:5px;padding:8px">{''.join(f'<span style="background:#fff;border-radius:5px;display:flex;align-items:center;justify-content:center;font-size:15px">{k}</span>' for k in 'azertyuiopqsdfghjklmwxcvbn,.')}</div>'''
    return frame(body).replace('{{', '{').replace('}}', '}')


def pupil_series(lang='fr'):
    fr = lang == 'fr'
    if fr:
        title, sub, ex = 'Série 3 : les fractions', 'Maths · 4ème année · 12 points', EXERCISES[:2]
        items = ''.join(
            f'<div style="padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px"><div style="display:flex;gap:8px;align-items:center"><b style="color:#2B3990;font-size:15px">Exercice {i}</b><span class="s13">{p} points</span></div>'
            f'<div style="font-size:16px;line-height:1.8;margin-top:6px">{s}</div></div>' for i, (s, _, p, _) in enumerate(ex, 1))
    else:
        title, sub = 'السلسلة 3: الكسور', 'رياضيات · السنة الرابعة · 12 نقطة'
        items = ('<div style="padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px"><div style="display:flex;gap:8px;align-items:center"><b style="color:#2B3990;font-size:15px">التمرين 1</b><span class="s13">4 نقاط</span></div>'
                 '<div style="font-size:16px;line-height:1.8;margin-top:6px">أحسب ثمّ اختزل: <span dir="ltr">$\\dfrac{3}{4} + \\dfrac{1}{2}$</span> ؛ <span dir="ltr">$\\dfrac{5}{6} - \\dfrac{1}{3}$</span></div></div>'
                 '<div style="padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px"><div style="display:flex;gap:8px;align-items:center"><b style="color:#2B3990;font-size:15px">التمرين 2</b><span class="s13">4 نقاط</span></div>'
                 '<div style="font-size:16px;line-height:1.8;margin-top:6px">قارن <span dir="ltr">$\\dfrac{3}{5}$</span> و<span dir="ltr">$\\dfrac{4}{7}$</span>. اكتب العلامة المناسبة: <span dir="ltr">$<$</span> أو <span dir="ltr">$>$</span> أو <span dir="ltr">$=$</span>.</div></div>')
    arrow = f'<span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center;{"" if fr else "transform:scaleX(-1)"}">{icon("arrowleft", 20)}</span>'
    body = f'''
  <div style="display:flex;align-items:center;gap:12px;padding:16px 18px;background:#fff;border-bottom:1px solid #E6E8F0">{arrow}
    <div style="flex:1;min-width:0"><div style="font-size:17px;font-weight:800">{title}</div><div class="s13">{sub}</div></div>{kind_badge('pdf', 36) if False else badge('layers', 'turquoise', 36, 10, 18)}</div>
  <div style="flex:1;overflow:hidden;padding:14px;display:flex;flex-direction:column;gap:10px">{items}</div>'''
    return frame(body, lang)


NOTES = [
    ('Écrire une formule sans LaTeX', 'Le texte s\'écrit normalement. ƒx ouvre une formule entre deux $ ; dedans, 3/4 devient une vraie fraction, x^2 un carré, sqrt(2) une racine, * un ×, : un ÷, <= ≤, >= ≥, != ≠, pi π. Les boutons insèrent chaque modèle (fraction, puissance, indice, racines, parenthèses, signes, vecteur, angle, degré, système). Un aperçu sous le champ montre le rendu final à chaque lettre. Le LaTeX est aussi accepté pour qui le connaît.'),
    ('Arabe', 'Un énoncé peut être en arabe : le texte se lit de droite à gauche, chaque formule garde son sens de lecture.'),
    ('Un exercice', 'Énoncé, image facultative (fichier ou photo), difficulté Facile, Moyen ou Difficile, points (4 par défaut), réponse attendue facultative, corrigé facultatif (texte avec formules, image ou fichier). Chaque exercice reste dans la bibliothèque du chapitre et sert dans d\'autres séries.'),
    ('Une série', 'Créer › Série (le bouton disait « bientôt ») ou Contenus › « Nouvelle série » : titre, matière, niveau, chapitre, puis les exercices dans l\'ordre (glisser pour changer). « Depuis la bibliothèque » reprend des exercices déjà écrits. Le total des points se calcule seul. À droite, ce que verront les élèves.'),
    ('Brouillon et publication', 'Enregistrée à chaque changement, en brouillon. « Publier » la met dans Contenus comme un document « Série » : on la partage avec un groupe et on la donne en devoir comme avant (les élèves envoient la photo de leur travail).'),
    ('Élèves et parents', 'La série s\'ouvre dans l\'application, formules comprises (Cours et Devoirs), en français ou en arabe. Le PDF à imprimer viendra avec les fiches (étape 4).'),
    ('Ensuite (R3)', 'Étape 2 : quiz et QCM (5 types de questions, saisie rapide). Étape 3 : les élèves passent les quiz, correction automatique. Étape 4 : fiches PDF élève et enseignante.'),
]


def phone_board():
    def column(label, content):
        return f'<div style="display:flex;flex-direction:column;gap:14px;align-items:center"><div class="cap" style="font-size:13px">{label}</div>{content}</div>'
    notes = ''.join(
        f'<div style="display:flex;gap:12px"><span style="width:26px;height:26px;border-radius:13px;background:#2B3990;color:#fff;font-size:13px;font-weight:800;display:flex;align-items:center;justify-content:center;flex-shrink:0">{i}</span>'
        f'<div><div style="font-size:15px;font-weight:800">{title}</div><div style="font-size:14px;color:#4A4F72;line-height:1.5;margin-top:2px">{text}</div></div></div>'
        for i, (title, text) in enumerate(NOTES, 1))
    body = f'''{KATEX}<div style="padding:48px;display:flex;flex-direction:column;gap:40px;background:#EEF0FA">
  <div style="display:flex;gap:40px;justify-content:center;align-items:flex-start">
    {column('ENSEIGNANTE · TÉLÉPHONE', phone_editor())}
    {column('ÉLÈVE · LA SÉRIE', pupil_series('fr'))}
    {column('ARABE · السلسلة', pupil_series('ar'))}
  </div>
  <div style="background:#fff;border:1px solid #E6E8F0;border-radius:24px;padding:26px;display:flex;flex-direction:column;gap:16px;max-width:1260px;margin:0 auto">
    <div style="font-size:22px;font-weight:800">Version 3, étape 1 : formules, exercices et séries</div>
    <div style="font-size:14px;color:#6B7090;line-height:1.5">Spec 05 « Builders ». Question client Q3 (formules) : réponse recommandée retenue, un éditeur avec des boutons. Données inventées, jeudi 8 octobre.</div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px 32px">{notes}</div>
  </div>
</div>'''
    return page('Séries sur téléphone', body, width=1440, height=1800)


if __name__ == '__main__':
    (OUT / 'SerieEditeur.html').write_text(series_screen())
    (OUT / 'ExerciceEditeur.html').write_text(panel_screen())
    (OUT / 'SeriesPhone.html').write_text(phone_board())
    print('SerieEditeur, ExerciceEditeur, SeriesPhone')
