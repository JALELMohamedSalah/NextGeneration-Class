"""Release 2, step 3: homework (spec 06): give a document with a deadline, pupils send photos, "Manquant"."""
from pathlib import Path

from contents import kind_badge, phone_header, square  # also puts the R1 generator on the path

import common  # noqa: E402
from common import avatar, badge, chip, icon, page, teacher  # noqa: E402
from planning import phone  # noqa: E402
from scan import frame  # noqa: E402

OUT = Path(__file__).resolve().parents[1]

common.ICONS.update({
    'send': '<path d="m22 2-7 20-4-9-9-4Z"/><path d="M22 2 11 13"/>',
    'calclock': '<path d="M21 7.5V6a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h3.5M16 2v4M8 2v4M3 10h5"/><circle cx="16" cy="16" r="6"/><path d="M16 14v2l1 1"/>',
    'eye': '<path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>',
    'lockkeyhole': '<rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>',
    'camera': '<path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"/><circle cx="12" cy="13" r="3"/>',
})

STATUS = {  # label, accent
    'todo': ('À faire', 'blue'), 'done': ('Rendu', 'green'), 'late': ('Rendu en retard', 'amber'),
    'missing': ('Manquant', 'red'), 'read': ('À lire', 'grey'),
}


def progress(done, late, missing, total):
    """A bar: rendus in green, late in amber, missing in red, the rest to do."""
    seg = lambda n, color: f'<span style="flex:{n};background:{color}"></span>' if n else ''  # noqa: E731
    rest = total - done - late - missing
    return (f'<div style="display:flex;height:8px;border-radius:4px;overflow:hidden;background:#EEF0F6;gap:2px">'
            f'{seg(done, "#2F9E44")}{seg(late, "#FFB020")}{seg(missing, "#E03131")}{seg(rest, "#E6E8F0")}</div>')


def list_page():
    def row(title, kind, group, deadline, deadline_note, counts, total, mode='file', first=False, urgent=False):
        done, late, missing = counts
        if mode == 'read':
            facts = f'<div style="display:flex;align-items:center;gap:8px;width:220px">{chip("Rien à rendre", "grey", dot=False)}<span class="s13">{total} élève</span></div>'
        else:
            parts = [f'{done + late} rendus sur {total}'] + ([f'{late} en retard'] if late else []) + ([f'{missing} manquant'] if missing else [])
            facts = f'<div style="display:flex;flex-direction:column;gap:6px;width:220px">{progress(done, late, missing, total)}<span class="s13">{" · ".join(parts)}</span></div>'
        return f'''<div class="row" style="padding:16px 0;{"border-top:none" if first else ""}">
  {kind_badge(kind)}
  <div style="flex:1;min-width:0"><div class="t15">{title}</div><div class="s13" style="display:flex;align-items:center;gap:6px;margin-top:3px">{group}</div></div>
  <div style="width:190px"><div style="font-size:14px;font-weight:700;color:{"#B5440A" if urgent else "#1A1D3A"}">{deadline}</div><div class="s13">{deadline_note}</div></div>
  {facts}
  <span style="color:#6B7090">{icon('more', 20)}</span>
</div>'''

    g4a = f'{square("4A", 22)}<span>4ème année · Maths</span>'
    g4l = f'{square("4L", 22)}<span>4ème année · Lecture</span>'
    gag = f'<span class="av" style="width:22px;height:22px;background:#7048E8;color:#fff;font-size:10px;border-radius:7px">AG</span><span>Adam Gharbi · Maths</span>'
    rows = (row('Lecture : le corbeau et le renard', 'pdf', g4l, 'Demain, 18:00', 'mercredi 8 octobre', (2, 0, 0), 5, first=True, urgent=True)
            + row('Série 2 : les fractions', 'pdf', g4a, 'Jeudi 9 oct., 18:00', 'dans 2 jours', (3, 0, 0), 6)
            + row('Table de 7', 'pdf', gag, 'Lundi 13 oct.', 'à lire avant la séance', (0, 0, 0), 1, mode='read'))
    return f'''<main class="page" style="max-width:1176px">
  <div style="display:flex;align-items:flex-end;gap:12px">
    <div style="flex:1"><h1 class="ptitle">Devoirs</h1>
      <div style="font-size:15px;color:#4A4F72;margin-top:6px">Ce que vos élèves ont à faire, et qui l'a rendu.</div></div>
    <span class="btn primary">{icon('plus', 18, 2.4)}Nouveau devoir</span>
  </div>
  <div style="display:flex;gap:12px;align-items:center">
    <div class="tabs"><span class="on">En cours <span class="count" style="background:#fff;color:#2B3990">3</span></span><span>Terminés <span class="count" style="background:#F1F3F5;color:#6B7090">12</span></span></div>
    <span style="flex:1"></span>
    <span class="btn secondary sm">{icon('filter', 15)}Groupe : tous</span>
  </div>
  <section class="card" style="padding:8px 24px">
    <div style="display:flex;gap:14px;padding:14px 0 10px;border-bottom:1px solid #F0F1F6" class="cap">
      <span style="width:40px"></span><span style="flex:1">DEVOIR</span><span style="width:190px">POUR LE</span><span style="width:220px">RENDUS</span><span style="width:20px"></span>
    </div>
    {rows}
  </section>
  <div class="note">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>Après la date limite, un devoir non rendu passe en « Manquant » tout seul. Les élèves et leurs parents voient chaque nouveau devoir dans leurs notifications.</span></div>
</main>'''


