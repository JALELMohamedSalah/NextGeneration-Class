"""Release 2: the teacher's notifications (spec 08). What the pupils and parents did: work sent, deadlines passed."""
from pathlib import Path

from contents import square  # also puts the R1 generator on the path

import common  # noqa: E402
from common import ACCENTS, avatar, icon, page, sidebar  # noqa: E402
from correction import queue_page  # noqa: E402
from planning import phone  # noqa: E402
from scan import frame  # noqa: E402

OUT = Path(__file__).resolve().parents[1]

common.ICONS.update({
    'inbox': '<path d="M22 12h-6l-2 3h-4l-2-3H2"/><path d="M5.45 5.11 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z"/>',
    'calx': '<path d="M8 2v4M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18M10 14l4 4M14 14l-4 4"/>',
    'calok': '<path d="M8 2v4M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18M9 16l2 2 4-4"/>',
})

KIND = {'sent': ('inbox', 'green'), 'missing': ('calx', 'red'), 'allsent': ('calok', 'turquoise')}

TEACHER_NAV = [('calcheck', 'Ma journée'), ('calendar', 'Planning'), ('users', 'Élèves'), ('folder', 'Contenus'), ('more', 'Plus')]


def kind_badge(kind, size=40):
    name, accent = KIND[kind]
    _, soft, on = ACCENTS[accent]
    return (f'<span class="badge" style="width:{size}px;height:{size}px;border-radius:12px;background:{soft};color:{on}">'
            f'{icon(name, 19)}</span>')


def count_badge(n):
    return (f'<span style="position:absolute;top:-6px;inset-inline-end:-6px;min-width:20px;height:20px;padding:0 5px;border-radius:10px;'
            f'background:#FFB020;border:2px solid #fff;color:#1A1D3A;font-size:10px;font-weight:800;display:flex;align-items:center;justify-content:center;direction:ltr">{n}</span>')


def bell(size=44, n=3, on=False):
    style = 'background:#EEF0FA;border-color:#C9CEEC;color:#2B3990' if on else 'color:#4A4F72'
    return (f'<span class="btn secondary" style="width:{size}px;height:{size}px;padding:0;justify-content:center;position:relative;{style}">'
            f'{icon("bell", 20)}{count_badge(n) if n else ""}</span>')


def line(text, color='#4A4F72', weight=500):
    return f'<div style="font-size:13px;line-height:1.45;color:{color};font-weight:{weight}">{text}</div>'


def notification(kind, title, lines, when, unread=False, action=None, late=None):
    """One row, as in the families' list (R1): what happened, the homework, who, when, and a shortcut."""
    tint = 'background:#F4F5FC;border-color:#DCE0F5' if unread else 'background:#fff'
    dot = '<span style="width:9px;height:9px;border-radius:5px;background:#2B3990;flex-shrink:0;margin-top:6px"></span>' if unread else ''
    tag = (f'<span class="chip" style="background:#FFF4DC;color:#9A6300;padding:3px 9px">{late}</span>' if late else '')
    button = f'<span class="btn tonal sm" style="height:34px;align-self:flex-start;margin-top:4px">{action}</span>' if action else ''
    return f'''<div style="display:flex;gap:12px;padding:14px;border:1px solid #E6E8F0;border-radius:18px;{tint}">
  {kind_badge(kind)}
  <div style="flex:1;min-width:0;display:flex;flex-direction:column;gap:4px">
    <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap"><span class="t15" style="font-weight:{800 if unread else 700}">{title}</span>{tag}</div>
    {lines}
    <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap"><span class="cap" style="font-weight:600;margin-top:2px;flex:1">{when}</span>{button}</div>
  </div>
  {dot}
</div>'''


def section(label):
    return f'<div class="cap" style="font-size:12px;letter-spacing:1px;text-transform:uppercase;margin-top:2px">{label}</div>'


def rows_fr(compact=False):
    group = (lambda code, name: name) if compact else (lambda code, name: f'<span style="display:inline-flex;align-items:center;gap:6px;vertical-align:middle">{square(code, 18)}{name}</span>')
    return f'''{section("Aujourd'hui")}
    {notification('sent', '3 travaux rendus', line('Série 2 : les fractions', '#1A1D3A', 700) + line(f'Adam, Sara et Omar · {group("4A", "4ème année · Maths")}'), 'Il y a 10 min', True, 'Corriger')}
    {notification('sent', '1 travail rendu', line('Série 1 : les fractions', '#1A1D3A', 700) + line(f'Amine Kefi · {group("4A", "4ème année · Maths")}'), 'Il y a 1 h', True, 'Corriger', late='En retard')}
    {notification('missing', 'Date limite passée', line('Lecture : le corbeau et le renard', '#1A1D3A', 700) + line('2 manquants : Rayen Mansour, Lina Bouzid', '#B42525', 600) + line(group('4L', '4ème année · Lecture')), 'Aujourd\'hui à 08:00', True, 'Voir')}
    {section('Plus tôt')}
    {notification('allsent', 'Date limite passée', line('Table de 7', '#1A1D3A', 700) + line('Tout le monde a rendu', '#237A35', 600) + line(group('4A', '4ème année · Maths')), 'Lundi 5 octobre')}
    {notification('sent', '5 travaux rendus', line('Série 1 : les fractions', '#1A1D3A', 700) + line(f'Sami, Omar, Adam et 2 autres · {group("4A", "4ème année · Maths")}'), 'Vendredi 3 octobre')}'''


