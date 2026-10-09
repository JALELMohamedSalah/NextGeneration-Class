// Screenshots of the local web app, signed in, through headless Chrome and the DevTools protocol.
// Usage: DEV_YAML=backend/src/main/resources/application-dev.yaml node infra/dev-tools/cdp-screens.mjs steps.json
// Steps (JSON array, run in order): {"viewport":[w,h]} {"go":url} {"wait":ms} {"click":[x,y]} {"type":text}
// {"key":"Enter"} {"eval":js} {"shot":"out.png"}, {"drag":[x1,y1,x2,y2]}, {"file":"/abs/path"} (answers the next file picker), and {"signin":"admin|teacher|student|parent","lang":"fr|ar"}, which signs in
// on its own (at the size the login coordinates belong to), so any viewport can follow. A "type" value starting with "$" is read from DEV_YAML
// by key: "$username" and "$password" (first match: the teacher), "$student-username", "$parent-phone",
// "$admin.username" (key inside a block)...
// so passwords never appear in steps, logs or chat.
// The app uses hash URLs: http://localhost:5050/#/enseignante/...
import { spawn } from 'node:child_process';
import { readFileSync, writeFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';

const steps = JSON.parse(readFileSync(process.argv[2], 'utf8'));
const port = 9333 + Math.floor(Math.random() * 500);
const profile = mkdtempSync(join(tmpdir(), 'ngchrome-'));
const chrome = spawn('/Applications/Google Chrome.app/Contents/MacOS/Google Chrome', [
  '--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`, '--no-first-run',
  '--hide-scrollbars', 'about:blank'], { stdio: 'ignore' });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
let targets;
for (let i = 0; i < 50; i++) { try { targets = await (await fetch(`http://127.0.0.1:${port}/json`)).json(); break; } catch { await sleep(200); } }
const page = targets.find((t) => t.type === 'page');
const ws = new WebSocket(page.webSocketDebuggerUrl);
await new Promise((r) => ws.addEventListener('open', r));
let id = 0; const pending = new Map();
// Console errors and uncaught exceptions are printed (lines mentioning a password are dropped).
const report = (text) => { if (!/password|mot de passe/i.test(text)) console.log('console', text.slice(0, 400)); };
// A {"file": path} step answers the next file picker the page opens with that file.
let nextFile = null;
ws.addEventListener('message', (e) => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
  if (m.method === 'Page.fileChooserOpened' && nextFile) {
    send('DOM.setFileInputFiles', { files: [nextFile], backendNodeId: m.params.backendNodeId });
    nextFile = null;
  }
  if (m.method === 'Runtime.exceptionThrown') report(m.params.exceptionDetails?.exception?.description ?? m.params.exceptionDetails?.text ?? '');
  if (m.method === 'Runtime.consoleAPICalled' && (['error', 'warning'].includes(m.params.type) || process.env.CDP_LOG)) report(m.params.args.map((a) => a.value ?? a.description ?? '').join(' '));
});
const send = (method, params = {}) => new Promise((r) => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params })); });
// "section.key" looks for the key inside that block of the YAML (e.g. "admin.username").
// Values come from DEV_YAML; a "${NAME:}" with no default is read from backend/.env (DEV_ENV), never printed.
const devEnv = (() => {
  const path = process.env.DEV_ENV || resolve(dirname(process.env.DEV_YAML), '../../../.env');
  try {
    return Object.fromEntries(readFileSync(path, 'utf8').split('\n').filter((l) => /^[A-Z_]+=/.test(l)).map((l) => [l.slice(0, l.indexOf('=')), l.slice(l.indexOf('=') + 1).trim()]));
  } catch { return {}; }
})();
const secrets = (() => {
  const y = readFileSync(process.env.DEV_YAML, 'utf8');
  // "section.key" looks for the key inside that block of the YAML (e.g. "admin.password").
  const get = (k) => {
    const [section, key] = k.includes('.') ? k.split('.') : [null, k];
    const at = section ? y.indexOf(`${section}:`) : 0;
    const t = at < 0 ? '' : y.slice(at);
    const placeholder = t.match(new RegExp(`${key}:\\s*\\$\\{([A-Z_]+):?([^}]*)\\}`));
    if (placeholder) return placeholder[2].trim() || devEnv[placeholder[1]] || process.env[placeholder[1]];
    return (t.match(new RegExp(`${key}:\\s*["']?([^"'\\n]+)`)) || [])[1]?.trim();
  };
  return { get };
})();
const value = (v) => v.startsWith('$') ? secrets.get(v.slice(1)) : v;
async function click(x, y) { for (const type of ['mousePressed', 'mouseReleased']) await send('Input.dispatchMouseEvent', { type, x, y, button: 'left', clickCount: 1 }); }
await send('Runtime.enable');
// The login screen centers its form: these points belong to a 1440 x 900 window, so sign-in always runs there.
const accounts = { admin: ['$admin.username', '$admin.password'], teacher: ['$username', '$password'], student: ['$student-username', '$student-password'], parent: ['$parent-phone', '$parent-password'] };
async function signin(role, lang = 'fr') {
  const [login, password] = accounts[role];
  const x = lang === 'ar' ? 317 : 1123;
  await send('Emulation.setDeviceMetricsOverride', { width: 1440, height: 900, deviceScaleFactor: 1, mobile: false });
  await send('Page.navigate', { url: 'http://localhost:5050/#/connexion' });
  await sleep(4000);
  if (lang === 'ar') { await click(1360, 55); await sleep(1500); }
  await click(x, 421); await send('Input.insertText', { text: value(login) });
  await click(x, 516); await send('Input.insertText', { text: value(password) });
  await send('Input.dispatchKeyEvent', { type: 'keyDown', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 });
  await send('Input.dispatchKeyEvent', { type: 'keyUp', key: 'Enter', code: 'Enter' });
  await sleep(4500);
  const r = await send('Runtime.evaluate', { expression: 'location.hash', returnByValue: true });
  const at = r.result?.result?.value ?? '';
  console.log(at.includes('connexion') ? `signin ${role} FAILED (still on the login screen)` : `signin ${role} ok ${at}`);
}
for (const s of steps) {
  if (s.signin) await signin(s.signin, s.lang);
  if (s.file) { nextFile = s.file; await send('Page.enable'); await send('Page.setInterceptFileChooserDialog', { enabled: true }); }
  if (s.viewport) await send('Emulation.setDeviceMetricsOverride', { width: s.viewport[0], height: s.viewport[1], deviceScaleFactor: 1, mobile: false });
  if (s.go) { await send('Page.navigate', { url: s.go }); }
  if (s.wait) await sleep(s.wait);
  if (s.click) await click(...s.click);
  // {"drag":[x1, y1, x2, y2]}: press, move in small steps, release (crop corners, reordering).
  if (s.drag) {
    const [x1, y1, x2, y2] = s.drag;
    // The pointer goes there first, as a hand would, then presses.
    await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x: x1, y: y1, button: 'none' });
    await sleep(60);
    await send('Input.dispatchMouseEvent', { type: 'mousePressed', x: x1, y: y1, button: 'left', buttons: 1, clickCount: 1 });
    await sleep(60);
    for (let i = 1; i <= 12; i++) {
      await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x: x1 + (x2 - x1) * i / 12, y: y1 + (y2 - y1) * i / 12, button: 'left', buttons: 1 });
      await sleep(16);
    }
    await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x: x2, y: y2, button: 'left', clickCount: 1 });
    await sleep(200);
  }
  if (s.type) { await send('Input.insertText', { text: value(s.type) }); }
  if (s.key) { await send('Input.dispatchKeyEvent', { type: 'keyDown', key: s.key, code: s.key, windowsVirtualKeyCode: s.key === 'Enter' ? 13 : 0 }); await send('Input.dispatchKeyEvent', { type: 'keyUp', key: s.key, code: s.key }); }
  if (s.eval) { const r = await send('Runtime.evaluate', { expression: s.eval, awaitPromise: true, returnByValue: true }); console.log('eval', JSON.stringify(r.result?.result?.value)); }
  if (s.shot) { const r = await send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: false }); writeFileSync(s.shot, Buffer.from(r.result.data, 'base64')); console.log('shot', s.shot); }
}
ws.close(); chrome.kill();
