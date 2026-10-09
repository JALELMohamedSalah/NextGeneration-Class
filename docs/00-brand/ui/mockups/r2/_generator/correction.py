"""Release 2, step 4: correction (spec 06), grades and Résultats (spec 07, 09, 10)."""
from pathlib import Path

from contents import kind_badge, phone_header, square  # also puts the R1 generator on the path

import common  # noqa: E402
from common import avatar, badge, chip, icon, page, teacher  # noqa: E402
from homework import STATUS  # noqa: E402
from planning import phone  # noqa: E402
from scan import frame  # noqa: E402

OUT = Path(__file__).resolve().parents[1]

common.ICONS.update({
    'arrowright': '<path d="M5 12h14M12 5l7 7-7 7"/>',
    'minus': '<path d="M5 12h14"/>',
    'trendup': '<path d="m22 7-8.5 8.5-5-5L2 17"/><path d="M16 7h6v6"/>',
    'pentool': '<path d="M12 19l7-7 3 3-7 7-3-3z"/><path d="M18 13l-1.5-7.5L2 2l3.5 14.5L13 18l5-5z"/><path d="m2 2 7.586 7.586"/><circle cx="11" cy="11" r="2"/>',
})
STATUS['corrected'] = ('Corrigé', 'violet')

HAND = "font-family:'Caveat',cursive;color:#1F3A93"
FONT = '<link href="https://fonts.googleapis.com/css2?family=Caveat:wght@500;600&display=swap" rel="stylesheet">'


def notebook(scale=1.0, lines=None, blank=0):
    """A page of a pupil's notebook, photographed straight: ruled lines, a red margin, blue pen."""
    lines = lines or [
        ('Vendredi 3 octobre', 'end'),
        ('Série 1 : les fractions', 'title'),
        ('Exercice 1', 'sub'),
        ('a)  3/4 + 1/4 = 4/4 = 1', ''),
        ('b)  2/5 + 1/5 = 3/5', ''),
        ('Exercice 2', 'sub'),
        ('6/8 = 3/4      9/12 = 3/4', ''),
        ('Exercice 3', 'sub'),
        ('1/2 + 1/4 = 2/4 + 1/4 = 3/4', ''),
        ('2/3 + 1/6 = 4/6 + 1/6 = 5/6', ''),
    ]
    lines = lines + [('', '')] * blank
    step = int(30 * scale)
    rows = ''
    for text, kind in lines:
        size = {'title': 30, 'sub': 25}.get(kind, 25) * scale
        weight = 600 if kind in ('title', 'sub') else 500
        align = 'text-align:end;' if kind == 'end' else ''
        deco = 'text-decoration:underline;' if kind in ('title', 'sub') else ''
        rows += f'<div style="height:{step}px;line-height:{step}px;font-size:{size}px;font-weight:{weight};{align}{deco}">{text}</div>'
    return (f'<div style="background:#FFFDF7;border-radius:4px;box-shadow:0 10px 30px rgba(28,37,102,.18);'
            f'padding:{int(36 * scale)}px {int(32 * scale)}px {int(60 * scale)}px {int(78 * scale)}px;position:relative;{HAND};direction:ltr;'
            f'background-image:repeating-linear-gradient(#FFFDF7 0 {step - 1}px,#BFD3EE {step - 1}px {step}px);background-position:0 {int(36 * scale) - 1}px">'
            f'<span style="position:absolute;top:0;bottom:0;left:{int(58 * scale)}px;width:2px;background:#E8A0A0"></span>{rows}</div>')


# ── Teacher, desktop ──

