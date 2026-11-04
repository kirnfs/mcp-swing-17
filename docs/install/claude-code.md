# Swing MCP in Claude Code

Video: <https://crosstech.solutions/swing-mcp#claude-code> (about a minute)

## 1. Prerequisites

- **JDK 17 or newer** on your `PATH` (`java -version` to check).
- **The two jars.** Download `swing-mcp.mcpb` from the
  [latest release](https://github.com/crosstech-solutions-bv/swing-mcp/releases/latest);
  it is a plain zip — unpack it and the jars are in `server/`:

  ```bash
  unzip swing-mcp.mcpb -d swing-mcp
  # swing-mcp/server/mcp-swing-17-server.jar
  # swing-mcp/server/mcp-swing-17-agent.jar
  ```

  (Windows: `tar -xf swing-mcp.mcpb`, or rename to `.zip` and extract. Building from
  source with `mvn verify` works too.) Use **absolute paths** to both jars below; on
  Windows escape backslashes in JSON (`C:\\tools\\swing-mcp\\server\\mcp-swing-17-server.jar`).

## 2. Install

One command (add `-s user` to make it available in every project instead of only this one):

```bash
claude mcp add swing \
  --env SWING_MCP_AGENT_JAR=/path/to/swing-mcp/server/mcp-swing-17-agent.jar \
  -- java -jar /path/to/swing-mcp/server/mcp-swing-17-server.jar
```

Output: `Added stdio MCP server swing with command: java -jar … to local config`.

## 3. Verify

```bash
claude mcp list
# swing: java -jar /path/to/swing-mcp/server/mcp-swing-17-server.jar - ✓ Connected
```

Inside a session, `/mcp` shows the server and its tools.

## 4. First prompt

> Launch `/path/to/my-app.jar` with Swing MCP, take a snapshot and tell me what is on screen.

The assistant calls `launch_app`, then `take_snapshot`, and from there clicks, fills and reads
by component `uid`. To drive an application that is already running, give it the process id
instead: *"Attach to PID 12345 and read the table in the main window."* The tool list is in
[../tool-reference.md](../tool-reference.md); the workflow patterns the assistant should follow
are in the bundled [skill](../../skills/swing-mcp/SKILL.md).

## 5. If it does not connect

- `java` must be JDK 17+ **on the PATH the client sees**. GUI apps often do not inherit your
  shell PATH — use an absolute path to the `java` binary in `command` if needed.
- `SWING_MCP_AGENT_JAR` must be an absolute path to an existing file, otherwise
  `launch_app`/`attach_to_app` fail.
- The server logs to `${java.io.tmpdir}/mcp-swing-17-server.log` (e.g. `/tmp/mcp-swing-17-server.log`,
  `%TEMP%\mcp-swing-17-server.log`). Nothing is written to stdout — that is the MCP channel.
- More options (ports, screenshot folder, timeouts, enabling `evaluate_java`) in
  [../installation.md](../installation.md#configuration-options).
