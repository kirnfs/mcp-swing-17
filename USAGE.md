# mcp-swing-17 — build and usage

MCP server and Java agent for Swing/JavaFX on **JDK 17**. Examples are application-agnostic:
substitute your project path and PID.

## 1. Requirements

- JDK 17;
- Maven 3.9+ (or `build.ps1`, which downloads Maven 3.9.9);
- Windows, Linux or macOS;
- an MCP client with stdio support (LM Studio, Qwen Code, Claude Desktop, Cursor, etc.).

## 2. Build

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1
```

Output:

```
dist/mcp-swing-17-server.jar
dist/mcp-swing-17-agent.jar
```

With Maven directly:

```bash
mvn -s maven-settings.xml -DskipTests package
```

## 3. Start the MCP server

```powershell
$env:SWING_MCP_AGENT_JAR = "$PWD\dist\mcp-swing-17-agent.jar"
java -jar "$PWD\dist\mcp-swing-17-server.jar"
```

Usually the MCP client starts the server. Example configuration:

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

## 4. Attach to an application

1. Start the target Java application on JDK 17+.
2. Find its PID:

```powershell
Get-Process javaw -ErrorAction SilentlyContinue |
  Select-Object Id,MainWindowTitle
```

3. In the MCP client:

```text
attach_to_app(pid = <PID>)
list_windows
```

4. Useful tools:

```text
take_snapshot
find_component
click
fill
get_table_data
select_tree_node
activate_tree_node
handle_dialog
take_screenshot
close_window
```

## 5. Important tools

- `take_screenshot(mode="PAINT")` — render the window content without overlaps or title bar.
- `take_screenshot(mode="SCREEN")` — copy the screen region.
- `activate_tree_node` — select a node, expand its ancestors and double-click it. Use it for lazy
  trees whose children load only on activation.
- `close_window` without arguments closes the **focused dialog** only. The main frame requires an
  explicit `close_window(windowIndex=0)`.
- `robot:true` is disabled by default: the real mouse and OS keyboard are not captured.

## 6. Verify

```text
list_windows    → application windows
take_screenshot → PNG
```

Component UIDs are valid for one MCP session. Take a fresh `take_snapshot` after UI changes.

## 7. Troubleshooting

| Symptom | Solution |
|---|---|
| `UnsupportedClassVersionError` | run on JDK 17+ and use jars from `dist/` |
| `Failed to parse request` | rebuild with `build.ps1` |
| attach cannot find the JVM | check the PID and target Java version |
| port cannot be bound | free the `40000…40100` range |
| screenshot is empty | use `take_screenshot(mode="PAINT")` |
| `Robot input is disabled` | do not use `robot:true`; this is the safe default |

## 8. Security

- loopback only;
- keep `evaluate_java` disabled;
- do not embed the agent in a production application;
- do not share the token or the response file.
