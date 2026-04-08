# 构建后自动复制配置文件
# 在 build 目录构建后,自动将配置文件复制到 build 目录

$projectRoot = Split-Path -Parent $PSScriptRoot
$buildDir = Join-Path $projectRoot "build"
$configFile = "railway_debug_pg.ini"

$sourceConfig = Join-Path $projectRoot $configFile
$destConfig = Join-Path $buildDir $configFile

if (-not (Test-Path $sourceConfig)) {
    Write-Host "❌ 配置文件不存在: $sourceConfig" -ForegroundColor Red
    Write-Host "   请先运行: .\setup_database.ps1" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $buildDir)) {
    Write-Host "ℹ️  build 目录不存在,创建中..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

Copy-Item $sourceConfig $destConfig -Force
Write-Host "✅ 已复制配置文件到 build 目录" -ForegroundColor Green

# 显示配置文件位置
Write-Host ""
Write-Host "📁 配置文件位置:" -ForegroundColor Cyan
Write-Host "   源文件: $sourceConfig" -ForegroundColor Gray
Write-Host "   目标: $destConfig" -ForegroundColor Gray
Write-Host ""
