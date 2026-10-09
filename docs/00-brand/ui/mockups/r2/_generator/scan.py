"""Release 2, step 2: scanning paper sheets with the phone into one PDF (spec 04, uploads)."""
from pathlib import Path

from contents import kind_badge, square, worksheet  # also puts the R1 generator on the path

import common  # noqa: E402
from common import badge, icon, page  # noqa: E402

OUT = Path(__file__).resolve().parents[1]

common.ICONS.update({
    'camera': '<path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"/><circle cx="12" cy="13" r="3"/>',
    'images': '<path d="M18 22H4a2 2 0 0 1-2-2V6"/><path d="m22 13-1.296-1.296a2.41 2.41 0 0 0-3.408 0L11 18"/><circle cx="12" cy="8" r="2"/><rect width="16" height="16" x="6" y="2" rx="2"/>',
    'rotate': '<path d="M21 12a9 9 0 1 1-9-9c2.52 0 4.93 1 6.74 2.74L21 8"/><path d="M21 3v5h-5"/>',
    'crop': '<path d="M6 2v14a2 2 0 0 0 2 2h14"/><path d="M18 22V8a2 2 0 0 0-2-2H2"/>',
    'grip': '<circle cx="9" cy="12" r="1"/><circle cx="9" cy="5" r="1"/><circle cx="9" cy="19" r="1"/><circle cx="15" cy="12" r="1"/><circle cx="15" cy="5" r="1"/><circle cx="15" cy="19" r="1"/>',
    'undo': '<path d="M3 7v6h6"/><path d="M21 17a9 9 0 0 0-9-9 9 9 0 0 0-6 2.3L3 13"/>',
    'scan': '<path d="M3 7V5a2 2 0 0 1 2-2h2M17 3h2a2 2 0 0 1 2 2v2M21 17v2a2 2 0 0 1-2 2h-2M7 21H5a2 2 0 0 1-2-2v-2M7 12h10"/>',
    'trash': '<path d="M3 6h18M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/>',
})

T = {
    'fr': dict(
        title='Scanner des feuilles', pages='3 pages', take='Prendre une photo', gallery='Depuis la galerie',
        hint='Posez la feuille à plat, bien éclairée. Appuyez sur une page pour la recadrer ou la pivoter, maintenez-la pour la déplacer.',
        color='Couleur', bw='Noir et blanc', create='Créer le PDF', cancel='Annuler',
        crop_title='Page 2 sur 3', rotate='Pivoter', reset='Rétablir', done='Valider', delete='Supprimer',
        crop_hint='Faites glisser les coins sur les bords de la feuille.',
    ),
    'ar': dict(
        title='مسح الأوراق', pages='3 صفحات', take='التقاط صورة', gallery='من المعرض',
        hint='ضع الورقة مسطّحة وفي إضاءة جيدة. اضغط على صفحة لقصّها أو تدويرها، واضغط مطوّلًا لتحريكها.',
        color='بالألوان', bw='بالأبيض والأسود', create='إنشاء ملف PDF', cancel='إلغاء',
        crop_title='صفحة 2 من 3', rotate='تدوير', reset='استرجاع', done='تأكيد', delete='حذف',
        crop_hint='اسحب الزوايا إلى حواف الورقة.',
    ),
}


def frame(body, lang='fr', dark=False, height=844):
    """A phone without tabs: the scan takes the whole screen."""
    d = ' dir="rtl"' if lang == 'ar' else ''
    font = "'IBM Plex Sans Arabic',sans-serif" if lang == 'ar' else "'Plus Jakarta Sans',sans-serif"
    bg = '#14172E' if dark else '#F6F7FB'
    return (f'<div{d} style="width:390px;height:{height}px;background:{bg};border-radius:36px;overflow:hidden;position:relative;font-family:{font};'
            f'box-shadow:0 20px 60px rgba(28,37,102,.15);border:1px solid #E6E8F0;display:flex;flex-direction:column">{body}</div>')


def photo(scale, tilt=0.0, bw=False):
    """A sheet photographed on a wooden table: the worksheet, slightly turned."""
    flt = 'grayscale(1) contrast(1.25)' if bw else 'none'
    return (f'<div style="background:linear-gradient(135deg,#C9A27A,#A97E58);padding:{int(14 * scale / 0.3)}px;border-radius:6px;overflow:hidden;filter:{flt}">'
            f'<div style="transform:rotate({tilt}deg)">{worksheet(scale)}</div></div>')