def assign_panel():
    seg = lambda items, on: '<div class="seg">' + ''.join(f'<span class="{"on" if i == on else ""}">{t}</span>' for i, t in enumerate(items)) + '</div>'  # noqa: E731
    return f'''<div class="scrim"></div>
<div class="panel">
  <div class="panel-h">{badge('clipboard', 'indigo', 44, 14, 20)}<div style="flex:1"><div style="font-size:20px;font-weight:800">Nouveau devoir</div>
    <div class="s13">Un document de la bibliothèque, pour un groupe ou quelques élèves, avec une date limite.</div></div>{icon('x', 22, color='#6B7090')}</div>
  <div class="panel-b" style="gap:15px">
    <div class="field"><label>Document</label>
      <div class="input" style="justify-content:space-between;padding:8px 12px"><span style="display:flex;align-items:center;gap:10px">{kind_badge('pdf', 34)}<span><span style="font-weight:700">Série 2 : les fractions</span><br><span class="s13" style="font-size:12px">Maths · 4ème année · Les fractions</span></span></span>{icon('chevdown', 18, color='#6B7090')}</div></div>
    <div class="field"><label>Titre</label><div class="input focus">Série 2 : les fractions</div><div class="hint">Pris du document. Les élèves voient ce titre.</div></div>
    <div class="field"><label>Pour</label>{seg(['Un groupe', 'Des élèves'], 0)}
      <div class="input" style="justify-content:space-between"><span style="display:flex;align-items:center;gap:10px">{square('4A')}4ème année · Maths · 6 élèves</span>{icon('chevdown', 18, color='#6B7090')}</div></div>
    <div style="display:flex;gap:12px">
      <div class="field" style="flex:1"><label>Date limite</label><div class="input" style="justify-content:space-between">Jeu. 9 oct. 2026{icon('calendar', 18, color='#6B7090')}</div></div>
      <div class="field" style="width:140px"><label>Heure</label><div class="input" style="justify-content:space-between">18:00{icon('clock', 18, color='#6B7090')}</div></div>
    </div>
    <div class="field"><label>Rendu</label>{seg(['Photos ou PDF', 'Rien à rendre'], 0)}<div class="hint">Les élèves prennent leur cahier en photo : les pages deviennent un seul PDF.</div></div>
    <div class="field"><label>Consignes <span class="s13" style="font-weight:500">· facultatif</span></label><div class="input" style="min-height:70px;align-items:flex-start;padding-top:12px;color:#6B7090">Ex. : Fais les exercices 1 à 3 sur ton cahier.</div></div>
    <div style="display:flex;align-items:center;gap:12px;padding:12px 14px;border:1px solid #E6E8F0;border-radius:14px">
      <div style="flex:1"><div style="font-size:14px;font-weight:700">Accepter les rendus en retard</div><div class="s13">Ils sont marqués « Rendu en retard ».</div></div>
      <span style="width:46px;height:28px;border-radius:14px;background:#DDE0EA;position:relative"><span style="position:absolute;top:3px;inset-inline-start:3px;width:22px;height:22px;border-radius:11px;background:#fff;box-shadow:0 1px 3px rgba(0,0,0,.2)"></span></span>
    </div>
  </div>
  <div class="panel-f"><span class="btn ghost">Annuler</span><span class="btn primary">{icon('send', 17)}Donner le devoir</span></div>
</div>'''