def queue_page():
    def row(initials, accent, name, when, status, first=False):
        label, acc = STATUS[status]
        return f'''<div class="row" style="padding:12px 0;{"border-top:none" if first else ""}">
  {avatar(initials, accent)}<div style="flex:1;font-size:15px;font-weight:700">{name}</div>
  <div style="width:170px">{chip(label, acc)}</div>
  <div style="width:190px" class="s13">{when}</div>
  <span class="btn tonal sm">Corriger</span>
</div>'''

    def group(kind, title, grp, grp_name, deadline, rows, count):
        return f'''<section class="card" style="padding:20px 24px 8px">
  <div style="display:flex;align-items:center;gap:14px;padding-bottom:12px;border-bottom:1px solid #F0F1F6">
    {kind_badge(kind)}
    <div style="flex:1"><div class="t15" style="font-size:17px">{title}</div>
      <div class="s13" style="display:flex;align-items:center;gap:6px;margin-top:3px">{square(grp, 20)}<span>{grp_name}</span><span>·</span><span>{deadline}</span></div></div>
    <span class="count" style="background:#FFF4DC;color:#9A6300">{count} à corriger</span>
    <span class="btn primary sm">{icon('pentool', 15)}Corriger</span>
  </div>
  {rows}
</section>'''

    fractions = (row('SB', 'blue', 'Sami Ben Salah', 'Rendu jeu. 2 oct., 19:40', 'done', True)
                 + row('OS', 'turquoise', 'Omar Saidi', 'Rendu ven. 3 oct., 15:05', 'done')
                 + row('AG', 'indigo', 'Adam Gharbi', 'Rendu ven. 3 oct., 17:12', 'done')
                 + row('AK', 'amber', 'Amine Kefi', 'Rendu sam. 4 oct., 09:30', 'late'))
    lecture = row('LB', 'violet', 'Lina Bouzid', 'Rendu hier, 18:20', 'done', True)
    return f'''<main class="page" style="max-width:1176px">
  <div style="display:flex;align-items:flex-end;gap:12px">
    <div style="flex:1"><h1 class="ptitle">Devoirs</h1>
      <div style="font-size:15px;color:#4A4F72;margin-top:6px">Ce que vos élèves ont à faire, et qui l'a rendu.</div></div>
    <span class="btn primary">{icon('plus', 18, 2.4)}Nouveau devoir</span>
  </div>
  <div style="display:flex;gap:12px;align-items:center">
    <div class="tabs"><span class="on">À corriger <span class="count" style="background:#fff;color:#2B3990">5</span></span><span>En cours <span class="count" style="background:#F1F3F5;color:#6B7090">2</span></span><span>Terminés <span class="count" style="background:#F1F3F5;color:#6B7090">12</span></span></div>
    <span style="flex:1"></span>
    <span class="btn secondary sm">{icon('filter', 15)}Groupe : tous</span>
    <span class="btn secondary sm">{icon('filter', 15)}Matière : toutes</span>
  </div>
  {group('pdf', 'Série 1 : les fractions', '4A', '4ème année · Maths', 'date limite vendredi 3 octobre', fractions, 4)}
  {group('pdf', 'Lecture : le corbeau et le renard', '4L', '4ème année · Lecture', 'date limite hier, 18:00', lecture, 1)}
  <div class="note">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>Chaque travail envoyé arrive ici, le plus ancien en premier. La note et le commentaire sont visibles par l'élève et ses parents dès l'enregistrement.</span></div>
</main>'''