# ── Desktop: the bell in the top bar opens a side panel over any page ──

def topbar():
    return f'''<div class="top">
  <div style="flex:1"></div>
  <span class="btn secondary" style="height:40px;padding:0 14px;font-size:13px;color:#4A4F72">FR · ع</span>
  {bell(44, 3, on=True)}
  <span class="btn primary">{icon('plus', 18, 2.4)}Créer</span>
</div>'''


def panel():
    return f'''<div class="scrim"></div>
<div class="panel" style="width:480px">
  <div class="panel-h">{kind_badge_bell()}<div style="flex:1"><div style="font-size:20px;font-weight:800">Notifications</div>
    <div class="s13">3 non lues</div></div><a style="font-size:13px;font-weight:700">Tout marquer comme lu</a>{icon('x', 22, color='#6B7090')}</div>
  <div class="panel-b" style="gap:12px;padding:20px 24px">
    {rows_fr()}
  </div>
</div>'''


def kind_badge_bell():
    return (f'<span class="badge" style="width:44px;height:44px;border-radius:14px;background:#EEF0FA;color:#2B3990">{icon("bell", 20)}</span>')


def desktop():
    body = f'''<div class="app" style="min-height:900px">{sidebar('Devoirs')}<div class="main">{topbar()}{queue_page()}</div></div>{panel()}'''
    return page('Notifications enseignante', body)


# ── Phones ──

def header_with_bell():
    return f'''<div style="display:flex;align-items:center;gap:10px">
  <img src="../ng-symbol.png" style="height:26px" alt=""><span style="flex:1;font-family:'Plus Jakarta Sans';font-size:15px;font-weight:700;color:#2B3990">NG Class</span>
  {bell(44, 3)}
  {avatar('IH', 'indigo', 40, True)}
</div>'''


def teacher_home():
    quick = ''.join(f'<span class="btn secondary sm" style="height:40px">{icon(i, 16)}{t}</span>' for i, t in
                    [('calplus', 'Séance'), ('clipboard', 'Devoir'), ('upload', 'Importer')])
    return phone(f'''
    {header_with_bell()}
    <div><div class="s13" style="font-weight:600">Jeudi 8 octobre</div><div style="font-size:26px;font-weight:800;letter-spacing:-.5px">Bonjour Ines</div>
      <div style="font-size:15px;color:#4A4F72;margin-top:4px">2 séances aujourd'hui.</div></div>
    <div style="display:flex;gap:8px;flex-wrap:wrap">{quick}</div>
    <div style="padding:22px;border-radius:24px;background:#2B3990;color:#fff;display:flex;flex-direction:column;gap:8px">
      <span class="chip" style="background:rgba(255,255,255,.14);color:#fff;align-self:flex-start">PROCHAINE SÉANCE</span>
      <div style="font-size:40px;font-weight:800;direction:ltr;text-align:start">15:00</div><div style="font-size:15px;font-weight:600">4ème année · Maths · Salle 2</div></div>
    <div class="note">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>La cloche apparaît à côté de votre avatar, avec le nombre de notifications non lues.</span></div>
    ''', TEACHER_NAV, 'fr', 0)


def list_fr():
    body = f'''
  <div style="display:flex;align-items:center;gap:12px;padding:16px 18px;background:#fff;border-bottom:1px solid #E6E8F0">
    <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center">{icon('arrowleft', 20)}</span>
    <div style="flex:1"><div style="font-size:18px;font-weight:800">Notifications</div><div class="s13">3 non lues</div></div>
    <a style="font-size:13px;font-weight:700">Tout marquer comme lu</a></div>
  <div style="flex:1;overflow:hidden;padding:14px 16px;display:flex;flex-direction:column;gap:10px">{rows_fr(compact=True)}</div>'''
    return frame(body)


