param([string]$Dir = "$env:USERPROFILE\.agents\skills\deepsight")

$Repo = "DevAnimecx/DeepSight"
$Branch = "main"
$Version = "v0.2.1"
$DesktopDir = "$env:APPDATA\Claude\agents\skills\deepsight"
$CodeDir = "$env:USERPROFILE\.agents\skills\deepsight"

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "    DeepSight v0.2.1 Universal Installer" -ForegroundColor Cyan
Write-Host "   AI-Powered Code Review -- Free" -ForegroundColor Cyan
Write-Host "   Supports: Claude, Codex CLI, GPT" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

$destinations = @()
if (Test-Path "$env:APPDATA\Claude") { 
  $destinations += $DesktopDir
  Write-Host "[DETECT] Claude Desktop found" -ForegroundColor Green
}
if (Get-Command claude -ErrorAction SilentlyContinue) { 
  $destinations += $CodeDir
  Write-Host "[DETECT] Claude Code found" -ForegroundColor Green
}
$destinations += $Dir

$tmp = Join-Path $env:TEMP "deepsight-$([System.IO.Path]::GetRandomFileName()).zip"
$extractDir = Join-Path $env:TEMP "deepsight-$([System.IO.Path]::GetRandomFileName())"

try {
  Write-Host "[...] Downloading DeepSight..." -ForegroundColor Blue
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
  Invoke-WebRequest -Uri "https://github.com/$Repo/archive/refs/heads/$Branch.zip" -OutFile $tmp -UseBasicParsing -ErrorAction Stop
  Write-Host "[OK]" -ForegroundColor Green

  Write-Host "[...] Extracting..." -ForegroundColor Blue
  Expand-Archive -Path $tmp -DestinationPath $extractDir -Force -ErrorAction Stop

  $root = Get-ChildItem $extractDir | Select-Object -First 1
  if (-not $root) { throw "Extract failed: empty archive" }

  $fileCount = (Get-ChildItem -Path $root.FullName -Recurse -File | Measure-Object).Count
  if ($fileCount -eq 0) { throw "Extract failed: no files found" }
  Write-Host "[OK] $fileCount files" -ForegroundColor Green

  foreach ($dest in $destinations) {
    Write-Host "[...] Installing to: $dest" -ForegroundColor Blue
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Get-ChildItem -Path $root.FullName | Copy-Item -Destination $dest -Recurse -Force
    Write-Host "[OK]" -ForegroundColor Green
  }

  Remove-Item $tmp -Force -ErrorAction SilentlyContinue
  Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
} catch {
  Write-Host "[FAIL] Download failed: $_" -ForegroundColor Red
  $git = Get-Command git -ErrorAction SilentlyContinue
  if ($git) {
    Write-Host "[...] Falling back to git clone..." -ForegroundColor Yellow
    $primary = $dir
    if (Test-Path $primary) { Remove-Item $primary -Recurse -Force -ErrorAction SilentlyContinue }
    git clone --depth 1 "https://github.com/$Repo.git" $primary
    foreach ($dest in $destinations) {
      if ($dest -ne $primary) {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        Get-ChildItem -Path $primary | Copy-Item -Destination $dest -Recurse -Force
      }
    }
  } else {
    Write-Host "[FAIL] Install failed. Check your internet connection or install Git." -ForegroundColor Red
    exit 1
  }
}

Write-Host ""
Write-Host "DeepSight $Version installed!" -ForegroundColor Green
Write-Host ""

Write-Host "Platform-Specific Setup:" -ForegroundColor Cyan
Write-Host ""
if (Test-Path "$env:APPDATA\Claude") {
  Write-Host "Claude:" -ForegroundColor Blue
  Write-Host "  Next review: /review this PR" -ForegroundColor Gray
  Write-Host "  Audit:       /audit security of src/" -ForegroundColor Gray
  Write-Host ""
}
if ($env:OPENAI_API_KEY) {
  Write-Host "OpenAI GPT: API key detected" -ForegroundColor Blue
  Write-Host "  Instructions: _platforms/openai/gpt-instructions.md" -ForegroundColor Gray
  Write-Host ""
}

Write-Host "One-liner:" -ForegroundColor Yellow
Write-Host "  powershell -c ""iwr -useb https://raw.githubusercontent.com/DevAnimecx/DeepSight/$Branch/install.ps1 | iex""" -ForegroundColor Gray
Write-Host "  (Run from CMD or PowerShell)" -ForegroundColor Gray
Write-Host ""
Write-Host "New in v0.2.1: Universal AI Skill Platform" -ForegroundColor Cyan
Write-Host "  - Works with Claude Desktop, Claude Code, OpenAI Codex CLI, Custom GPT" -ForegroundColor Gray
Write-Host "  - 10 agents including new Dependency Auditor" -ForegroundColor Gray
Write-Host "  - Auto-detect your AI platforms" -ForegroundColor Gray
Write-Host ""