def correction_page():
    phrases = ''.join(f'<span class="chip" style="background:#fff;border:1px solid #E6E8F0;color:#4A4F72;font-size:13px;padding:6px 12px">{p}</span>'
                      for p in ['Très bien !', 'Bon travail', 'Revois la leçon', 'Soigne l\'écriture'])
    choice = lambda ic, acc, title: (f'<div style="flex:1;display:flex;align-items:center;gap:10px;padding:12px;border:1.5px dashed #9AA3D9;background:#F4F5FC;border-radius:14px">'  # noqa: E731
                                     f'{badge(ic, acc, 34, 10, 17)}<span style="font-size:14px;font-weight:700">{title}</span></div>')
    body = f'''{FONT}
<div style="display:flex;flex-direction:column;height:900px;background:#E9EBF3">
  <div style="height:72px;flex-shrink:0;display:flex;align-items:center;gap:14px;padding:0 24px;background:#fff;border-bottom:1px solid #E6E8F0">
    <span class="btn secondary" style="width:44px;padding:0;justify-content:center">{icon('arrowleft', 20)}</span>
    <div style="flex:1"><div style="font-size:18px;font-weight:800">Série 1 : les fractions</div><div class="s13">4ème année · Maths · date limite vendredi 3 octobre</div></div>
    <span class="btn secondary" style="width:44px;padding:0;justify-content:center">{icon('chevleft', 20)}</span>
    <div style="font-size:14px;font-weight:700;width:110px;text-align:center">Copie 2 sur 4</div>
    <span class="btn secondary" style="width:44px;padding:0;justify-content:center">{icon('chevright', 20)}</span>
  </div>
  <div style="flex:1;display:flex;min-height:0">
    <div style="flex:1;display:flex;flex-direction:column;align-items:center;padding:28px 40px 0;gap:16px;overflow:hidden">
      <div style="width:540px">{notebook(0.92, blank=8)}</div>
      <div style="display:flex;align-items:center;gap:10px;padding:6px;background:#fff;border:1px solid #E6E8F0;border-radius:14px;box-shadow:0 6px 20px rgba(28,37,102,.10)">
        <span class="btn ghost sm" style="width:38px;padding:0;justify-content:center">{icon('chevleft', 18)}</span><span style="font-size:14px;font-weight:700;width:96px;text-align:center">Page 1 sur 2</span><span class="btn ghost sm" style="width:38px;padding:0;justify-content:center">{icon('chevright', 18)}</span>
        <span style="width:1px;height:24px;background:#E6E8F0"></span>
        <span class="btn ghost sm" style="width:38px;padding:0;justify-content:center">{icon('minus', 18)}</span><span class="btn ghost sm" style="width:38px;padding:0;justify-content:center">{icon('plus', 18)}</span>
      </div>
    </div>
    <div style="width:460px;background:#fff;border-inline-start:1px solid #E6E8F0;display:flex;flex-direction:column">
      <div style="flex:1;padding:24px;display:flex;flex-direction:column;gap:20px">
        <div style="display:flex;align-items:center;gap:12px">{avatar('OS', 'turquoise', 44)}<div style="flex:1"><div style="font-size:17px;font-weight:800">Omar Saidi</div><div class="s13">Rendu vendredi 3 octobre à 15:05 · 2 pages</div></div>{chip('Rendu', 'green')}</div>
        <div class="field"><label>Note</label>
          <div style="display:flex;align-items:center;gap:12px"><div class="input focus" style="width:120px;font-size:24px;font-weight:800;justify-content:center;height:60px">16</div><span style="font-size:22px;font-weight:800;color:#6B7090">/ 20</span></div>
          <div class="hint">Un nombre de 0 à 20, demi-points acceptés : 14,5.</div></div>
        <div class="field"><label>Commentaire <span class="s13" style="font-weight:500">· facultatif · visible par l'élève et ses parents</span></label>
          <div class="input" style="min-height:92px;align-items:flex-start;padding-top:12px;line-height:1.5">Très bon travail. Dans l'exercice 3, pense à simplifier ta réponse quand c'est possible.</div>
          <div style="display:flex;flex-wrap:wrap;gap:8px">{phrases}</div></div>
        <div class="field"><label>Copie corrigée <span class="s13" style="font-weight:500">· facultatif</span></label>
          <div style="display:flex;gap:10px">{choice('camera', 'turquoise', 'Prendre en photo')}{choice('folder', 'indigo', 'Choisir un fichier')}</div></div>
      </div>
      <div style="padding:14px 24px 18px;border-top:1px solid #E6E8F0;display:flex;flex-direction:column;gap:10px">
        <div class="s13" style="text-align:end">Copie suivante : Adam Gharbi</div>
        <div style="display:flex;gap:10px;justify-content:flex-end"><span class="btn secondary">Enregistrer</span>
        <span class="btn primary">Enregistrer et suivant{icon('arrowright', 17)}</span></div>
      </div>
    </div>
  </div>
</div>'''
    return page('Corriger', body)


