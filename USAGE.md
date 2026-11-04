# mcp-swing-17 — сборка и использование

MCP-сервер и агент для Java Swing/JavaFX на **JDK 17**. Примеры не привязаны к конкретному
приложению: подставить путь к своему проекту и PID.

## 1. Требования

- JDK 17;
- Maven 3.9+ (или `build.ps1`, который скачает Maven 3.9.9);
- Windows/Linux/macOS;
- MCP-клиент с поддержкой stdio (LM Studio, Qwen Code, Claude Desktop, Cursor и т. п.).

## 2. Сборка

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1
```

Результат:

```
dist/mcp-swing-17-server.jar
dist/mcp-swing-17-agent.jar
```

Через Maven без PowerShell:

```bash
mvn -s maven-settings.xml -DskipTests package
```

## 3. Запуск MCP-сервера

```powershell
$env:SWING_MCP_AGENT_JAR = "$PWD\dist\mcp-swing-17-agent.jar"
java -jar "$PWD\dist\mcp-swing-17-server.jar"
```

Обычно сервер запускает MCP-клиент. Пример конфигурации:

```json
{
  "mcpServers": {
    "mcp-swing-17": {
      "command": "java",
      "args": ["-jar", "<путь>/dist/mcp-swing-17-server.jar"],
      "env": {
        "SWING_MCP_AGENT_JAR": "<путь>/dist/mcp-swing-17-agent.jar"
      }
    }
  }
}
```

## 4. Подключение к приложению

1. Запустите целевое Java-приложение на JDK 17+.
2. Узнайте PID:

```powershell
Get-Process javaw -ErrorAction SilentlyContinue |
  Select-Object Id,MainWindowTitle
```

3. В MCP-клиенте:

```text
attach_to_app(pid = <PID>)
list_windows
```

4. Дальше:

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

## 5. Важные инструменты

- `take_screenshot(mode="PAINT")` — снимок содержимого окна без перекрытий и без заголовка.
- `take_screenshot(mode="SCREEN")` — копия области экрана.
- `activate_tree_node` — выбрать узел, раскрыть родителей и активировать его двойным кликом.
  Нужен для ленивых деревьев, где дети загружаются только при активации.
- `close_window` без аргументов закрывает **сфокусированный диалог**. Главное окно — только явным
  `close_window(windowIndex=0)`.
- `robot:true` по умолчанию отключён: реальная мышь и OS-клавиатура не перехватываются.

## 6. Проверка

```text
list_windows    → список окон приложения
take_screenshot → PNG
```

UID компонентов действуют в рамках одной MCP-сессии. После изменения UI берите свежий
`take_snapshot`.

## 7. Ошибки

| Симптом | Решение |
|---|---|
| `UnsupportedClassVersionError` | запускать на JDK 17+; использовать jar из `dist/` |
| `Failed to parse request` | пересобрать проект через `build.ps1` |
| attach не находит JVM | проверить PID и версию Java целевого процесса |
| порт не создаётся | освободить диапазон `40000…40100` |
| скриншот пустой | использовать `take_screenshot(mode="PAINT")` |
| `Robot input is disabled` | не использовать `robot:true`; это безопасный режим |

## 8. Безопасность

- только loopback;
- `evaluate_java` не включать;
- не встраивать агент в production-приложение;
- не передавать token/response-файл третьим лицам.
