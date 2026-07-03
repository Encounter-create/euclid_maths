# 罗马军团开发体系 - 安装脚本
# 支持 Claude Code、Marvis 和手动安装
# 用法: .\install.ps1 [-Target <claude|marvis|both>] [-Scope <project|user>]
param(
    [ValidateSet("claude", "marvis", "both")]
    [string]$Target = "both",
    [ValidateSet("project", "user")]
    [string]$Scope = "project"
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  罗马军团开发体系 - 安装程序 v3" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 技能列表
# ============================================
$skills = @(
    @{Name="legion-workflow";     Desc="总纲 - 军团指挥中枢"},
    @{Name="legion-chancellor";   Desc="宰相 - 需求分析"},
    @{Name="legion-advisor";      Desc="参谋 - 技术方案"},
    @{Name="legion-general";      Desc="将军 - 任务调度"},
    @{Name="legion-centurions";   Desc="百夫长组 - 专业执行"}
)

# ============================================
# Claude Code 安装
# ============================================
function Install-ClaudeCode {
    Write-Host ">>> 安装到 Claude Code..." -ForegroundColor Yellow

    if ($Scope -eq "project") {
        $targetDir = Join-Path (Get-Location) ".claude\skills"
    } else {
        $targetDir = "$env:USERPROFILE\.claude\skills"
    }

    Write-Host "    目标目录: $targetDir" -ForegroundColor Gray

    foreach ($skill in $skills) {
        $skillName = $skill.Name
        $skillFile = Join-Path $scriptDir "$skillName.skill"
        $skillTargetDir = Join-Path $targetDir $skillName

        if (-not (Test-Path $skillFile)) {
            Write-Host "    [!] 找不到 $skillFile ，跳过" -ForegroundColor Red
            continue
        }

        # 创建目标目录
        New-Item -ItemType Directory -Force -Path $skillTargetDir | Out-Null

        # 解压 .skill (ZIP) 到目标目录
        Write-Host "    安装 $skillName ($($skill.Desc))..." -ForegroundColor Gray
        Expand-Archive -Path $skillFile -DestinationPath $skillTargetDir -Force

        Write-Host "    [OK] $skillName 安装完成" -ForegroundColor Green
    }

    # 复制 IMPROVEMENTS.md
    $improvementsSrc = Join-Path $scriptDir "IMPROVEMENTS.md"
    if (Test-Path $improvementsSrc) {
        $improvementsDst = Join-Path $targetDir "..\IMPROVEMENTS.md"
        Copy-Item $improvementsSrc $improvementsDst -Force
        Write-Host "    [OK] IMPROVEMENTS.md 已复制" -ForegroundColor Green
    }

    Write-Host "    Claude Code 安装完成！" -ForegroundColor Green
}

# ============================================
# Marvis 安装
# ============================================
function Install-Marvis {
    Write-Host ">>> 安装到 Marvis..." -ForegroundColor Yellow

    # Marvis 使用 .skill 文件（ZIP 格式），直接复制到 skills 目录
    $marvisBase = "$env:APPDATA\Tencent\Marvis\User"

    # 查找 Marvis 用户目录
    $userDirs = Get-ChildItem -Path $marvisBase -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "oAN1i2U*" }

    if (-not $userDirs) {
        Write-Host "    [!] 未找到 Marvis 用户目录，请手动指定路径" -ForegroundColor Red
        Write-Host "    手动安装：将 .skill 文件导入 Marvis 的技能管理界面" -ForegroundColor Yellow
        return
    }

    foreach ($userDir in $userDirs) {
        # Marvis 技能通常在工作区目录下
        $workspaces = Get-ChildItem -Path (Join-Path $userDir.FullName "workspace") -Directory -ErrorAction SilentlyContinue

        foreach ($ws in $workspaces) {
            $skillsDir = Join-Path $ws.FullName "skills"
            New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null

            foreach ($skill in $skills) {
                $src = Join-Path $scriptDir "$($skill.Name).skill"
                $dst = Join-Path $skillsDir "$($skill.Name).skill"

                if (Test-Path $src) {
                    Copy-Item $src $dst -Force
                    Write-Host "    [OK] $($skill.Name).skill → $skillsDir" -ForegroundColor Green
                }
            }
        }
    }

    Write-Host "    Marvis 安装完成！" -ForegroundColor Green
}

# ============================================
# 主流程
# ============================================
Write-Host "安装目标: $Target" -ForegroundColor White
Write-Host "安装范围: $Scope" -ForegroundColor White
Write-Host ""

if ($Target -eq "claude" -or $Target -eq "both") {
    Install-ClaudeCode
    Write-Host ""
}

if ($Target -eq "marvis" -or $Target -eq "both") {
    Install-Marvis
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  安装完成！现在可以启动军团了" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "启动军团：" -ForegroundColor White
Write-Host "  Claude Code:  加载 legion-workflow 技能后说 '启动军团，帮我做...'" -ForegroundColor Gray
Write-Host "  快速战役:      加载 legion-workflow 技能后说 '快速战役，帮我...'" -ForegroundColor Gray
Write-Host ""
Write-Host "单独使用角色：" -ForegroundColor White
Write-Host "  需求分析:      加载 legion-chancellor" -ForegroundColor Gray
Write-Host "  技术方案:      加载 legion-advisor" -ForegroundColor Gray
Write-Host "  任务分派:      加载 legion-general" -ForegroundColor Gray
Write-Host "  百夫长执行:    加载 legion-centurions" -ForegroundColor Gray