def detail_page():
    def tile(label, value, accent):
        strong, soft, on = common.ACCENTS[accent]
        return (f'<div style="flex:1;padding:16px 18px;border-radius:20px;background:#fff;border:1px solid #E6E8F0;display:flex;align-items:center;gap:14px">'
                f'<span style="width:12px;height:40px;border-radius:6px;background:{strong}"></span>'
                f'<div><div style="font-size:28px;font-weight:800;line-height:1">{value}</div><div class="s13" style="margin-top:4px">{label}</div></div></div>')

    def row(initials, accent, name, status, when, grade='', first=False):
        label, acc = STATUS[status]
        action = {'corrected': f'<span class="btn secondary sm">{icon("eye", 15)}Voir</span>',
                  'done': '<span class="btn tonal sm">Corriger</span>', 'late': '<span class="btn tonal sm">Corriger</span>',
                  'missing': f'<span class="btn ghost sm">{icon("pencil", 14)}Noter</span>'}[status]
        mark = f'<span style="font-size:15px;font-weight:800">{grade}</span><span class="s13"> / 20</span>' if grade else '<span class="s13">—</span>'
        return f'''<div class="row" style="padding:12px 0;{"border-top:none" if first else ""}">
  {avatar(initials, accent)}<div style="flex:1;font-size:15px;font-weight:700">{name}</div>
  <div style="width:160px">{chip(label, acc)}</div>
  <div style="width:160px" class="s13">{when}</div>
  <div style="width:90px">{mark}</div>
  <div style="width:120px;display:flex;justify-content:flex-end">{action}</div>
</div>'''

    rows = (row('AG', 'indigo', 'Adam Gharbi', 'corrected', 'Ven. 3 oct., 17:12', '14', True)
            + row('AK', 'amber', 'Amine Kefi', 'late', 'Sam. 4 oct., 09:30')
            + row('OS', 'turquoise', 'Omar Saidi', 'corrected', 'Ven. 3 oct., 15:05', '16')
            + row('RM', 'violet', 'Rayen Mansour', 'missing', '')
            + row('SB', 'blue', 'Sami Ben Salah', 'corrected', 'Jeu. 2 oct., 19:40', '12,5')
            + row('YT', 'orange', 'Yasmine Trabelsi', 'done', 'Ven. 3 oct., 16:58'))
    return f'''<main class="page" style="max-width:1176px">
  <div style="display:flex;align-items:center;gap:8px" class="s13"><span>Devoirs</span>{icon('chevright', 14)}<span>Terminés</span></div>
  <div style="display:flex;align-items:flex-start;gap:14px">
    {kind_badge('pdf', 52)}
    <div style="flex:1"><h1 class="ptitle" style="font-size:30px">Série 1 : les fractions</h1>
      <div style="display:flex;align-items:center;gap:8px;margin-top:8px;font-size:14px;color:#4A4F72">{square('4A', 22)}<span>4ème année · Maths</span><span>·</span>{icon('calclock', 16)}<span>Pour le vendredi 3 octobre à 18:00</span><span>·</span><span>Moyenne 14,17 / 20</span></div></div>
    <span class="btn primary">{icon('pentool', 17)}Corriger (2)</span>
    <span class="btn secondary">{icon('calendar', 17)}Changer la date</span>
    <span class="btn secondary">{icon('lockkeyhole', 17)}Clore</span>
  </div>
  <div style="display:flex;gap:12px">{tile('Corrigés', 3, 'violet')}{tile('À corriger', 2, 'green')}{tile('Manquants', 1, 'red')}{tile('À faire', 0, 'blue')}</div>
  <section class="card" style="padding:8px 24px">
    <div style="display:flex;gap:14px;padding:14px 0 10px;border-bottom:1px solid #F0F1F6" class="cap">
      <span style="width:40px"></span><span style="flex:1">ÉLÈVE</span><span style="width:160px">STATUT</span><span style="width:160px">RENDU LE</span><span style="width:90px">NOTE</span><span style="width:120px"></span>
    </div>
    {rows}
  </section>
  <div class="note">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>« Noter » un élève sans rendu : une copie rendue sur papier, par exemple. Un devoir sans note ne compte jamais comme 0 dans la moyenne.</span></div>
</main>'''


# ── Phones ──

PUPIL_NAV = [('house', 'Accueil'), ('book', 'Cours'), ('clipboard', 'Devoirs'), ('calendar', 'Planning'), ('chart', 'Résultats')]


