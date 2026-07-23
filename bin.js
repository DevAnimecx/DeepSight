#!/usr/bin/env node
'use strict';

const https = require('https');
const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

const PKG = (() => {
  try {
    return require(path.join(__dirname, 'package.json'));
  } catch (e) {
    return { name: 'deepsight', version: '0.2.1' };
  }
})();
const VERSION = PKG.version || '0.2.1';
const REPO = 'DevAnimecx/DeepSight';
const ZIP_URL = 'https://github.com/' + REPO + '/archive/refs/heads/main.zip';

/* ───────── helpers ───────── */
function box(msg) {
  const lines = msg.split('\n');
  const w = Math.max(4, ...lines.map(function(l) { return l.length; }));
  var top = '╔' + '═'.repeat(w + 2) + '╗';
  var bot = '╚' + '═'.repeat(w + 2) + '╝';
  console.log('\n' + top);
  for (var i = 0; i < lines.length; i++) {
    console.log('║ ' + lines[i].padEnd(w) + ' ║');
  }
  console.log(bot + '\n');
}

function echo(tag, msg) { console.log('  ' + tag + '  ' + msg); }
function ok(msg)        { echo('\u2713', msg); }
function fail(msg)      { echo('\u2717', msg); }
function spin(msg)      { echo('\u25C9', msg); }

function homeDir() {
  if (os.platform() === 'win32') {
    return process.env.USERPROFILE || process.env.HOMEDRIVE + process.env.HOMEPATH || process.cwd();
  }
  return process.env.HOME || os.homedir() || process.cwd();
}
var H = homeDir();

/* ───────── platform detection ───────── */
function detectPlatforms() {
  var platforms = [];
  var pf = os.platform();

  /* Claude Desktop */
  var claudePaths = {
    win32:  path.join(process.env.APPDATA || '', 'Claude'),
    darwin: path.join(H, 'Library', 'Application Support', 'Claude'),
    linux:  path.join(H, '.config', 'Claude')
  };
  var claudeDir = claudePaths[pf] || '';
  if (claudeDir && fs.existsSync(claudeDir)) {
    platforms.push({
      id: 'claude-desktop',
      name: 'Claude Desktop',
      dir: claudeDir,
      agentDir: path.join(claudeDir, 'agents', 'skills', 'deepsight')
    });
    ok('Claude Desktop    \u2192 ' + claudeDir);
  } else {
    fail('Claude Desktop    \u2192 not found');
  }

  /* Claude Code */
  var agentsDir = path.join(H, '.agents');
  var foundClaudeCode = false;
  try {
    var r = execSync('where claude 2>nul || which claude 2>/dev/null', {
      stdio: 'pipe',
      encoding: 'utf8',
      timeout: 3000
    });
    if (r.trim()) foundClaudeCode = true;
  } catch (e) { /* not found */ }
  if (foundClaudeCode || fs.existsSync(agentsDir)) {
    var ccDir = path.join(agentsDir, 'skills', 'deepsight');
    platforms.push({
      id: 'claude-code',
      name: 'Claude Code',
      dir: agentsDir,
      agentDir: ccDir
    });
    ok('Claude Code       \u2192 ' + ccDir);
  } else {
    fail('Claude Code       \u2192 not found');
  }

  /* OpenAI Codex CLI */
  var codexConfig = path.join(H, '.config', 'codex', 'codex.json');
  if (fs.existsSync(codexConfig)) {
    platforms.push({
      id: 'codex',
      name: 'OpenAI Codex CLI',
      dir: path.dirname(codexConfig),
      agentDir: path.join(path.dirname(codexConfig), 'deepsight')
    });
    ok('OpenAI Codex CLI  \u2192 ' + path.dirname(codexConfig));
  } else {
    fail('OpenAI Codex CLI  \u2192 not found');
  }

  /* Custom GPT */
  if (process.env.OPENAI_API_KEY) {
    ok('Custom GPT        \u2192 API key configured');
  } else {
    fail('Custom GPT        \u2192 API key not set');
  }

  return platforms;
}

/* ───────── download ───────── */
function httpsGet(url) {
  return new Promise(function(resolve, reject) {
    https.get(url, { headers: { 'User-Agent': 'deepsight-installer/' + VERSION } }, function(res) {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        https.get(res.headers.location, { headers: { 'User-Agent': 'deepsight-installer/' + VERSION } }, function(res2) {
          if (res2.statusCode >= 300 && res2.statusCode < 400 && res2.headers.location) {
            https.get(res2.headers.location, { headers: { 'User-Agent': 'deepsight-installer/' + VERSION } }, function(res3) {
              resolve(res3);
            }).on('error', reject);
          } else { resolve(res2); }
        }).on('error', reject);
      } else { resolve(res); }
    }).on('error', reject);
  });
}

