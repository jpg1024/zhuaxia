# ============================================================
# 抓虾 Todo 单文件 EXE 打包脚本
# 用法: powershell -ExecutionPolicy Bypass -File pack_single.ps1
#       -ReleaseDir <Release目录> -ToolsDir <tools目录> -IconPath <ico路径>
# 产物: <ReleaseDir>\zhuaxia_single.exe（双击直接运行，Win7 SP1 ~ Win11）
# ============================================================
param(
    [Parameter(Mandatory = $true)][string]$ReleaseDir,
    [Parameter(Mandatory = $true)][string]$ToolsDir,
    [Parameter(Mandatory = $true)][string]$IconPath
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

# 0. 前置检查
$appExe = Join-Path $ReleaseDir 'zhuaxia.exe'
if (-not (Test-Path $appExe)) {
    Write-Error "zhuaxia.exe not found in $ReleaseDir"
    exit 1
}
if (-not (Test-Path $IconPath)) {
    Write-Error "icon not found: $IconPath"
    exit 1
}

# 1. 清理旧产物与临时目录（防止把旧单文件打包进 zip）
$outExe = Join-Path $ReleaseDir 'zhuaxia_single.exe'
if (Test-Path $outExe) { Remove-Item -Force $outExe }
$tmp = Join-Path (Split-Path $ReleaseDir -Parent) 'single_tmp'
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
New-Item -ItemType Directory -Path $tmp | Out-Null

# 2. 压缩 Release 目录内容（不含顶层 Release 文件夹）到 package.zip
$zip = Join-Path $tmp 'package.zip'
[System.IO.Compression.ZipFile]::CreateFromDirectory(
    $ReleaseDir, $zip,
    [System.IO.Compression.CompressionLevel]::Optimal, $false)
Write-Output ("package.zip: {0} bytes" -f (Get-Item $zip).Length)

# 3. 编译自解压 stub（.NET 4.5+，无外部依赖）
$csc = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path $csc)) {
    $csc = 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe'
}
if (-not (Test-Path $csc)) {
    Write-Error 'csc.exe not found (.NET Framework SDK missing)'
    exit 1
}
$fwDir = Split-Path $csc -Parent
$stubCs = Join-Path $ToolsDir 'single_file_stub.cs'
if (-not (Test-Path $stubCs)) {
    Write-Error "stub source not found: $stubCs"
    exit 1
}

& $csc /nologo /optimize+ /target:winexe `
    "/win32icon:$IconPath" `
    "/resource:$zip,package.zip" `
    "/r:$fwDir\System.IO.Compression.dll" `
    "/r:$fwDir\System.IO.Compression.FileSystem.dll" `
    "/out:$outExe" $stubCs

if ($LASTEXITCODE -ne 0) {
    Write-Error "csc failed with exit code $LASTEXITCODE"
    exit 1
}

# 4. 清理临时目录
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }

# 5. 输出结果
$size = (Get-Item $outExe).Length
Write-Output ("single exe OK: {0}" -f $outExe)
Write-Output ("size: {0} bytes ({1:N1} MB)" -f $size, ($size / 1MB))
exit 0