def list_ar():
    def g(name):
        return f'<bdi>{name}</bdi>'
    body = f'''
  <div style="display:flex;align-items:center;gap:12px;padding:16px 18px;background:#fff;border-bottom:1px solid #E6E8F0">
    <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center;transform:scaleX(-1)">{icon('arrowleft', 20)}</span>
    <div style="flex:1"><div style="font-size:18px;font-weight:800">الإشعارات</div><div class="s13">3 إشعارات غير مقروءة</div></div>
    <a style="font-size:13px;font-weight:700">تعليم الكل كمقروء</a></div>
  <div style="flex:1;overflow:hidden;padding:14px 16px;display:flex;flex-direction:column;gap:10px">
    {section('اليوم')}
    {notification('sent', '3 أعمال مُرسلة', line(g('Série 2 : les fractions'), '#1A1D3A', 700) + line(f'{g("Adam")}، {g("Sara")}، {g("Omar")} · {g("4ème année · Maths")}'), 'منذ 10 دقائق', True, 'تصحيح')}
    {notification('sent', 'عمل واحد مُرسل', line(g('Série 1 : les fractions'), '#1A1D3A', 700) + line(f'{g("Amine Kefi")} · {g("4ème année · Maths")}'), 'منذ ساعة', True, 'تصحيح', late='متأخّر')}
    {notification('missing', 'انقضى آخر أجل', line(g('Lecture : le corbeau et le renard'), '#1A1D3A', 700) + line(f'لم يُرسل 2: {g("Rayen Mansour")}، {g("Lina Bouzid")}', '#B42525', 600) + line(g('4ème année · Lecture')), 'اليوم على الساعة 08:00', True, 'عرض')}
    {section('قبل ذلك')}
    {notification('allsent', 'انقضى آخر أجل', line(g('Table de 7'), '#1A1D3A', 700) + line('أرسل الجميع', '#237A35', 600) + line(g('4ème année · Maths')), 'الاثنين 5 أكتوبر')}
  </div>'''
    return frame(body, 'ar')


def empty():
    classmates = '''<div style="display:flex;align-items:flex-end;gap:5px;justify-content:center">
      <div style="width:38px;height:80px;background:#2B3990;border-radius:19px 19px 0 0;display:flex;justify-content:center;gap:4px;padding-top:18px;box-sizing:border-box"><span style="width:7px;height:7px;border-radius:4px;background:#fff"></span><span style="width:7px;height:7px;border-radius:4px;background:#fff"></span></div>
      <div style="width:80px;height:40px;background:#12A39A;border-radius:40px 40px 0 0"></div>
      <div style="width:42px;height:60px;background:#FFB020;border-radius:13px 13px 0 0"></div>
      <div style="width:34px;height:68px;background:#7048E8;border-radius:17px 17px 0 0"></div></div>'''
    body = f'''
  <div style="display:flex;align-items:center;gap:12px;padding:16px 18px;background:#fff;border-bottom:1px solid #E6E8F0">
    <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center">{icon('arrowleft', 20)}</span>
    <div style="flex:1"><div style="font-size:18px;font-weight:800">Notifications</div><div class="s13">Tout est lu</div></div></div>
  <div style="flex:1;padding:16px">
    <div style="height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:16px;background:#fff;border:1px solid #E6E8F0;border-radius:20px;padding:24px;text-align:center">
      {classmates}
      <div style="font-size:15px;font-weight:700">Rien de nouveau pour le moment.</div>
      <div class="s13" style="max-width:270px;line-height:1.5">Vous serez prévenue ici quand un élève rend un travail ou quand une date limite passe.</div>
    </div></div>'''
    return frame(body)


NOTES = [
    ('La cloche', 'En haut de chaque page, entre « FR · ع » et « Créer » (à côté de l\'avatar sur téléphone), avec le nombre de notifications non lues en orange. Elle s\'ouvre en panneau sur ordinateur et en plein écran sur téléphone.'),
    ('Travaux rendus', 'Quand un élève ou un parent envoie un travail. Un seul message par devoir tant que vous ne l\'avez pas lu : « 3 travaux rendus » avec les prénoms, au lieu de trois messages. « En retard » si l\'envoi arrive après la date limite. « Corriger » ouvre la copie.'),
    ('Date limite passée', 'À la date limite de chaque devoir : qui n\'a pas rendu (« 2 manquants » et leurs noms), ou « Tout le monde a rendu ». « Voir » ouvre le devoir.'),
    ('Lu', 'Toucher une notification la marque comme lue et ouvre ce qu\'elle concerne. « Tout marquer comme lu » vide le compteur. On garde les deux derniers mois, comme pour les familles.'),
    ('Pas encore', 'Rien sur le téléphone ni par e-mail (notifications push et résumé du matin à 07:30 : version 4). Vos propres actions ne vous notifient jamais.'),
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
    {column('MA JOURNÉE · LA CLOCHE', teacher_home())}
    {column('NOTIFICATIONS', list_fr())}
    {column('ARABE · الإشعارات', list_ar())}
  </div>
  <div style="display:flex;gap:40px;justify-content:center;align-items:flex-start">
    {column('RIEN DE NOUVEAU', empty())}
    <div style="width:820px;background:#fff;border:1px solid #E6E8F0;border-radius:24px;padding:26px;display:flex;flex-direction:column;gap:16px">
      <div style="font-size:22px;font-weight:800">Notifications de l'enseignante</div>
      <div style="font-size:14px;color:#6B7090;line-height:1.5">Spec 08 (centre de notifications, sans push). Données inventées, jeudi 8 octobre.</div>
      {notes}
    </div>
  </div>
</div>'''
    return page('Notifications enseignante sur téléphone', body, width=1440, height=1900)


if __name__ == '__main__':
    (OUT / 'NotificationsEnseignante.html').write_text(desktop())
    (OUT / 'NotificationsEnseignantePhone.html').write_text(phone_board())
    print('NotificationsEnseignante, NotificationsEnseignantePhone')
