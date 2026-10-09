"""Notification center (R1): a session cancelled, moved or restored reaches the parents and the children with a login."""
from pathlib import Path

from common import ACCENTS, avatar, icon, page
from planning import phone

OUT = Path('/Users/macbook/Desktop/NextGenerationClass/docs/00-brand/ui/mockups/r1')

PARENT_NAV = [('dashboard', 'Aperçu'), ('calendar', 'Planning'), ('bell', 'Notifications')]
STUDENT_NAV_AR = [('house', 'الرئيسية'), ('book', 'الدروس'), ('clipboard', 'الفروض'), ('calendar', 'الجدول'), ('chart', 'النتائج')]


def kind_badge(kind):
    name, accent = {'cancel': ('ban', 'red'), 'move': ('clock', 'blue'), 'restore': ('circlecheck', 'green')}[kind]
    _, soft, on = ACCENTS[accent]
    return (f'<span class="badge" style="width:40px;height:40px;border-radius:12px;background:{soft};color:{on}">'
            f'{icon(name, 19)}</span>')


def notification(kind, title, lines, when, unread=False, child=None):
    """One row: what happened, for whom, when, and the session it concerns."""
    tint = 'background:#F4F5FC;border-color:#DCE0F5' if unread else 'background:#fff'
    dot = '<span style="width:9px;height:9px;border-radius:5px;background:#2B3990;flex-shrink:0;margin-top:6px"></span>' if unread else ''
    tag = (f'<span class="chip" style="background:#fff;border:1px solid #E6E8F0;color:#1A1D3A;padding:3px 9px">{child}</span>'
           if child else '')
    return f'''<div style="display:flex;gap:12px;padding:14px;border:1px solid #E6E8F0;border-radius:18px;{tint}">
  {kind_badge(kind)}
  <div style="flex:1;min-width:0;display:flex;flex-direction:column;gap:5px">
    <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap"><span class="t15" style="font-weight:{800 if unread else 700}">{title}</span>{tag}</div>
    {lines}
    <div class="cap" style="font-weight:600;margin-top:2px">{when}</div>
  </div>
  {dot}
</div>'''


def line(text, color='#4A4F72', weight=500, strike=False):
    deco = 'text-decoration:line-through;' if strike else ''
    return f'<div style="font-size:13px;line-height:1.45;color:{color};font-weight:{weight};{deco}">{text}</div>'


def section(label):
    return f'<div class="cap" style="font-size:12px;letter-spacing:1px;text-transform:uppercase;margin-top:4px">{label}</div>'


def parent_list():
    return phone(f'''
    <div style="display:flex;align-items:flex-end;gap:12px"><div style="flex:1"><div class="s13" style="font-weight:600">2 non lues</div><div style="font-size:22px;font-weight:800">Notifications</div></div><a style="font-size:13px;font-weight:700;padding-bottom:4px">Tout marquer comme lu</a></div>
    {section("Aujourd'hui")}
    {notification('cancel', 'Séance annulée', line('Jeudi 8 octobre · 10:00 · 4ème année · Maths') + line('Motif : sortie scolaire', '#B42525', 600), 'Il y a 2 h', unread=True, child='Adam')}
    {notification('move', 'Séance déplacée', line('Mardi 13 octobre · 15:00', '#6B7090', strike=True) + line('Mercredi 14 octobre · 14:00 · Lecture', '#1A1D3A', 700), 'Il y a 5 h', unread=True, child='Lina')}
    {section('Plus tôt')}
    {notification('restore', 'Séance rétablie', line('Samedi 10 octobre · 9:00 · 4ème année · Maths'), 'Lundi 5 octobre', child='Adam')}
    {notification('cancel', '3 séances annulées', line('À partir du mardi 20 octobre · Lecture') + line('Motif : vacances', '#B42525', 600), 'Lundi 5 octobre', child='Lina')}
    ''', PARENT_NAV, 'fr', 2).replace(
        '<span style="font-size:11px;font-weight:800;color:#2B3990">Notifications</span>',
        '<span style="font-size:11px;font-weight:800;color:#2B3990">Notifications</span>', 1).replace(
        f'{icon("bell", 20)}</span>',
        f'{icon("bell", 20)}<span style="position:absolute;margin-top:-18px;margin-inline-start:22px;min-width:17px;height:17px;padding:0 5px;border-radius:9px;background:#FFB020;color:#1A1D3A;font-size:10px;font-weight:800;display:flex;align-items:center;justify-content:center">2</span></span>', 1)