def thumb(n, tilt, selected=False, bw=False):
    border = '2.5px solid #2B3990' if selected else '1px solid #E6E8F0'
    return f'''<div style="position:relative;min-width:0;overflow:hidden;background:#fff;border:{border};border-radius:16px;padding:8px;display:flex;flex-direction:column;gap:6px">
  <div style="height:150px;overflow:hidden;border-radius:10px;display:flex;justify-content:center;align-items:flex-start;background:#E9EBF3">{photo(0.22, tilt, bw)}</div>
  <div style="display:flex;align-items:center;gap:6px"><span style="width:24px;height:24px;border-radius:12px;background:#1A1D3A;color:#fff;font-size:12px;font-weight:800;display:flex;align-items:center;justify-content:center">{n}</span>
    <span style="flex:1"></span><span style="color:#6B7090">{icon('grip', 18)}</span></div>
  <span style="position:absolute;top:14px;inset-inline-end:14px;width:30px;height:30px;border-radius:15px;background:#fff;box-shadow:0 2px 8px rgba(0,0,0,.18);display:flex;align-items:center;justify-content:center;color:#B42525">{icon('x', 16, 2.4)}</span>
</div>'''


def pages_screen(lang='fr'):
    t = T[lang]
    seg = f'<div class="seg"><span class="on">{t["color"]}</span><span>{t["bw"]}</span></div>'
    body = f'''
  <div style="display:flex;align-items:center;gap:12px;padding:18px 18px 12px;background:#fff;border-bottom:1px solid #E6E8F0">
    <span class="btn secondary" style="width:44px;height:44px;padding:0;justify-content:center">{icon('x', 20)}</span>
    <div style="flex:1"><div style="font-size:18px;font-weight:800">{t['title']}</div><div class="s13">{t['pages']}</div></div>
  </div>
  <div style="flex:1;overflow:hidden;padding:16px 18px;display:flex;flex-direction:column;gap:14px">
    {seg}
    <div style="display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px">
      {thumb(1, -2)}{thumb(2, 3, selected=True)}{thumb(3, -1)}
      <div style="border:1.5px dashed #9AA3D9;border-radius:16px;background:#F4F5FC;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:8px;color:#2B3990;min-height:196px">
        {icon('camera', 26)}<span style="font-size:13px;font-weight:700">{t['take']}</span></div>
    </div>
    <div class="note" style="background:#fff;border:1px solid #E6E8F0">{icon('info', 16, color='#2B3990', style='margin-top:2px')}<span>{t['hint']}</span></div>
  </div>
  <div style="padding:14px 18px 18px;background:#fff;border-top:1px solid #E6E8F0;display:flex;flex-direction:column;gap:10px">
    <div style="display:flex;gap:10px">
      <span class="btn tonal" style="flex:1;min-width:0;height:50px;padding:0 10px;font-size:13px;justify-content:center">{icon('camera', 18)}{t['take']}</span>
      <span class="btn secondary" style="flex:1;min-width:0;height:50px;padding:0 10px;font-size:13px;justify-content:center">{icon('images', 18)}{t['gallery']}</span>
    </div>
    <span class="btn primary" style="height:52px;justify-content:center">{icon('filetext', 18)}{t['create']}</span>
  </div>'''
    return frame(body, lang)