function downloadRelease() {
  return new Promise(function(resolve, reject) {
    spin('Downloading DeepSight v' + VERSION + ' from GitHub...');
    var tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'deepsight-'));
    var zipPath = path.join(tmpDir, 'archive.zip');
    var extractDir = path.join(tmpDir, 'extracted');
    var file = fs.createWriteStream(zipPath);

    httpsGet(ZIP_URL).then(function(res) {
      if (res.statusCode !== 200) {
        reject(new Error('Download failed (HTTP ' + res.statusCode + ')'));
        return;
      }
      res.pipe(file);
      file.on('finish', function() {
        file.close();
        var size = fs.statSync(zipPath).size;
        ok('Downloaded (' + (size / 1024).toFixed(1) + ' KB)');

        spin('Extracting...');
        try {
          extractZip(zipPath, extractDir);
          var items = fs.readdirSync(extractDir);
          var rootDir = items.find(function(i) {
            return fs.statSync(path.join(extractDir, i)).isDirectory();
          });
          if (!rootDir) {
            reject(new Error('No directory found in extracted zip'));
            return;
          }
          var srcDir = path.join(extractDir, rootDir);
          var fileCount = countFiles(srcDir);
          ok('Extracted (' + fileCount + ' files)');
          resolve(srcDir);
        } catch (e) {
          reject(new Error('Extraction failed: ' + e.message));
        }
      });
    }).catch(reject);
  });
}

