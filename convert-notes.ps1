# =============================================================
# convert-notes.ps1 —— 把 docx 笔记批量转成 GitHub 可预览的 Markdown
#
# 用法（在仓库根目录执行）：
#   .\convert-notes.ps1              转换所有文件夹里的 docx
#   .\convert-notes.ps1 -Folder docker   只转换 docker 文件夹
#   .\convert-notes.ps1 -DryRun      只看会转换哪些文件，不实际执行
#
# 转换后：docx 同级生成同名 .md，图片提取到 media/ 文件夹
# =============================================================

param(
    [string]$Folder = ".",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# ---- 定位 pandoc ----
$pandoc = @(
    "$env:LOCALAPPDATA\Pandoc\pandoc.exe",
    "$env:ProgramFiles\Pandoc\pandoc.exe",
    "${env:ProgramFiles(x86)}\Pandoc\pandoc.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $pandoc) {
    Write-Host "找不到 pandoc。请先安装：" -ForegroundColor Red
    Write-Host "  winget install --id JohnMacFarlane.Pandoc -e" -ForegroundColor Yellow
    exit 1
}

$utf8 = New-Object System.Text.UTF8Encoding($false)
$root = (Resolve-Path $Folder).Path

# ---- 找出所有 docx（排除 .git 和 Word 临时文件）----
$docx = Get-ChildItem -Path $root -Recurse -Filter *.docx -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.Name -notmatch '^~\$' }

if (-not $docx) {
    Write-Host "没有找到 docx 文件。" -ForegroundColor Yellow
    exit 0
}

Write-Host "找到 $($docx.Count) 个 docx 文件`n" -ForegroundColor Cyan

$okCount = 0; $failCount = 0; $imgTotal = 0

foreach ($f in $docx) {
    $dir  = $f.DirectoryName
    $base = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
    $rel  = $f.FullName.Replace("$root\", "")

    if ($DryRun) {
        Write-Host "  [将转换] $rel  ->  $base.md" -ForegroundColor Gray
        continue
    }

    # 同一文件夹里有多个 docx 时，图片分开放，避免互相覆盖
    $docxInDir = @(Get-ChildItem $dir -Filter *.docx -File).Count
    $mediaOpt  = if ($docxInDir -gt 1) { $base } else { "." }

    Push-Location $dir
    try {
        & $pandoc $f.Name -t gfm -o "$base.md" --extract-media=$mediaOpt 2>&1 | Out-Null

        if ($LASTEXITCODE -ne 0) {
            Write-Host "  [失败] $rel" -ForegroundColor Red
            $failCount++
            continue
        }

        # 把 pandoc 输出的 <img src="x" style="..." /> 转成标准 markdown ![](x)
        # 注意：.NET 的 File/WriteAllText 用的是「进程当前目录」，与 Push-Location
        # 不同步，所以这里必须用绝对路径，否则会写到仓库根目录去。
        $mdPath = Join-Path $dir "$base.md"
        $c = Get-Content -LiteralPath $mdPath -Raw -Encoding utf8
        $imgCount = ([regex]::Matches($c, '<img')).Count
        if ($imgCount -gt 0) {
            $c = [regex]::Replace($c, '(?s)<img\s+src="([^"]+)"[^>]*?/>', '![]($1)')
            $c = $c -replace '\]\(\./', ']('
            [System.IO.File]::WriteAllText($mdPath, $c, $utf8)
        }

        # 校验图片链接是否都能对上
        $missing = 0
        foreach ($m in [regex]::Matches($c, '!\[[^\]]*\]\(([^)]+)\)')) {
            $p = Join-Path $dir ($m.Groups[1].Value -replace '/', '\')
            if (-not (Test-Path $p)) { $missing++ }
        }

        if ($missing -gt 0) {
            Write-Host "  [完成但有 $missing 个图片链接失效] $rel  ->  $base.md" -ForegroundColor Yellow
        } else {
            Write-Host "  [完成] $rel  ->  $base.md   (图片 $imgCount 张)" -ForegroundColor Green
        }
        $imgTotal += $imgCount
        $okCount++
    }
    finally { Pop-Location }
}

if (-not $DryRun) {
    Write-Host "`n共转换 $okCount 个，失败 $failCount 个，提取图片 $imgTotal 张" -ForegroundColor Cyan
    Write-Host "`n接着执行：" -ForegroundColor Cyan
    Write-Host "  git add ." -ForegroundColor White
    Write-Host "  git status        # 确认清单" -ForegroundColor White
    Write-Host "  git commit -m `"更新笔记`"" -ForegroundColor White
    Write-Host "  git push" -ForegroundColor White
}