def detail_page():
    def tile(label, value, accent):
        strong, soft, on = common.ACCENTS[accent]
        return (f'<div style="flex:1;padding:16px 18px;border-radius:20px;background:#fff;border:1px solid #E6E8F0;display:flex;align-items:center;gap:14px">'
                f'<span style="width:12px;height:40px;border-radius:6px;background:{strong}"></span>'
                f'<div><div style="font-size:28px;font-weight:800;line-height:1">{value}</div><div class="s13" style="margin-top:4px">{label}</div></div></div>')

    def row(initials, accent, name, status, when, first=False):
        label, acc = STATUS[status]
        action = (f'<span class="btn secondary sm">{icon("eye", 15)}Voir le rendu</span>' if status in ('done', 'late')
                  else '<span class="s13" style="width:126px">Rien reçu</span>' if status == 'missing' else '<span style="width:126px"></span>')
        return f'''<div class="row" style="padding:12px 0;{"border-top:none" if first else ""}">
  {avatar(initials, accent)}<div style="flex:1;font-size:15px;font-weight:700">{name}</div>
  <div style="width:170px">{chip(label, acc)}</div>
  <div style="width:170px" class="s13">{when}</div>
  <div style="width:140px;display:flex;justify-content:flex-end">{action}</div>
</div>'''

    rows = (row('AG', 'indigo', 'Adam Gharbi', 'done', 'Ven. 3 oct., 17:12', True)
            + row('AK', 'amber', 'Amine Kefi', 'late', 'Sam. 4 oct., 09:30')
            + row('OS', 'turquoise', 'Omar Saidi', 'done', 'Ven. 3 oct., 15:05')
            + row('RM', 'violet', 'Rayen Mansour', 'missing', '')
            + row('SB', 'blue', 'Sami Ben Salah', 'done', 'Jeu. 2 oct., 19:40')
            + row('YT', 'orange', 'Yasmine Trabelsi', 'done', 'Ven. 3 oct., 16:58'))
    return f'''<main class="page" style="max-width:1176px">
  <div style="display:flex;align-items:center;gap:8px" class="s13"><span>Devoirs</span>{icon('chevright', 14)}<span>Terminés</span></div>
  <div style="display:flex;align-items:flex-start;gap:14px">
    {kind_badge('pdf', 52)}
    <div style="flex:1"><h1 class="ptitle" style="font-size:30px">Série 1 : les fractions</h1>
      <div style="display:flex;align-items:center;gap:8px;margin-top:8px;font-size:14px;color:#4A4F72">{square('4A', 22)}<span>4ème année · Maths</span><span>·</span>{icon('calclock', 16)}<span>Pour le vendredi 3 octobre, 18:00</span><span>·</span><span>Retard accepté</span></div></div>
    <span class="btn secondary">{icon('calendar', 17)}Changer la date</span>
    <span class="btn secondary">{icon('lockkeyhole', 17)}Clore</span>
  </div>
  <div style="display:flex;gap:14px">{tile('Rendus', 4, 'green')}{tile('Rendus en retard', 1, 'amber')}{tile('Manquants', 1, 'red')}{tile('À faire', 0, 'blue')}</div>
  <section class="card" style="padding:8px 24px">
    <div style="display:flex;gap:14px;padding:14px 0 10px;border-bottom:1px solid #F0F1F6" class="cap">
      <span style="width:40px"></span><span style="flex:1">ÉLÈVE</span><span style="width:170px">STATUT</span><span style="width:170px">RENDU LE</span><span style="width:140px"></span>
    </div>
    {rows}
  </section>
  <div class="note">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>« Voir le rendu » ouvre le PDF de l'élève. La correction, la note sur 20 et le commentaire arrivent à l'étape suivante.</span></div>
</main>'''


# ── Phones ──

PUPIL_NAV = [('house', 'Accueil'), ('book', 'Cours'), ('clipboard', 'Devoirs'), ('calendar', 'Planning')]


def hw_card(title, sub, when, status, urgent=False, lang='fr'):
    label, acc = STATUS[status]
    color = '#B5440A' if urgent else '#4A4F72'
    return (f'<div style="display:flex;gap:12px;padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px">'
            f'{kind_badge("pdf", 44)}<div style="flex:1;min-width:0"><div style="font-size:16px;font-weight:700">{title}</div>'
            f'<div style="font-size:14px;color:#6B7090;margin-top:2px">{sub}</div>'
            f'<div style="display:flex;align-items:center;gap:6px;margin-top:8px;font-size:14px;font-weight:700;color:{color}">{icon("calclock", 16)}{when}</div></div>'
            f'<div>{chip(label, acc)}</div></div>')


