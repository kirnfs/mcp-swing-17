# mcp-swing-17

MCP server and Java agent for automating Swing and JavaFX desktop applications, built for
**Java 17**. Fork of [Swing MCP](https://github.com/crosstech-solutions-bv/swing-mcp).

- Version: `1.5.0-java17`
- Upstream commit: `abfacfa`
- License: MIT (see `LICENSE`)
- Usage guide: [USAGE.md](USAGE.md)

## Contents

```
dist/mcp-swing-17-server.jar    MCP server (stdio)
dist/mcp-swing-17-agent.jar     Java agent loaded into the target JVM
build.ps1                       Windows build (JDK 17)
build.sh                        Linux/macOS build
mcp-swing-17-server/            server sources
mcp-swing-17-agent/             agent sources
mcp-swing-17-common/            shared classes
```

## Build

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1
```

Requires **JDK 17**. Maven 3.9.9 is downloaded into `.build/` on first use.

On Linux/macOS:

```bash
./build.sh
```

or:

```bash
mvn -s maven-settings.xml -DskipTests package
```

## Run

```text
SWING_MCP_AGENT_JAR=<path>/dist/mcp-swing-17-agent.jar
java -jar <path>/dist/mcp-swing-17-server.jar
```

The server uses stdio and is normally started by an MCP client. The agent attaches to an already
running Java application by PID through `attach_to_app`.

```json
{
  "mcpServers": {
    "mcp-swing-17": {
      "command": "java",
      "args": ["-jar", "<path>/dist/mcp-swing-17-server.jar"],
      "env": {
        "SWING_MCP_AGENT_JAR": "<path>/dist/mcp-swing-17-agent.jar"
      }
    }
  }
}
```

## Differences from upstream

1. Java 17 instead of Java 21: virtual threads replaced with a regular executor.
2. Removed the Java 17-incompatible `JMenu instanceof JMenuItem` pattern.
3. Replaced `List.getFirst()` with `get(0)`.
4. Relocated the agent's Jackson package so the target application's Jackson cannot shadow it.
5. `java.version=17`, JavaFX 17.
6. Real-mouse `robot` input is disabled by default.
7. `close_window` closes only the focused dialog unless a `windowIndex` is passed explicitly.

## Security

- the agent listens on loopback only;
- keep `evaluate_java` disabled;
- use as a development/testing tool;
- do not expose the agent port or the response-file token.