def student_list_ar():
    return phone(f'''
    <div style="display:flex;align-items:center;gap:12px"><span class="btn secondary" style="width:40px;height:40px;padding:0;justify-content:center">{icon('chevright', 18)}</span><div style="flex:1;font-size:22px;font-weight:700">الإشعارات</div><a style="font-size:13px;font-weight:700">تعليم الكل كمقروء</a></div>
    {section('اليوم')}
    {notification('cancel', 'ألغيت الحصة', line('الخميس 8 أكتوبر · 10:00 · رياضيات') + line('السبب: خرجة مدرسية', '#B42525', 600), 'منذ ساعتين', unread=True)}
    {section('قبل ذلك')}
    {notification('move', 'تغيّر موعد الحصة', line('الثلاثاء 13 أكتوبر · 15:00', '#6B7090', strike=True) + line('الأربعاء 14 أكتوبر · 14:00 · رياضيات', '#1A1D3A', 700), 'الاثنين 5 أكتوبر')}
    <div style="flex:1"></div>
    <div class="note">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>تفتح هذه الصفحة من الجرس في أعلى الصفحة الرئيسية.</span></div>
    ''', STUDENT_NAV_AR, 'ar', 0)


def parent_empty():
    classmates = '''<div style="display:flex;align-items:flex-end;gap:5px;justify-content:center">
      <div style="width:38px;height:80px;background:#2B3990;border-radius:19px 19px 0 0;display:flex;justify-content:center;gap:4px;padding-top:18px;box-sizing:border-box"><span style="width:7px;height:7px;border-radius:4px;background:#fff"></span><span style="width:7px;height:7px;border-radius:4px;background:#fff"></span></div>
      <div style="width:80px;height:40px;background:#12A39A;border-radius:40px 40px 0 0"></div>
      <div style="width:42px;height:60px;background:#FFB020;border-radius:13px 13px 0 0"></div>
      <div style="width:34px;height:68px;background:#7048E8;border-radius:17px 17px 0 0"></div></div>'''
    return phone(f'''
    <div><div class="s13" style="font-weight:600">Tout est lu</div><div style="font-size:22px;font-weight:800">Notifications</div></div>
    <div style="flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:16px;background:#fff;border:1px solid #E6E8F0;border-radius:20px;padding:24px;text-align:center">
      {classmates}
      <div style="font-size:15px;font-weight:700">Aucune notification pour le moment.</div>
      <div class="s13" style="max-width:260px;line-height:1.5">Vous serez prévenu ici si une séance est annulée, déplacée ou rétablie.</div>
    </div>
    ''', PARENT_NAV, 'fr', 2)


def board():
    def column(label, content):
        return f'<div style="display:flex;flex-direction:column;gap:14px;align-items:center"><div class="cap" style="font-size:13px">{label}</div>{content}</div>'

    body = f'''<div style="padding:48px;display:flex;gap:48px;align-items:flex-start;justify-content:center;min-height:960px;background:#EEF0FA">
  {column('PARENT · ONGLET NOTIFICATIONS', parent_list())}
  {column('ÉLÈVE · ARABE · DEPUIS LA CLOCHE', student_list_ar())}
  {column('PARENT · RIEN DE NOUVEAU', parent_empty())}
</div>'''
    return page('Notifications', body, width=1440, height=960)


if __name__ == '__main__':
    (OUT / 'Notifications.html').write_text(board())
    print('Notifications')