def pupil_list():
    return phone(f'''
    {phone_header('AG')}
    <div><div style="font-size:26px;font-weight:800;letter-spacing:-.5px">Mes devoirs</div><div style="font-size:15px;color:#4A4F72;margin-top:4px">Ce que tu as à faire, le plus pressé en premier.</div></div>
    <div class="cap" style="font-size:12px;letter-spacing:1px;color:#2B3990">À FAIRE · 3</div>
    {hw_card('Lecture : le corbeau et le renard', 'Lecture', 'Pour demain, 18:00', 'todo', urgent=True)}
    {hw_card('Série 2 : les fractions', 'Maths', 'Pour jeudi, 18:00', 'todo')}
    {hw_card('Table de 7', 'Maths · rien à rendre', 'À lire avant lundi', 'read')}
    <div class="cap" style="font-size:12px;letter-spacing:1px">RENDUS</div>
    {hw_card('Série 1 : les fractions', 'Maths', 'Rendu vendredi, 17:12', 'done')}
    ''', PUPIL_NAV, 'fr', 2)


def pupil_homework(sent=False):
    top = f'''<div style="display:flex;align-items:center;gap:12px;padding:16px 18px;background:#fff;border-bottom:1px solid #E6E8F0">
    <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center">{icon('arrowleft', 20)}</span>
    <div style="flex:1;min-width:0"><div style="font-size:17px;font-weight:800">Série 2 : les fractions</div><div class="s13">Maths · 4ème année</div></div>
    {chip('Rendu', 'green') if sent else chip('À faire', 'blue')}</div>'''
    deadline = f'''<div style="display:flex;align-items:center;gap:12px;padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px">
    {badge('calclock', 'amber', 44, 14, 20)}<div><div style="font-size:16px;font-weight:800">Pour jeudi 9 octobre, 18:00</div><div class="s13">dans 2 jours</div></div></div>'''
    consignes = '''<div style="padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px"><div class="cap" style="margin-bottom:6px">CONSIGNES</div>
    <div style="font-size:15px;line-height:1.5">Fais les exercices 1 à 3 sur ton cahier, puis envoie une photo de chaque page.</div></div>'''
    document = f'''<div style="display:flex;align-items:center;gap:12px;padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px">
    {kind_badge('pdf', 44)}<div style="flex:1"><div style="font-size:15px;font-weight:700">Série 2 : les fractions</div><div class="s13">Série · 3 pages</div></div><span class="btn tonal sm">Ouvrir</span></div>'''
    if sent:
        work = f'''<div style="padding:14px;background:#E7F6EA;border:1px solid #BFE5C7;border-radius:18px;display:flex;flex-direction:column;gap:10px">
      <div style="display:flex;align-items:center;gap:10px">{icon('circlecheck', 22, color='#237A35')}<div style="font-size:16px;font-weight:800;color:#237A35">C'est envoyé !</div></div>
      <div style="display:flex;align-items:center;gap:12px;padding:10px;background:#fff;border-radius:14px">{kind_badge('pdf', 40)}<div style="flex:1"><div style="font-size:15px;font-weight:700">Mon travail</div><div class="s13">2 pages · mardi 7 octobre, 16:40</div></div><span class="btn ghost sm" style="color:#2B3990">Voir</span></div>
      <div style="font-size:14px;color:#237A35">Tu peux le remplacer jusqu'à jeudi 18:00.</div></div>'''
        button = f'<span class="btn secondary" style="height:52px;justify-content:center">{icon("camera", 18)}Remplacer mon travail</span>'
    else:
        work = f'''<div style="padding:16px;border:1.5px dashed #9AA3D9;background:#F4F5FC;border-radius:18px;display:flex;align-items:center;gap:12px">
      {badge('camera', 'turquoise', 48, 14, 22)}<div><div style="font-size:16px;font-weight:800;color:#0B6E68">Ton travail</div><div class="s13">Une photo par page de ton cahier : elles deviennent un seul PDF.</div></div></div>'''
        button = f'<span class="btn primary" style="height:52px;justify-content:center">{icon("camera", 18)}Prendre mon travail en photo</span>'
    body = f'''{top}
  <div style="flex:1;overflow:hidden;padding:16px 18px;display:flex;flex-direction:column;gap:12px">{deadline}{consignes}{document}{work}</div>
  <div style="padding:14px 18px 18px;background:#fff;border-top:1px solid #E6E8F0;display:flex;flex-direction:column">{button}</div>'''
    return frame(body)