def teacher_phone():
    body = f'''{FONT}
  <div style="display:flex;align-items:center;gap:12px;padding:16px 18px;background:#fff;border-bottom:1px solid #E6E8F0">
    <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center">{icon('arrowleft', 20)}</span>
    <div style="flex:1;min-width:0"><div style="font-size:16px;font-weight:800">Série 1 : les fractions</div><div class="s13">Copie 2 sur 4</div></div>
    <span class="btn secondary" style="width:40px;height:40px;padding:0;justify-content:center">{icon('chevleft', 18)}</span>
    <span class="btn secondary" style="width:40px;height:40px;padding:0;justify-content:center">{icon('chevright', 18)}</span>
  </div>
  <div style="height:300px;overflow:hidden;background:#E9EBF3;padding:16px 30px 0;position:relative">{notebook(0.6)}
    <span class="chip" style="position:absolute;bottom:12px;inset-inline-end:14px;background:#1A1D3A;color:#fff">Page 1 sur 2</span></div>
  <div style="flex:1;padding:16px 18px;display:flex;flex-direction:column;gap:14px;background:#fff;border-radius:24px 24px 0 0;margin-top:-18px;position:relative;box-shadow:0 -8px 24px rgba(28,37,102,.08)">
    <div style="display:flex;align-items:center;gap:10px">{avatar('OS', 'turquoise', 40)}<div style="flex:1"><div style="font-size:16px;font-weight:800">Omar Saidi</div><div class="s13">Rendu vendredi, 15:05</div></div>{chip('Rendu', 'green')}</div>
    <div style="display:flex;align-items:center;gap:10px"><div class="input focus" style="width:96px;font-size:22px;font-weight:800;justify-content:center;height:56px">16</div><span style="font-size:20px;font-weight:800;color:#6B7090">/ 20</span></div>
    <div class="input" style="min-height:74px;align-items:flex-start;padding-top:10px;font-size:14px;line-height:1.45">Très bon travail. Dans l'exercice 3, pense à simplifier ta réponse.</div>
    <div style="display:flex;gap:8px;flex-wrap:wrap">{''.join(f'<span class="chip" style="background:#fff;border:1px solid #E6E8F0;color:#4A4F72">{p}</span>' for p in ['Très bien !', 'Bon travail', 'Revois la leçon'])}</div>
    <div class="s13" style="display:flex;align-items:center;gap:8px">{icon('camera', 16)}Ajouter la copie corrigée · facultatif</div>
  </div>
  <div style="padding:12px 18px 18px;background:#fff;border-top:1px solid #E6E8F0"><span class="btn primary" style="height:52px;justify-content:center;width:100%">Enregistrer et suivant{icon('arrowright', 17)}</span></div>'''
    return frame(body)


def pupil_corrected():
    body = f'''
  <div style="display:flex;align-items:center;gap:12px;padding:16px 18px;background:#fff;border-bottom:1px solid #E6E8F0">
    <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center">{icon('arrowleft', 20)}</span>
    <div style="flex:1;min-width:0"><div style="font-size:17px;font-weight:800">Série 1 : les fractions</div><div class="s13">Maths · 4ème année</div></div>
    {chip('Corrigé', 'violet')}</div>
  <div style="flex:1;overflow:hidden;padding:16px 18px;display:flex;flex-direction:column;gap:12px">
    <div style="padding:18px;background:#fff;border:1px solid #E6E8F0;border-radius:20px;display:flex;flex-direction:column;gap:14px">
      <div style="display:flex;align-items:center;gap:14px">
        <div style="width:96px;height:96px;border-radius:24px;background:#F1ECFD;display:flex;flex-direction:column;align-items:center;justify-content:center;direction:ltr">
          <span style="font-size:36px;font-weight:800;color:#5B34D6;line-height:1">14</span><span style="font-size:14px;font-weight:700;color:#5B34D6">/ 20</span></div>
        <div style="flex:1"><div style="font-size:18px;font-weight:800">Bien joué, Adam !</div><div class="s13" style="margin-top:2px">Corrigé mercredi 7 octobre</div></div></div>
      <div style="display:flex;gap:10px;padding:12px;background:#F6F7FB;border-radius:14px">{avatar('IH', 'indigo', 32, True)}
        <div><div class="cap" style="font-size:11px">MOT DE L'ENSEIGNANTE</div><div style="font-size:15px;line-height:1.5;margin-top:3px">Bon travail ! Revois la simplification des fractions avant jeudi.</div></div></div>
    </div>
    <div style="display:flex;align-items:center;gap:12px;padding:12px 14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px">{badge('pentool', 'violet', 40, 12, 18)}<div style="flex:1"><div style="font-size:15px;font-weight:700">Copie corrigée</div><div class="s13">1 page</div></div><span class="btn tonal sm">Ouvrir</span></div>
    <div style="display:flex;align-items:center;gap:12px;padding:12px 14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px">{kind_badge('pdf', 40)}<div style="flex:1"><div style="font-size:15px;font-weight:700">Mon travail</div><div class="s13">2 pages · vendredi 3 octobre, 17:12</div></div><span class="btn tonal sm">Ouvrir</span></div>
    <div style="display:flex;align-items:center;gap:12px;padding:12px 14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px">{kind_badge('pdf', 40)}<div style="flex:1"><div style="font-size:15px;font-weight:700">Série 1 : les fractions</div><div class="s13">Série · 2 pages</div></div><span class="btn tonal sm">Ouvrir</span></div>
  </div>'''
    return frame(body)


