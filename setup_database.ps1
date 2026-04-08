# 数据库配置快速设置脚本
# 在新设备上运行此脚本进行初始配置

Write-Host "=== 高铁管理系统 - 数据库配置向导 ===" -ForegroundColor Cyan
Write-Host ""

# 检查配置文件是否存在
$configFile = "railway_debug_pg.ini"
$exampleFile = "railway_debug_pg.ini.example"

if (Test-Path $configFile) {
    Write-Host "⚠️  配置文件已存在: $configFile" -ForegroundColor Yellow
    $overwrite = Read-Host "是否覆盖? (y/N)"
    if ($overwrite -ne 'y' -and $overwrite -ne 'Y') {
        Write-Host "已取消。" -ForegroundColor Gray
        exit
    }
}

# 复制示例文件
if (Test-Path $exampleFile) {
    Copy-Item $exampleFile $configFile
    Write-Host "✅ 已创建配置文件: $configFile" -ForegroundColor Green
} else {
    Write-Host "❌ 找不到示例文件: $exampleFile" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📋 请填写 Supabase 数据库连接信息:" -ForegroundColor Cyan
Write-Host "   (可在 Supabase Dashboard → Settings → Database 中找到)" -ForegroundColor Gray
Write-Host ""

# 收集用户输入
$host = Read-Host "数据库主机 (如: aws-1-ap-southeast-2.pooler.supabase.com)"
$port = Read-Host "端口 (Pooler: 6543, Direct: 5432) [6543]"
if ([string]::IsNullOrWhiteSpace($port)) { $port = "6543" }

$database = Read-Host "数据库名 [postgres]"
if ([string]::IsNullOrWhiteSpace($database)) { $database = "postgres" }

$user = Read-Host "用户名 (如: postgres.xxxx)"
$password = Read-Host "密码" -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

$sslmode = Read-Host "SSL 模式 [require]"
if ([string]::IsNullOrWhiteSpace($sslmode)) { $sslmode = "require" }

# 写入配置文件
$content = @"
# Supabase 数据库连接配置
# 请勿将此文件提交到 Git (已加入 .gitignore)
# 生成时间: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

[postgres]
host=$host
port=$port
database=$database
user=$user
password=$passwordPlain
sslmode=$sslmode
"@

$content | Out-File -FilePath $configFile -Encoding UTF8

Write-Host ""
Write-Host "✅ 配置已保存到: $configFile" -ForegroundColor Green
Write-Host ""

# 测试网络连接
Write-Host "🔍 测试网络连接..." -ForegroundColor Cyan
try {
    $testResult = Test-NetConnection -ComputerName $host -Port $port -WarningAction SilentlyContinue
    if ($testResult.TcpTestSucceeded) {
        Write-Host "✅ 网络连接正常 (${host}:${port})" -ForegroundColor Green
    } else {
        Write-Host "❌ 无法连接到 ${host}:${port}" -ForegroundColor Red
        Write-Host "   请检查:" -ForegroundColor Yellow
        Write-Host "   1. 网络连接是否正常" -ForegroundColor Yellow
        Write-Host "   2. 防火墙是否阻止连接" -ForegroundColor Yellow
        Write-Host "   3. 主机地址和端口是否正确" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  无法测试连接: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📝 下一步:" -ForegroundColor Cyan
Write-Host "   1. 运行程序测试数据库连接" -ForegroundColor Gray
Write-Host "   2. 查看启动日志中的连接状态" -ForegroundColor Gray
Write-Host "   3. 如有问题,参阅 DATABASE_SETUP.md" -ForegroundColor Gray
Write-Host ""