def parent_list():
    def card(title, sub, when, status_ar, accent, urgent=False):
        strong, soft, on = common.ACCENTS[accent]
        return (f'<div style="display:flex;gap:12px;padding:14px;background:#fff;border:1px solid #E6E8F0;border-radius:18px">'
                f'{kind_badge("pdf", 44)}<div style="flex:1;min-width:0"><div style="font-size:16px;font-weight:700"><bdi>{title}</bdi></div>'
                f'<div style="font-size:14px;color:#6B7090;margin-top:2px">{sub}</div>'
                f'<div style="display:flex;align-items:center;gap:6px;margin-top:8px;font-size:14px;font-weight:700;color:{"#B5440A" if urgent else "#4A4F72"}">{icon("calclock", 16)}{when}</div></div>'
                f'<div><span class="chip" style="background:{soft};color:{on}"><span class="dot" style="background:{strong}"></span>{status_ar}</span></div></div>')

    return phone(f'''
    {phone_header('MG', 'turquoise')}
    <div><div style="font-size:26px;font-weight:800">واجبات <bdi>Adam</bdi></div><div style="font-size:15px;color:#4A4F72;margin-top:4px">ما على <bdi>Adam</bdi> إنجازه وما أرسله.</div></div>
    {card('Lecture : le corbeau et le renard', 'القراءة', 'لغدٍ، 18:00', 'للإنجاز', 'blue', urgent=True)}
    {card('Série 2 : les fractions', 'الرياضيات', 'ليوم الخميس، 18:00', 'للإنجاز', 'blue')}
    {card('Série 1 : les fractions', 'الرياضيات', 'أُرسل يوم الجمعة، 17:12', 'أُرسل', 'green')}
    <div class="note" style="background:#fff;border:1px solid #E6E8F0">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>ليس لـ<bdi>Adam</bdi> حساب خاص: يمكنك تصوير عمله وإرساله من هنا.</span></div>
    ''', [('dashboard', 'نظرة عامة'), ('book', 'الدروس'), ('clipboard', 'الواجبات'), ('calendar', 'الجدول'), ('bell', 'الإشعارات')], 'ar', 2)


NOTES = [
    ('Donner un devoir', 'Depuis « Devoirs » (Nouveau devoir) ou depuis un document de Contenus (« Donner en devoir »). Un document publié, pour un groupe ou quelques élèves d\'un groupe, avec une date et une heure limites.'),
    ('Deux façons de rendre', '« Photos ou PDF » : l\'élève prend son cahier en photo avec le même scanner que l\'enseignante, les pages deviennent un seul PDF. « Rien à rendre » : un document à lire, sans statut. Les quiz en ligne viennent avec la version 3.'),
    ('Les statuts', 'À faire, Rendu, Rendu en retard (seulement si le retard est accepté), Manquant (tout seul après la date limite). L\'élève peut remplacer son travail jusqu\'à la date limite.'),
    ('Pour l\'enseignante', 'La liste « En cours » et « Terminés » avec l\'avancement de chaque devoir ; le détail montre chaque élève, son statut, l\'heure du rendu et « Voir le rendu ». Changer la date limite, clore un devoir.'),
    ('Prévenus', 'Un nouveau devoir arrive dans les notifications de l\'élève et de ses parents.'),
    ('Parent (proposition)', 'La plupart des élèves n\'ont pas de compte : le parent voit les devoirs de son enfant et peut envoyer son travail en photo à sa place.'),
    ('Ensuite', 'La correction (« À corriger », note sur 20, commentaire), les Résultats et « Travail manquant » sur Ma journée viennent à l\'étape suivante.'),
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
    {column('ÉLÈVE · MES DEVOIRS', pupil_list())}
    {column('ÉLÈVE · UN DEVOIR', pupil_homework())}
    {column('ÉLÈVE · TRAVAIL ENVOYÉ', pupil_homework(sent=True))}
  </div>
  <div style="display:flex;gap:40px;justify-content:center;align-items:flex-start">
    {column('PARENT · ARABE · الواجبات', parent_list())}
    <div style="width:820px;background:#fff;border:1px solid #E6E8F0;border-radius:24px;padding:26px;display:flex;flex-direction:column;gap:16px">
      <div style="font-size:22px;font-weight:800">Devoirs, étape 3</div>
      <div style="font-size:14px;color:#6B7090;line-height:1.5">Spec 06, sans la correction (étape suivante). Données inventées, mardi 7 octobre.</div>
      {notes}
    </div>
  </div>
</div>'''
    return page('Devoirs sur téléphone', body, width=1440, height=1960)


if __name__ == '__main__':
    listing = list_page()
    (OUT / 'Devoirs.html').write_text(teacher('Devoirs', 'Devoirs', listing))
    (OUT / 'NouveauDevoir.html').write_text(teacher('Nouveau devoir', 'Devoirs', listing, assign_panel()))
    (OUT / 'Devoir.html').write_text(teacher('Devoir', 'Devoirs', detail_page()))
    (OUT / 'DevoirsPhone.html').write_text(phone_board())
    print('Devoirs, NouveauDevoir, Devoir, DevoirsPhone')