def results(lang='fr'):
    fr = lang == 'fr'
    T = lambda f, a: f if fr else a  # noqa: E731

    def grade_row(title, date, mark, comment=None, first=False):
        com = f'<div style="font-size:13px;color:#4A4F72;line-height:1.45;margin-top:4px">« {comment} »</div>' if comment and fr else (
            f'<div style="font-size:13px;color:#4A4F72;line-height:1.45;margin-top:4px"><bdi>{comment}</bdi></div>' if comment else '')
        return (f'<div style="display:flex;gap:12px;padding:12px 0;{"" if first else "border-top:1px solid #F0F1F6"}">'
                f'<div style="flex:1;min-width:0"><div style="font-size:15px;font-weight:700"><bdi>{title}</bdi></div><div class="s13">{date}</div>{com}</div>'
                f'<div style="direction:ltr;white-space:nowrap"><span style="font-size:17px;font-weight:800">{mark}</span><span class="s13"> /20</span></div></div>')

    maths = f'''<div style="padding:16px;background:#fff;border:1px solid #E6E8F0;border-radius:20px">
    <div style="display:flex;align-items:center;gap:8px"><span style="width:10px;height:10px;border-radius:3px;background:#2B3990"></span><span class="cap" style="flex:1;letter-spacing:1px;color:#4A4F72">{T('MATHÉMATIQUES', 'الرياضيات')}</span>{chip(T('En progrès', 'في تحسّن'), 'green', dot=False)}</div>
    <div style="display:flex;align-items:baseline;gap:6px;margin-top:10px;direction:ltr;justify-content:{'flex-start' if fr else 'flex-end'}"><span style="font-size:40px;font-weight:800;letter-spacing:-1px">15,25</span><span style="font-size:16px;font-weight:700;color:#6B7090">/20</span></div>
    <div class="s13">{T('Moyenne de 4 notes', 'المعدّل من 4 أعداد')}</div>
    <div style="display:flex;gap:8px;margin-top:12px">
      <div style="flex:1;padding:10px;background:#F6F7FB;border-radius:12px"><div style="font-size:15px;font-weight:800">{T('3 sur 4', '3 من 4')}</div><div class="s13" style="font-size:12px">{T('devoirs rendus', 'واجبات مُرسلة')}</div></div>
      <div style="flex:1;padding:10px;background:#F6F7FB;border-radius:12px"><div style="font-size:15px;font-weight:800;direction:ltr;text-align:{'left' if fr else 'right'}">95 %</div><div class="s13" style="font-size:12px">{T('présence', 'الحضور')}</div></div></div>
    <div class="cap" style="margin-top:14px;font-size:11px;letter-spacing:1px">{T('NOTES', 'الأعداد')}</div>
    {grade_row('Série 1 : les fractions', T('vendredi 3 octobre', 'الجمعة 3 أكتوبر'), '14', T('Bon travail ! Revois la simplification des fractions avant jeudi.', 'Bon travail ! Revois la simplification des fractions avant jeudi.'), True)}
    {grade_row('Table de 7', T('lundi 29 septembre', 'الاثنين 29 سبتمبر'), '16')}
    {grade_row('Série 0 : révisions', T('jeudi 25 septembre', 'الخميس 25 سبتمبر'), '15,5')}
  </div>'''
    lecture = f'''<div style="padding:16px;background:#fff;border:1px solid #E6E8F0;border-radius:20px">
    <div style="display:flex;align-items:center;gap:8px"><span style="width:10px;height:10px;border-radius:3px;background:#12A39A"></span><span class="cap" style="flex:1;letter-spacing:1px;color:#4A4F72">{T('LECTURE', 'القراءة')}</span></div>
    <div style="font-size:16px;font-weight:700;margin-top:8px">{T('Pas encore de note.', 'لا يوجد عدد بعد.')}</div><div class="s13">{T('1 devoir rendu sur 1 · présence 100 %', 'واجب واحد مُرسل من 1 · الحضور 100 %')}</div></div>'''
    if fr:
        return phone(f'''
    {phone_header('AG')}
    <div><div style="font-size:26px;font-weight:800;letter-spacing:-.5px">Mes résultats</div><div style="font-size:15px;color:#4A4F72;margin-top:4px">Tes notes et ton travail, matière par matière.</div></div>
    {maths}{lecture}''', PUPIL_NAV, 'fr', 4)
    top = f'''<div style="display:flex;align-items:center;gap:12px">
      <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center;transform:scaleX(-1)">{icon('arrowleft', 20)}</span>
      <div style="flex:1"><div style="font-size:24px;font-weight:800">نتائج <bdi>Adam</bdi></div><div style="font-size:14px;color:#4A4F72;margin-top:2px">أعداده وعمله، مادّة بمادّة.</div></div></div>'''
    return phone(f'{top}{maths}{lecture}',
                 [('dashboard', 'نظرة عامة'), ('book', 'الدروس'), ('clipboard', 'الواجبات'), ('calendar', 'الجدول'), ('bell', 'الإشعارات')], 'ar', 0)


