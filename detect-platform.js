#!/usr/bin/env node
/**
 * DeepSight Platform Detector
 * Scans the system for installed AI platforms and returns a config object.
 * Usage: node detect-platform.js [--json]
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

const homedir = os.homedir();

function detectClaudeDesktop() {
  const paths = [];
  if (process.platform === 'win32') {
    const appdata = process.env.APPDATA || path.join(homedir, 'AppData', 'Roaming');
    paths.push(path.join(appdata, 'Claude'));
  } else if (process.platform === 'darwin') {
    paths.push(path.join(homedir, 'Library', 'Application Support', 'Claude'));
  } else {
    paths.push(path.join(process.env.XDG_CONFIG_HOME || path.join(homedir, '.config'), 'Claude'));
  }
  for (const p of paths) {
    if (fs.existsSync(p)) {
      const configPath = path.join(p, 'claude_desktop_config.json');
      return {
        detected: true,
        path: p,
        configPath: fs.existsSync(configPath) ? configPath : null,
        version: 'desktop'
      };
    }
  }
  return { detected: false };
}

function detectClaudeCode() {
  const paths = [
    path.join(homedir, '.claude'),
    path.join(homedir, '.agents')
  ];
  for (const p of paths) {
    if (fs.existsSync(p)) {
      return {
        detected: true,
        path: p,
        version: 'code'
      };
    }
  }
  return { detected: false };
}

function detectOpenAICodex() {
  const configDir = process.env.OPENAI_CONFIG || path.join(homedir, '.config', 'codex');
  const configPath = path.join(configDir, 'codex.json');
  if (fs.existsSync(configPath)) {
    return { detected: true, path: configDir, configPath };
  }
  return { detected: false };
}

function detectOpenAIGPT() {
  // Check for OPENAI_API_KEY in environment or common config files
  if (process.env.OPENAI_API_KEY) {
    return { detected: true, method: 'env', key: 'OPENAI_API_KEY' };
  }
  // Check common config files
  const configPaths = [
    path.join(homedir, '.openai', 'config.json'),
    path.join(homedir, '.config', 'openai', 'config.json')
  ];
  for (const p of configPaths) {
    if (fs.existsSync(p)) {
      return { detected: true, method: 'file', path: p };
    }
  }
  return { detected: false };
}

function detectAll() {
  return {
    timestamp: new Date().toISOString(),
    platform: process.platform,
    claude: {
      desktop: detectClaudeDesktop(),
      code: detectClaudeCode()
    },
    openai: {
      codex: detectOpenAICodex(),
      gpt: detectOpenAIGPT()
    }
  };
}

// CLI
const args = process.argv.slice(2);
const result = detectAll();

if (args.includes('--json')) {
  console.log(JSON.stringify(result, null, 2));
} else {
  console.log('=== DeepSight Platform Detector ===');
  console.log(System: \n);
  
  const cd = result.claude.desktop;
  console.log(Claude Desktop: );
  if (cd.detected) console.log(  Path: );
  
  const cc = result.claude.code;
  console.log(Claude Code:    );
  if (cc.detected) console.log(  Path: );
  
  const cx = result.openai.codex;
  console.log(OpenAI Codex:  );
  if (cx.detected) console.log(  Path: );
  
  const gpt = result.openai.gpt;
  console.log(OpenAI GPT:    );
  if (gpt.detected) console.log(  Method: );
}