function extractZip(zipPath, dest) {
  var pf = os.platform();
  fs.mkdirSync(dest, { recursive: true });

  if (pf === 'win32') {
    /* Use PowerShell Expand-Archive */
    execSync(
      'powershell -NoProfile -Command "& {Expand-Archive -Path \'' + zipPath.replace(/'/g, "''") + '\' -DestinationPath \'' + dest.replace(/'/g, "''") + '\' -Force}"',
      { stdio: 'pipe', timeout: 60000 }
    );
  } else {
    /* macOS / Linux — try unzip, then tar */
    try {
      execSync('unzip -o "' + zipPath + '" -d "' + dest + '" 2>/dev/null', {
        stdio: 'pipe',
        timeout: 60000
      });
    } catch (e1) {
      try {
        execSync('tar -xzf "' + zipPath + '" -C "' + dest + '" 2>/dev/null', {
          stdio: 'pipe',
          timeout: 60000
        });
      } catch (e2) {
        try {
          execSync('7z x "' + zipPath + '" -o"' + dest + '" -y', {
            stdio: 'pipe',
            timeout: 60000
          });
        } catch (e3) {
          /* Last resort: use python */
          try {
            execSync('python3 -c "import zipfile,sys; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])" "' + zipPath + '" "' + dest + '"', {
              stdio: 'pipe',
              timeout: 60000
            });
          } catch (e4) {
            execSync('python -c "import zipfile,sys; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])" "' + zipPath + '" "' + dest + '"', {
              stdio: 'pipe',
              timeout: 60000
            });
          }
        }
      }
    }
  }

  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }
}

function countFiles(dir) {
  var c = 0;
  try {
    var entries = fs.readdirSync(dir, { withFileTypes: true });
    for (var i = 0; i < entries.length; i++) {
      var e = entries[i];
      if (e.name.startsWith('.git') || e.name === 'node_modules') continue;
      var p = path.join(dir, e.name);
      if (e.isDirectory()) {
        c += countFiles(p);
      } else {
        c++;
      }
    }
  } catch (e) { /* skip */ }
  return c;
}

/* ───────── install ───────── */
function copyDir(src, dest, filter) {
  fs.mkdirSync(dest, { recursive: true });
  var entries = fs.readdirSync(src, { withFileTypes: true });
  for (var i = 0; i < entries.length; i++) {
    var e = entries[i];
    if (filter && !filter(e.name)) continue;
    if (e.name.startsWith('.git') || e.name === 'node_modules' || e.name === '.github') continue;
    var s = path.join(src, e.name);
    var d = path.join(dest, e.name);
    if (e.isDirectory()) {
      copyDir(s, d, filter);
    } else {
      try {
        fs.copyFileSync(s, d);
      } catch (err) { /* skip locked files */ }
    }
  }
}

function installTo(src, dest) {
  if (!dest) return false;
  copyDir(src, dest);
  return true;
}

/* ───────── main ───────── */
function main() {
  var args = process.argv.slice(2);
  var flags = {
    help: false,
    version: false,
    claude: false,
    codex: false,
    gpt: false,
    list: false,
    dryRun: false,
    yes: false
  };

  for (var i = 0; i < args.length; i++) {
    var a = args[i];
    if (a === '--help' || a === '-h') flags.help = true;
    else if (a === '--version' || a === '-v') flags.version = true;
    else if (a === '--claude') flags.claude = true;
    else if (a === '--codex') flags.codex = true;
    else if (a === '--gpt') flags.gpt = true;
    else if (a === '--list-platforms' || a === '--detect') flags.list = true;
    else if (a === '--dry-run') flags.dryRun = true;
    else if (a === '--yes' || a === '-y') flags.yes = true;
  }

  /* ── help ── */
  if (flags.help) {
    console.log('DeepSight v' + VERSION + ' \u2014 Universal AI Skill Platform');
    console.log('');
    console.log('Usage: npx deepsight [options]');
    console.log('');
    console.log('Options:');
    console.log('  --help, -h             Show this help');
    console.log('  --version, -v          Show version');
    console.log('  --claude               Force install to Claude');
    console.log('  --codex                Force install to Codex CLI');
    console.log('  --gpt                  Generate GPT instructions');
    console.log('  --list-platforms, --detect  Detect AI platforms');
    console.log('  --dry-run              Preview without installing');
    console.log('  --yes, -y              Skip confirmation');
    return;
  }

  /* ── version ── */
  if (flags.version) {
    console.log(VERSION);
    return;
  }

  /* ── header ── */
  box('DeepSight v' + VERSION + ' \u2014 npx installer\nUniversal AI Skill Platform');

  /* ── detect platforms ── */
  spin('Detecting AI platforms...');
  console.log('');
  var platforms = detectPlatforms();
  console.log('');

  if (flags.list) return;

  /* ── download ── */
  var srcDir;
  try {
    srcDir = downloadRelease();
  } catch (e) {
    console.error('  \u2717 Download failed: ' + e.message);
    process.exit(1);
  }

  /* ── filter targets ── */
  var targets = platforms.filter(function(p) { return p.agentDir; });
  if (flags.claude) targets = targets.filter(function(p) { return p.id.indexOf('claude') === 0; });
  if (flags.codex) targets = targets.filter(function(p) { return p.id === 'codex'; });

  /* Add default ~/.agents/skills/deepsight/ */
  if (!flags.claude && !flags.codex) {
    var defaultDir = path.join(H, '.agents', 'skills', 'deepsight');
    var hasDefault = targets.some(function(t) { return t.agentDir === defaultDir; });
    if (!hasDefault) {
      targets.push({
        id: 'default',
        name: 'Default',
        dir: path.join(H, '.agents'),
        agentDir: defaultDir
      });
    }
  }

  if (targets.length === 0) {
    fail('No install targets found. Use --claude or --codex to force.');
    process.exit(1);
  }

  /* ── confirm ── */
  if (!flags.yes && !flags.dryRun) {
    console.log('  Install locations:');
    for (var j = 0; j < targets.length; j++) {
      console.log('    \u2022 ' + targets[j].name + '  \u2192 ' + targets[j].agentDir);
    }
    console.log('');
    process.stdout.write('  Proceed? [Y/n] ');
    var answer = readAnswer();
    if (!answer) answer = 'y';
    if (answer === 'n' || answer === 'no') {
      console.log('  \u2717 Cancelled.');
      return;
    }
  }

  /* ── install ── */
  console.log('');
  spin('Installing...');
  console.log('');
  for (var k = 0; k < targets.length; k++) {
    var t = targets[k];
    if (flags.dryRun) {
      echo('\u2192', t.name + '  \u2192 ' + t.agentDir + ' (dry-run)');
    } else {
      var success = installTo(srcDir, t.agentDir);
      if (success) {
        ok(t.name + '  \u2192 ' + t.agentDir);
      } else {
        fail(t.name + '  \u2192 install failed');
      }
    }
  }

  /* ── GPT instructions ── */
  if (flags.gpt || (!flags.claude && !flags.codex)) {
    var gptDir = path.join(H, '.agents', 'skills', 'deepsight', '_platforms', 'openai');
    var gptFile = path.join(gptDir, 'gpt-instructions.md');
    if (!flags.dryRun) {
      fs.mkdirSync(gptDir, { recursive: true });
      fs.writeFileSync(gptFile, '# DeepSight GPT Instructions\n\nInstall DeepSight via: npx deepsight --gpt\n');
      ok('Custom GPT        \u2192 instructions generated');
    } else {
      echo('\u2192', 'Custom GPT        \u2192 ' + gptFile + ' (dry-run)');
    }
  }

  /* ── complete ── */
  console.log('');
  ok('DeepSight v' + VERSION + ' installed successfully!');
  console.log('');
  console.log('  Platform-specific setup:');
  console.log('    Claude:   /review this PR');
  console.log('    Codex:    read _platforms/openai/codex-instructions.md');
  console.log('    GPT:      read _platforms/openai/gpt-instructions.md');
  console.log('');
  console.log('  New to DeepSight?');
  console.log('    npx deepsight --help     Show this help');
  console.log('    npx deepsight --detect   Scan for AI platforms');
  console.log('    npx deepsight --dry-run  Preview installation');
  console.log('');
}

/* ───────── sync stdin reader ───────── */
function readAnswer() {
  try {
    var buf = Buffer.alloc(16);
    var bytes = fs.readSync(process.stdin.fd, buf, 0, 16, 0);
    return buf.toString('utf8', 0, bytes).trim().toLowerCase();
  } catch (e) {
    return 'y';
  }
}

main();
