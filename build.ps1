[CmdletBinding()]
param(
    [string]$MavenHome = ''
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$mavenVersion = '3.9.9'

function Resolve-Maven {
    param([string]$Requested)

    if ($Requested) {
        $candidate = Join-Path $Requested 'bin\mvn.cmd'
        if (Test-Path $candidate) { return $candidate }
        throw "Maven не найден: $candidate"
    }

    $command = Get-Command mvn.cmd, mvn -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { return $command.Source }

    $cache = Join-Path $root ".build\apache-maven-$mavenVersion"
    $cached = Join-Path $cache 'bin\mvn.cmd'
    if (Test-Path $cached) { return $cached }

    $build = Join-Path $root '.build'
    New-Item -ItemType Directory -Force -Path $build | Out-Null
    $zip = Join-Path $build "apache-maven-$mavenVersion-bin.zip"
    if (-not (Test-Path $zip)) {
        Write-Host "[maven] скачивание $mavenVersion..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri "https://archive.apache.org/dist/maven/maven-3/$mavenVersion/binaries/apache-maven-$mavenVersion-bin.zip" -OutFile $zip
    }
    Expand-Archive -LiteralPath $zip -DestinationPath $build -Force
    if (-not (Test-Path $cached)) { throw "Не удалось распаковать Maven: $cached" }
    return $cached
}

$mvn = Resolve-Maven -Requested $MavenHome
$settings = Join-Path $root 'maven-settings.xml'
$mavenArgs = @(
    '-s', $settings,
    '-Dmaven.compiler.release=17',
    '-DskipTests',
    'package'
)

Write-Host "[build] swing-mcp (server + agent, Java 17)" -ForegroundColor Cyan
Push-Location $root
try {
    & $mvn @mavenArgs
    if ($LASTEXITCODE -ne 0) { throw "Maven завершился с кодом $LASTEXITCODE" }
} finally {
    Pop-Location
}

$agentBuilt = Join-Path $root 'mcp-swing-17-agent\target\mcp-swing-17-agent-1.5.0-java17.jar'
$serverBuilt = Join-Path $root 'mcp-swing-17-server\target\mcp-swing-17-server-1.5.0-java17.jar'
foreach ($built in @($agentBuilt, $serverBuilt)) {
    if (-not (Test-Path $built)) { throw "Не найден собранный артефакт: $built" }
}
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$agentOut = Join-Path $dist 'mcp-swing-17-agent.jar'
$serverOut = Join-Path $dist 'mcp-swing-17-server.jar'
Copy-Item -LiteralPath $agentBuilt -Destination $agentOut -Force
Copy-Item -LiteralPath $serverBuilt -Destination $serverOut -Force
Write-Host "[done] $agentOut"
Write-Host "[done] $serverOut" -ForegroundColor Green
