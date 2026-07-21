param([string]$Dir = "$env:APPDATA\Claude\agents\skills\deepsight")

$Repo = "DevAnimecx/DeepSight"
$Branch = "main"
$CodeDir = "$env:USERPROFILE\.agents\skills\deepsight"
$Version = "v0.1.1"

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "        DeepSight $Version Installer" -ForegroundColor Cyan
Write-Host "     AI-Powered Code Review -- Free" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

$destinations = @($Dir)
if ($CodeDir -ne $Dir) { $destinations += $CodeDir }

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
    $primary = $destinations[0]
    if (Test-Path $primary) { Remove-Item $primary -Recurse -Force -ErrorAction SilentlyContinue }
    git clone --depth 1 "https://github.com/$Repo.git" $primary
    if ($destinations.Count -gt 1 -and $destinations[1] -ne $primary) {
      $secondary = $destinations[1]
      New-Item -ItemType Directory -Path $secondary -Force | Out-Null
      Get-ChildItem -Path $primary | Copy-Item -Destination $secondary -Recurse -Force
      Write-Host "[OK] Installed to: $secondary" -ForegroundColor Green
    }
  } else {
    Write-Host "[FAIL] Install failed. Check your internet connection or install Git." -ForegroundColor Red
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
