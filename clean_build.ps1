# 清理构建文件脚本
# 在项目根目录运行,清理所有 CMake 和 Qt 构建产物

Write-Host ""
Write-Host "=== 清理构建文件 ===" -ForegroundColor Cyan
Write-Host ""

$rootDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($rootDir)) {
    $rootDir = Get-Location
}

Set-Location $rootDir

# 构建产物列表
$itemsToRemove = @(
    # CMake 文件
    "CMakeCache.txt",
    "CMakeFiles",
    "cmake_install.cmake",
    ".cmake",
    
    # Ninja 构建
    "build.ninja",
    ".ninja_deps",
    ".ninja_log",
    
    # Qt 自动生成
    "appRailwaySystem_autogen",
    "*_autogen",
    
    # 可执行文件
    "*.exe",
    "*.dll",
    
    # Qt Creator 临时文件
    ".qt",
    ".qtc",
    ".qtcreator",
    ".qtc_clangd",
    
    # 测试输出
    "Testing"
)

$removedCount = 0
$failedCount = 0

foreach ($item in $itemsToRemove) {
    $matches = Get-ChildItem -Path . -Filter $item -Force -ErrorAction SilentlyContinue
    
    foreach ($match in $matches) {
        try {
            if ($match.PSIsContainer) {
                Write-Host "删除目录: $($match.Name)" -ForegroundColor Yellow
                Remove-Item -Path $match.FullName -Recurse -Force
            } else {
                Write-Host "删除文件: $($match.Name)" -ForegroundColor Gray
                Remove-Item -Path $match.FullName -Force
            }
            $removedCount++
        } catch {
            Write-Host "失败: $($match.Name) - $_" -ForegroundColor Red
            $failedCount++
        }
    }
}

Write-Host ""
if ($removedCount -gt 0) {
    Write-Host "✅ 已删除 $removedCount 个文件/目录" -ForegroundColor Green
} else {
    Write-Host "ℹ️  没有找到需要清理的文件" -ForegroundColor Cyan
}

if ($failedCount -gt 0) {
    Write-Host "❌ 失败 $failedCount 个" -ForegroundColor Red
}

Write-Host ""
Write-Host "📝 保留的重要文件:" -ForegroundColor Cyan
Write-Host "   - 所有源代码 (.cpp, .h, .qml)" -ForegroundColor Gray
Write-Host "   - CMakeLists.txt" -ForegroundColor Gray
Write-Host "   - railway_debug_pg.ini (数据库配置)" -ForegroundColor Gray
Write-Host "   - 文档和资源文件" -ForegroundColor Gray
Write-Host ""

$rebuild = Read-Host "是否立即重新构建? (y/N)"
if ($rebuild -eq 'y' -or $rebuild -eq 'Y') {
    Write-Host ""
    Write-Host "🔨 开始重新构建..." -ForegroundColor Cyan
    
    # 创建 build 目录
    if (Test-Path "build") {
        Remove-Item -Recurse -Force build
    }
    New-Item -ItemType Directory -Path "build" | Out-Null
    
    # 复制配置文件到 build 目录
    if (Test-Path "railway_debug_pg.ini") {
        Copy-Item "railway_debug_pg.ini" "build\" -Force
        Write-Host "✅ 已复制配置文件到 build 目录" -ForegroundColor Green
    } else {
        Write-Host "⚠️  警告: 配置文件 railway_debug_pg.ini 不存在" -ForegroundColor Yellow
        Write-Host "   请在构建后运行: .\setup_database.ps1" -ForegroundColor Yellow
    }
    
    Set-Location build
    
    # 配置 CMake
    Write-Host "配置 CMake..." -ForegroundColor Gray
    cmake .. -G "Ninja"
    
    if ($LASTEXITCODE -eq 0) {
        # 构建
        Write-Host "构建项目..." -ForegroundColor Gray
        cmake --build .
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ 构建成功!" -ForegroundColor Green
            Write-Host "可执行文件: build\appRailwaySystem.exe" -ForegroundColor Cyan
        } else {
            Write-Host ""
            Write-Host "❌ 构建失败" -ForegroundColor Red
        }
    } else {
        Write-Host ""
        Write-Host "❌ CMake 配置失败" -ForegroundColor Red
    }
    
    Set-Location ..
} else {
    Write-Host "跳过重新构建" -ForegroundColor Gray
}

Write-Host ""