def crop_screen(lang='fr'):
    t = T[lang]
    corner = 'position:absolute;width:26px;height:26px;border-radius:13px;background:#fff;border:3px solid #2B3990;box-shadow:0 2px 8px rgba(0,0,0,.4)'
    tool = lambda ic, label, primary=False: (  # noqa: E731
        f'<div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:6px;color:{"#fff" if not primary else "#1A1D3A"}">'
        f'<span style="width:52px;height:52px;border-radius:16px;display:flex;align-items:center;justify-content:center;'
        f'background:{"#FFB020" if primary else "rgba(255,255,255,.12)"}">{icon(ic, 22)}</span>'
        f'<span style="font-size:12px;font-weight:700;color:#fff">{label}</span></div>')
    body = f'''
  <div style="display:flex;align-items:center;gap:12px;padding:18px;color:#fff">
    <span style="width:44px;height:44px;border-radius:14px;background:rgba(255,255,255,.12);display:flex;align-items:center;justify-content:center">{icon('arrowleft', 20)}</span>
    <div style="flex:1;font-size:17px;font-weight:800">{t['crop_title']}</div>
    <span style="width:44px;height:44px;border-radius:14px;background:rgba(255,255,255,.12);display:flex;align-items:center;justify-content:center;color:#FF8787">{icon('trash', 19)}</span>
  </div>
  <div style="flex:1;display:flex;align-items:center;justify-content:center;position:relative;padding:10px 24px">
    <div style="position:relative;overflow:hidden;border-radius:6px">
      {photo(0.56, 3)}
      <div style="position:absolute;inset:18px 16px 22px 20px;border:2px solid #fff;box-shadow:0 0 0 9999px rgba(10,12,30,.55)"></div>
      <span style="{corner};top:5px;left:7px"></span><span style="{corner};top:5px;right:3px"></span>
      <span style="{corner};bottom:9px;left:7px"></span><span style="{corner};bottom:9px;right:3px"></span>
    </div>
  </div>
  <div style="padding:0 24px 8px;text-align:center;font-size:13px;color:#C9CCE0">{t['crop_hint']}</div>
  <div style="display:flex;padding:14px 18px 24px">{tool('rotate', t['rotate'])}{tool('undo', t['reset'])}{tool('check', t['done'], True)}</div>'''
    return frame(body, lang, dark=True)


def import_choice():
    """The import panel on a phone: choose a file, or scan sheets."""
    body = f'''
  <div style="display:flex;align-items:center;gap:12px;padding:18px;background:#fff;border-bottom:1px solid #E6E8F0">
    {badge('upload', 'indigo', 44, 14, 20)}<div style="flex:1"><div style="font-size:18px;font-weight:800">Importer un document</div>
      <div class="s13">PDF, photo ou Word, ou des feuilles à scanner.</div></div>{icon('x', 22, color='#6B7090')}</div>
  <div style="flex:1;overflow:hidden;padding:18px;display:flex;flex-direction:column;gap:14px">
    <div style="display:flex;gap:10px">
      <div style="flex:1;border:1.5px dashed #9AA3D9;border-radius:16px;background:#F4F5FC;padding:16px 10px;display:flex;flex-direction:column;align-items:center;gap:8px;text-align:center">
        {badge('folder', 'indigo', 44, 14, 20)}<span style="font-size:14px;font-weight:800;color:#2B3990">Choisir un fichier</span><span class="s13" style="font-size:12px">PDF, JPG, PNG, Word</span></div>
      <div style="flex:1;border:1.5px solid #2B3990;border-radius:16px;background:#fff;padding:16px 10px;display:flex;flex-direction:column;align-items:center;gap:8px;text-align:center">
        {badge('camera', 'turquoise', 44, 14, 20)}<span style="font-size:14px;font-weight:800;color:#0B6E68">Scanner des feuilles</span><span class="s13" style="font-size:12px">Plusieurs pages, un seul PDF</span></div>
    </div>
    <div class="field"><label>Titre</label><div class="input" style="color:#6B7090">Ex. : Série 2 : les fractions</div></div>
    <div class="field"><label>Matière</label><div class="input" style="justify-content:space-between"><span style="display:flex;align-items:center;gap:10px"><span style="width:12px;height:12px;border-radius:6px;background:#2B3990"></span>Mathématiques</span>{icon('chevdown', 18, color='#6B7090')}</div></div>
    <div class="field"><label>Niveau</label><div class="input" style="justify-content:space-between">4ème année{icon('chevdown', 18, color='#6B7090')}</div></div>
    <div class="field"><label>Chapitre</label><div class="input" style="justify-content:space-between">La multiplication{icon('chevdown', 18, color='#6B7090')}</div></div>
  </div>
  <div style="display:flex;gap:10px;justify-content:flex-end;padding:14px 18px 18px;border-top:1px solid #E6E8F0;background:#fff"><span class="btn ghost">Annuler</span><span class="btn primary">{icon('upload', 17)}Importer</span></div>'''
    return frame(body)


