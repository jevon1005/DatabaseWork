# PostgreSQL 驱动依赖检查和修复
# 检查 libpq.dll 是否存在,如不存在则提供下载指引

Write-Host "=== PostgreSQL 驱动检查 ===" -ForegroundColor Cyan
Write-Host ""

# 检查 QPSQL 驱动
$qpsqlPath = "D:\Qt\6.9.3\mingw_64\plugins\sqldrivers\qsqlpsql.dll"
if (Test-Path $qpsqlPath) {
    Write-Host "✅ QPSQL 驱动已安装" -ForegroundColor Green
} else {
    Write-Host "❌ QPSQL 驱动未找到!" -ForegroundColor Red
    Write-Host "   路径: $qpsqlPath" -ForegroundColor Yellow
    exit 1
}

# 检查 libpq.dll
$qtBinPath = "D:\Qt\6.9.3\mingw_64\bin"
$libpqFiles = Get-ChildItem $qtBinPath -Filter "*pq*.dll" -ErrorAction SilentlyContinue

if ($libpqFiles.Count -eq 0) {
    Write-Host "❌ libpq.dll 未找到!" -ForegroundColor Red
    Write-Host ""
    Write-Host "📥 解决方案:" -ForegroundColor Cyan
    Write-Host "   PostgreSQL 驱动需要 libpq.dll 才能工作" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   方法 1: 下载 PostgreSQL 二进制包" -ForegroundColor Yellow
    Write-Host "   1. 访问: https://www.enterprisedb.com/download-postgresql-binaries" -ForegroundColor Gray
    Write-Host "   2. 下载 Windows x86-64 ZIP 包" -ForegroundColor Gray
    Write-Host "   3. 解压后,将以下文件复制到 $qtBinPath :" -ForegroundColor Gray
    Write-Host "      - libpq.dll" -ForegroundColor Gray
    Write-Host "      - libcrypto-3-x64.dll" -ForegroundColor Gray
    Write-Host "      - libssl-3-x64.dll" -ForegroundColor Gray
    Write-Host "      - libiconv-2.dll" -ForegroundColor Gray
    Write-Host "      - libintl-9.dll" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   方法 2: 安装完整 PostgreSQL (不推荐,太大)" -ForegroundColor Yellow
    Write-Host "   安装后从 PostgreSQL\bin 复制 DLL" -ForegroundColor Gray
    Write-Host ""
    exit 1
} else {
    Write-Host "✅ libpq.dll 已安装" -ForegroundColor Green
    foreach ($file in $libpqFiles) {
        Write-Host "   - $($file.Name)" -ForegroundColor Gray
    }
}

# 检查 SSL 库
$sslFiles = @("libssl-3-x64.dll", "libcrypto-3-x64.dll")
$missingSsl = @()

foreach ($sslFile in $sslFiles) {
    if (-not (Test-Path (Join-Path $qtBinPath $sslFile))) {
        $missingSsl += $sslFile
    }
}

if ($missingSsl.Count -gt 0) {
    Write-Host "⚠️  缺少 SSL 库:" -ForegroundColor Yellow
    foreach ($file in $missingSsl) {
        Write-Host "   - $file" -ForegroundColor Gray
    }
    Write-Host "   这可能导致 sslmode=require 连接失败" -ForegroundColor Yellow
} else {
    Write-Host "✅ SSL 库完整" -ForegroundColor Green
}

Write-Host ""
Write-Host "📝 后续步骤:" -ForegroundColor Cyan
Write-Host "   如果缺少依赖,请安装后重新运行程序" -ForegroundColor Gray
Write-Host ""