NOTES = [
    ('À corriger', 'Un nouvel onglet de Devoirs, en premier : chaque travail envoyé, groupé par devoir, le plus ancien en premier. Filtres groupe et matière. « Corriger » ouvre la première copie.'),
    ('L\'écran de correction', 'La copie à gauche (pages, zoom), à droite la note sur 20 (demi-points acceptés), un commentaire avec des phrases rapides, et la copie corrigée en photo ou en fichier si vous le voulez. « Enregistrer et suivant » ouvre la copie suivante du même devoir, sans revenir à la liste.'),
    ('Visible tout de suite', 'À l\'enregistrement, l\'élève et ses parents voient la note et le commentaire, avec une notification « Devoir corrigé ». Un travail corrigé ne peut plus être remplacé. Vous pouvez changer la note ensuite (« Voir »).'),
    ('Sans rendu', '« Noter » un élève Manquant : une copie sur papier, ou 0 si vous le décidez. Un devoir sans note ne compte jamais comme 0.'),
    ('Résultats (élève)', 'Un cinquième onglet : par matière la moyenne sur 20 (sans coefficients), « En progrès » ou « En baisse » à partir de 4 notes, les devoirs rendus, la présence, et chaque note avec le mot de l\'enseignante. « Pas encore de note » au lieu de 0.'),
    ('Parents', 'Les cartes Moyenne, Devoirs et Dernière note de l\'Aperçu (maquette approuvée) se remplissent et ouvrent les résultats de l\'enfant (ici en arabe).'),
    ('Ma journée', '« À corriger » et « Travail manquant » se remplissent comme sur la maquette approuvée de Ma journée ; un clic ouvre la copie à corriger.'),
    ('Ensuite', 'Les évaluations sur papier (+ Évaluation, notes du groupe au clavier) et « Relancer » avec les notifications sur le téléphone.'),
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
    {column('ENSEIGNANTE · CORRIGER', teacher_phone())}
    {column('ÉLÈVE · DEVOIR CORRIGÉ', pupil_corrected())}
    {column('ÉLÈVE · RÉSULTATS', results('fr'))}
  </div>
  <div style="display:flex;gap:40px;justify-content:center;align-items:flex-start">
    {column('PARENT · ARABE · النتائج', results('ar'))}
    <div style="width:820px;background:#fff;border:1px solid #E6E8F0;border-radius:24px;padding:26px;display:flex;flex-direction:column;gap:16px">
      <div style="font-size:22px;font-weight:800">Correction et résultats, étape 4</div>
      <div style="font-size:14px;color:#6B7090;line-height:1.5">Spec 06 (correction), 07 (notes), 09 et 10 (élève, parent). Données inventées, mercredi 7 octobre.</div>
      {notes}
    </div>
  </div>
</div>'''
    return page('Correction sur téléphone', body, width=1440, height=2000)


if __name__ == '__main__':
    (OUT / 'ACorriger.html').write_text(teacher('À corriger', 'Devoirs', queue_page(), height=1000))
    (OUT / 'Corriger.html').write_text(correction_page())
    (OUT / 'DevoirNotes.html').write_text(teacher('Devoir', 'Devoirs', detail_page()))
    (OUT / 'CorrectionPhone.html').write_text(phone_board())
    print('ACorriger, Corriger, DevoirNotes, CorrectionPhone')
