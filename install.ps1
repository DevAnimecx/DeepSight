param([string]$Dir = "$env:USERPROFILE\.agents\skills\deepsight")

$Repo = "DevAnimecx/DeepSight"
$Branch = "main"

Write-Host ""
Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        DeepSight v0.1.1 Installer         ║" -ForegroundColor Cyan
Write-Host "║     AI-Powered Code Review — Free         ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $Dir)) { New-Item -ItemType Directory -Path $Dir -Force | Out-Null }

$tmp = "$env:TEMP\deepsight.zip"
$extractDir = "$env:TEMP\deepsight-extract"

try {
  Write-Host "Downloading DeepSight..." -ForegroundColor Blue
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -Uri "https://github.com/$Repo/archive/refs/heads/$Branch.zip" -OutFile $tmp -UseBasicParsing -ErrorAction Stop
  Expand-Archive -Path $tmp -DestinationPath $extractDir -Force -ErrorAction Stop

  $root = Get-ChildItem $extractDir | Select-Object -First 1
  if (-not $root) { throw "Extract failed" }

  Get-ChildItem -Path $root.FullName | Copy-Item -Destination $Dir -Recurse -Force
  Remove-Item $tmp -Force -ErrorAction SilentlyContinue
  Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue

  Write-Host "✓ DeepSight v0.1.1 installed to: $Dir" -ForegroundColor Green
} catch {
  Write-Host "Download failed: $_" -ForegroundColor Red
  $git = Get-Command git -ErrorAction SilentlyContinue
  if ($git) {
    Write-Host "Falling back to git clone..." -ForegroundColor Yellow
    if (Test-Path $Dir) { Remove-Item $Dir -Recurse -Force -ErrorAction SilentlyContinue }
    git clone --depth 1 "https://github.com/$Repo.git" $Dir
  } else {
    Write-Host "Install failed. Check connection or install git." -ForegroundColor Red
    exit 1
  }
}

Write-Host ""
Write-Host "Quick Start:" -ForegroundColor Cyan
Write-Host "  /review this PR"
Write-Host "  /audit security of src/"
Write-Host ""
Write-Host "One-liner:" -ForegroundColor Yellow
Write-Host "  iwr -useb https://raw.githubusercontent.com/DevAnimecx/DeepSight/$Branch/install.ps1 | iex" -ForegroundColor Gray
Write-Host ""
