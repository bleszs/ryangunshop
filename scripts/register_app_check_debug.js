'use strict';

const childProcess = require('child_process');
const path = require('path');

const packageName = 'id.ryangunshop.ryangunshop';
const projectNumber = '884773335114';
const appId = '1:884773335114:android:b204a53c5bdabfc3f136b3';
const displayName = 'Pixel_8_2 local debug';
const adb = process.env.ADB_PATH || childProcess
  .execFileSync('where.exe', ['adb'], {encoding: 'utf8'})
  .split(/\r?\n/)
  .find(Boolean);

function adbRun(args) {
  return childProcess.execFileSync(adb, ['-s', 'emulator-5554', ...args], {
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'pipe'],
  });
}

async function main() {
  adbRun(['shell', 'am', 'force-stop', packageName]);
  adbRun(['logcat', '-c']);
  adbRun(['shell', 'am', 'start', '-n', `${packageName}/.MainActivity`]);
  await new Promise((resolve) => setTimeout(resolve, 10000));

  const appCheckLines = adbRun(['logcat', '-d', '-v', 'brief'])
    .split(/\r?\n/)
    .filter((line) => line.includes('DebugAppCheckProvider'))
    .join('\n');
  const match = appCheckLines.match(
    /[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/i,
  );
  if (!match) throw new Error('Debug App Check token tidak ditemukan');

  const npmRoot = childProcess
    .execFileSync(process.env.ComSpec, ['/d', '/s', '/c', 'npm root -g'], {
      encoding: 'utf8',
    })
    .trim();
  const firebaseTools = path.join(npmRoot, 'firebase-tools', 'lib');
  const auth = require(path.join(firebaseTools, 'auth.js'));
  const api = require(path.join(firebaseTools, 'apiv2.js'));
  const account = auth.getGlobalDefaultAccount();
  if (!account) throw new Error('Firebase CLI belum login');
  auth.setRefreshToken(account.tokens.refresh_token);

  const client = new api.Client({
    urlPrefix: 'https://firebaseappcheck.googleapis.com/v1',
  });
  const parent = `projects/${projectNumber}/apps/${appId}`;
  const listed = await client.get(`/${parent}/debugTokens`);
  const existing = (listed.body.debugTokens || []).find(
    (item) => item.displayName === displayName,
  );
  if (existing?.name) {
    await client.delete(`/${existing.name}`);
  }
  await client.post(`/${parent}/debugTokens`, {
    displayName,
    token: match[0],
  });
  console.log('Debug App Check token emulator berhasil dirotasi.');
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
