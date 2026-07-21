param([string]$Dir = "$env:APPDATA\Claude\agents\skills\deepsight")

$Repo = "DevAnimecx/DeepSight"
$Branch = "main"
$CodeDir = "$env:USERPROFILE\.agents\skills\deepsight"

Write-Host ""
Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        DeepSight v0.1.1 Installer         ║" -ForegroundColor Cyan
Write-Host "║     AI-Powered Code Review — Free         ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$destinations = @($Dir)
if ($CodeDir -ne $Dir) { $destinations += $CodeDir }

$tmp = "$env:TEMP\deepsight.zip"
$extractDir = "$env:TEMP\deepsight-extract"

try {
  Write-Host "Downloading DeepSight..." -ForegroundColor Blue
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -Uri "https://github.com/$Repo/archive/refs/heads/$Branch.zip" -OutFile $tmp -UseBasicParsing -ErrorAction Stop
  Expand-Archive -Path $tmp -DestinationPath $extractDir -Force -ErrorAction Stop

  $root = Get-ChildItem $extractDir | Select-Object -First 1
  if (-not $root) { throw "Extract failed" }

  foreach ($dest in $destinations) {
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Get-ChildItem -Path $root.FullName | Copy-Item -Destination $dest -Recurse -Force
    Write-Host "✓ Installed to: $dest" -ForegroundColor Green
  }

  Remove-Item $tmp -Force -ErrorAction SilentlyContinue
  Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
} catch {
  Write-Host "Download failed: $_" -ForegroundColor Red
  $git = Get-Command git -ErrorAction SilentlyContinue
  if ($git) {
    Write-Host "Falling back to git clone..." -ForegroundColor Yellow
    $primary = $destinations[0]
    if (Test-Path $primary) { Remove-Item $primary -Recurse -Force -ErrorAction SilentlyContinue }
    git clone --depth 1 "https://github.com/$Repo.git" $primary
    if ($destinations.Count -gt 1 -and $destinations[1] -ne $primary) {
      $secondary = $destinations[1]
      New-Item -ItemType Directory -Path $secondary -Force | Out-Null
      Get-ChildItem -Path $primary | Copy-Item -Destination $secondary -Recurse -Force
      Write-Host "✓ Installed to: $secondary" -ForegroundColor Green
    }
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
