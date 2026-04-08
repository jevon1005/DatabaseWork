# 数据库连接测试脚本
# 在配置完成后运行,验证连接是否正常

Write-Host ""
Write-Host "=== 数据库连接测试 ===" -ForegroundColor Cyan
Write-Host ""

# 检查配置文件
$configFile = "railway_debug_pg.ini"
if (-not (Test-Path $configFile)) {
    Write-Host "❌ 配置文件不存在: $configFile" -ForegroundColor Red
    Write-Host "   请先运行: .\setup_database.ps1" -ForegroundColor Yellow
    exit 1
}

# 读取配置
$config = Get-Content $configFile | Where-Object { $_ -match "^(host|port|database|user)=" }
$hostLine = $config | Where-Object { $_ -match "^host=" }
$portLine = $config | Where-Object { $_ -match "^port=" }

if ($hostLine -match "host=(.+)") { $host = $matches[1].Trim() }
if ($portLine -match "port=(.+)") { $port = $matches[1].Trim() }

Write-Host "📋 配置信息:" -ForegroundColor Cyan
Write-Host "   主机: $host" -ForegroundColor Gray
Write-Host "   端口: $port" -ForegroundColor Gray
Write-Host ""

# 测试网络连接
Write-Host "🔍 测试网络连接..." -ForegroundColor Cyan
try {
    $testResult = Test-NetConnection -ComputerName $host -Port $port -WarningAction SilentlyContinue
    
    if ($testResult.TcpTestSucceeded) {
        Write-Host "✅ 网络连接成功!" -ForegroundColor Green
        Write-Host "   主机可达,端口开放" -ForegroundColor Gray
    } else {
        Write-Host "❌ 网络连接失败!" -ForegroundColor Red
        Write-Host ""
        Write-Host "   可能原因:" -ForegroundColor Yellow
        Write-Host "   1. 主机地址错误" -ForegroundColor Gray
        Write-Host "   2. 端口号错误" -ForegroundColor Gray
        Write-Host "   3. 防火墙阻止连接" -ForegroundColor Gray
        Write-Host "   4. 网络环境限制(公司/学校网络)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "   排查步骤:" -ForegroundColor Yellow
        Write-Host "   - 检查配置文件中的 host 和 port" -ForegroundColor Gray
        Write-Host "   - 暂时关闭防火墙测试" -ForegroundColor Gray
        Write-Host "   - 尝试使用移动热点" -ForegroundColor Gray
        exit 1
    }
} catch {
    Write-Host "⚠️  测试失败: $_" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "📝 下一步:" -ForegroundColor Cyan
Write-Host "   运行程序,检查启动日志中的数据库连接状态" -ForegroundColor Gray
Write-Host "   - 成功: '✅ 成功连接到 Supabase 云数据库!'" -ForegroundColor Green
Write-Host "   - 失败: '❌ 数据库连接失败: <错误信息>'" -ForegroundColor Red
Write-Host ""

# DNS 解析测试
Write-Host "🔍 DNS 解析测试..." -ForegroundColor Cyan
try {
    $ipAddress = [System.Net.Dns]::GetHostAddresses($host)[0].IPAddressToString
    Write-Host "✅ DNS 解析成功: $host -> $ipAddress" -ForegroundColor Green
} catch {
    Write-Host "❌ DNS 解析失败: $_" -ForegroundColor Red
    Write-Host "   检查网络 DNS 设置" -ForegroundColor Yellow
}

Write-Host ""
