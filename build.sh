#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

mvn -s maven-settings.xml -Dmaven.compiler.release=17 -DskipTests package
mkdir -p dist
cp mcp-swing-17-agent/target/mcp-swing-17-agent-1.5.0-java17.jar dist/mcp-swing-17-agent.jar
cp mcp-swing-17-server/target/mcp-swing-17-server-1.5.0-java17.jar dist/mcp-swing-17-server.jar
printf 'Built:\n  %s\n  %s\n' "$ROOT/dist/mcp-swing-17-agent.jar" "$ROOT/dist/mcp-swing-17-server.jar"