def import_scanned():
    """Back in the panel: the scan is one PDF, ready to import like any file."""
    body = f'''
  <div style="display:flex;align-items:center;gap:12px;padding:18px;background:#fff;border-bottom:1px solid #E6E8F0">
    {badge('upload', 'indigo', 44, 14, 20)}<div style="flex:1"><div style="font-size:18px;font-weight:800">Importer un document</div>
      <div class="s13">PDF, photo ou Word, ou des feuilles à scanner.</div></div>{icon('x', 22, color='#6B7090')}</div>
  <div style="flex:1;overflow:hidden;padding:18px;display:flex;flex-direction:column;gap:14px">
    <div style="display:flex;align-items:center;gap:12px;padding:12px 14px;border:1.5px dashed #9AA3D9;border-radius:16px;background:#F4F5FC">
      {kind_badge('pdf')}<div style="flex:1"><div class="t15">Scan du 6 octobre.pdf</div><div class="s13">PDF · 3 pages · 820 Ko</div></div>
      <span class="btn ghost sm" style="color:#2B3990;padding:0 6px">Changer</span></div>
    <div class="field"><label>Titre</label><div class="input focus">Série 3 : la multiplication</div><div class="hint">Les élèves voient ce titre.</div></div>
    <div class="field"><label>Chapitre</label><div class="input" style="justify-content:space-between">La multiplication{icon('chevdown', 18, color='#6B7090')}</div></div>
    <div class="field"><label>Étiquette</label><div class="seg"><span class="on">Série</span><span>Cours</span><span>Corrigé</span><span>Autre</span></div></div>
    <div class="field"><label>Partager avec <span class="s13" style="font-weight:500">· facultatif</span></label>
      <div style="display:flex;align-items:center;gap:12px;padding:10px 12px;border:1.5px solid #2B3990;border-radius:14px;background:#F4F5FC">
        <span style="color:#2B3990;display:flex">{icon('checksquare', 20)}</span>{square('4A')}<span style="flex:1;font-size:14px;font-weight:600">4ème année · Maths</span><span class="s13">6 élèves</span></div></div>
  </div>
  <div style="display:flex;gap:10px;justify-content:flex-end;padding:14px 18px 18px;border-top:1px solid #E6E8F0;background:#fff"><span class="btn ghost">Annuler</span><span class="btn primary">{icon('upload', 17)}Importer</span></div>'''
    return frame(body)


NOTES = [
    ('Où', 'Dans « Importer un document », à côté de « Choisir un fichier ». Sur ordinateur, le bouton ouvre les photos déjà prises (pas de caméra).'),
    ('Prendre les pages', 'Une photo par feuille, l\'une après l\'autre : l\'appareil photo du téléphone s\'ouvre, puis on revient à la liste. On peut aussi ajouter des photos de la galerie.'),
    ('Ranger les pages', 'Maintenir une page pour la déplacer, la croix pour la supprimer. Le numéro suit l\'ordre.'),
    ('Recadrer, pivoter', 'Toucher une page ouvre le recadrage : les quatre coins sur les bords de la feuille, un quart de tour, « Rétablir » pour revenir à la photo d\'origine.'),
    ('Couleur ou noir et blanc', 'Noir et blanc rend une feuille photographiée plus nette et le fichier plus léger. Le choix vaut pour tout le PDF.'),
    ('Un seul PDF, fait sur le téléphone', 'Les pages sont réduites (1600 px, qualité 75) puis mises en A4 dans un PDF. Rien n\'est envoyé avant « Importer ».'),
    ('Ensuite, comme un fichier', 'Le PDF revient dans le panneau : titre, chapitre, étiquette, partage, puis « Importer ». 20 Mo au plus, soit environ 40 pages.'),
    ('Arabe', 'Même écran de droite à gauche ; la page 1 est la première en lisant.'),
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
    {column('1 · IMPORTER : DEUX CHOIX', import_choice())}
    {column('2 · LES PAGES', pages_screen('fr'))}
    {column('3 · RECADRER UNE PAGE', crop_screen('fr'))}
  </div>
  <div style="display:flex;gap:40px;justify-content:center;align-items:flex-start">
    {column('4 · LE PDF EST PRÊT', import_scanned())}
    {column('ARABE · الصفحات', pages_screen('ar'))}
    <div style="width:390px;background:#fff;border:1px solid #E6E8F0;border-radius:24px;padding:26px;display:flex;flex-direction:column;gap:16px">
      <div style="font-size:22px;font-weight:800">Scanner des feuilles</div>
      <div style="font-size:14px;color:#6B7090;line-height:1.5">Contenus, étape 2 (spec 04). Une série sur papier devient un PDF en une minute. Données inventées.</div>
      {notes}
    </div>
  </div>
</div>'''
    return page('Scanner des feuilles', body, width=1440, height=2050)


if __name__ == '__main__':
    (OUT / 'Scanner.html').write_text(board())
    print('Scanner')
