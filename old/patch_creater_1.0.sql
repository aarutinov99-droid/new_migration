#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Упаковка директории патча в ZIP-архив через внешний архиватор.
Полная поддержка UTF-8 + счётчик версий + конфигурационный файл.

Конфигурация (JSON) задаёт:
    - output_dir      — папка для результирующих архивов
    - counter_file    — путь к файлу со счётчиком версий
    - tool            — архиватор: "7z" | "winrar" | "tar" (или null — автопоиск)
    - tool_path       — явный путь к exe архиватора (необязательно)
    - name            — базовое имя архива (необязательно)
    - level           — уровень сжатия 0-9
    - include_root    — включать ли корневую папку в архив
    - password        — пароль на архив (необязательно)
    - timestamp       — добавлять ли дату-время в имя архива
    - bump            — какую часть semver инкрементировать: major|minor|patch

Приоритет: CLI-аргумент > значение из конфига > встроенное значение по умолчанию.

Пример конфига (pack_config.json):
    {
        "output_dir": "./dist",
        "counter_file": "./state/patch_version_counter.json",
        "tool": "7z",
        "tool_path": null,
        "name": null,
        "level": 9,
        "include_root": true,
        "password": null,
        "timestamp": false,
        "bump": "patch"
    }
"""

import argparse
import io
import json
import locale
import os
import re
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path
from typing import Any


# =====================================================================
#  UTF-8
# =====================================================================

def setup_utf8_environment() -> None:
    """Принудительно включает UTF-8 для файловой системы, потоков и подпроцессов."""
    os.environ.setdefault("PYTHONUTF8", "1")
    os.environ.setdefault("PYTHONIOENCODING", "utf-8")

    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
        sys.stdin.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, io.UnsupportedOperation):
        sys.stdout = io.TextIOWrapper(
            sys.stdout.buffer, encoding="utf-8", errors="replace", line_buffering=True
        )
        sys.stderr = io.TextIOWrapper(
            sys.stderr.buffer, encoding="utf-8", errors="replace", line_buffering=True
        )

    if os.name == "nt":
        try:
            import ctypes
            kernel32 = ctypes.windll.kernel32
            kernel32.SetConsoleOutputCP(65001)
            kernel32.SetConsoleCP(65001)
        except Exception:
            pass


def subprocess_utf8_env() -> dict:
    env = os.environ.copy()
    env["PYTHONUTF8"] = "1"
    env["PYTHONIOENCODING"] = "utf-8"
    if os.name == "nt":
        env.setdefault("LANG", "ru_RU.UTF-8")
    return env


# =====================================================================
#  Конфигурация
# =====================================================================

DEFAULT_CONFIG_NAME = "pack_config.json"

# Значения по умолчанию (используются, если нет ни в CLI, ни в конфиге)
DEFAULTS: dict[str, Any] = {
    "output_dir":   "./dist",
    "counter_file": None,        # None → <output>/<имя_директории>_version_counter.json
    "tool":         None,        # None → автопоиск
    "tool_path":    None,
    "name":         None,        # None → имя директории-источника
    "level":        9,
    "include_root": True,
    "password":     None,
    "timestamp":    False,
    "bump":         "patch",
    "version":      None,        # можно зафиксировать версию в конфиге
    "no_build":     False,       # отключить build-номер в имени архива
}

# Какие ключи допустимы в конфиге
ALLOWED_KEYS = set(DEFAULTS.keys())


class ConfigError(Exception):
    """Ошибка разбора/валидации конфигурации."""


def load_config(config_path: Path) -> dict[str, Any]:
    """
    Читает JSON-конфиг. Возвращает словарь с известными ключами.
    Неизвестные ключи — предупреждение (не ошибка).
    """
    if not config_path.is_file():
        raise ConfigError(f"Файл конфигурации не найден: {config_path}")

    try:
        with config_path.open("r", encoding="utf-8") as f:
            raw = json.load(f)
    except json.JSONDecodeError as e:
        raise ConfigError(f"Ошибка разбора JSON '{config_path}': {e}") from e
    except OSError as e:
        raise ConfigError(f"Не удалось прочитать '{config_path}': {e}") from e

    if not isinstance(raw, dict):
        raise ConfigError(f"Корень конфига должен быть объектом JSON: {config_path}")

    unknown = set(raw.keys()) - ALLOWED_KEYS
    if unknown:
        print(f"[i] В конфиге '{config_path}' неизвестные ключи: "
              f"{', '.join(sorted(unknown))} (пропущены)")

    cfg = dict(DEFAULTS)
    for k, v in raw.items():
        if k in ALLOWED_KEYS:
            cfg[k] = v
    return cfg


def find_default_config(explicit: str | None, script_dir: Path, cwd: Path) -> Path | None:
    """
    Ищет конфиг:
      1) явно указанный путь (--config);
      2) <cwd>/pack_config.json
      3) <папка_скрипта>/pack_config.json
    Возвращает None, если ничего не найдено.
    """
    if explicit:
        p = Path(explicit).resolve()
        if not p.is_file():
            raise ConfigError(f"Указанный конфиг не найден: {p}")
        return p

    for candidate in (cwd / DEFAULT_CONFIG_NAME, script_dir / DEFAULT_CONFIG_NAME):
        if candidate.is_file():
            return candidate.resolve()
    return None


def resolve_relative_to(path_value: str, base_dir: Path) -> Path:
    """Разрешает относительный путь относительно base_dir."""
    p = Path(path_value)
    if not p.is_absolute():
        p = (base_dir / p).resolve()
    else:
        p = p.resolve()
    return p


# =====================================================================
#  Счётчик версий
# =====================================================================

COUNTER_SUFFIX = "_version_counter.json"


def sanitize_for_filename(name: str) -> str:
    cleaned = re.sub(r'[<>:"/\\|?*\x00-\x1f]', "_", name).strip(" .")
    return cleaned or "patch"


def make_counter_path(output_dir: Path, source_dir_name: str) -> Path:
    safe = sanitize_for_filename(source_dir_name)
    return (output_dir / f"{safe}{COUNTER_SUFFIX}").resolve()


def counter_files_in(output_dir: Path) -> list[Path]:
    if not output_dir.exists():
        return []
    return sorted(output_dir.glob(f"*{COUNTER_SUFFIX}"))


class VersionCounter:
    HISTORY_LIMIT = 50

    def __init__(self, counter_path: Path, source_dir: Path | None = None):
        self.path = counter_path
        self.source_dir = source_dir
        self.build = 0
        self.last_version = None
        self.history: list[dict] = []
        self._load()

    def _load(self) -> None:
        if not self.path.is_file():
            return
        try:
            with self.path.open("r", encoding="utf-8") as f:
                data = json.load(f)
            self.build = int(data.get("build", 0))
            self.last_version = data.get("last_version")
            self.history = list(data.get("history", []))
        except (json.JSONDecodeError, OSError, ValueError) as e:
            print(f"[!] Не удалось прочитать счётчик '{self.path}': {e}", file=sys.stderr)
            print("[i] Начинаю счёт заново с 0.", file=sys.stderr)
            self.build = 0
            self.last_version = None
            self.history = []

    def _save(self) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        data = {
            "source_name": self.path.name[:-len(COUNTER_SUFFIX)]
                if self.path.name.endswith(COUNTER_SUFFIX) else self.path.stem,
            "source_path": str(self.source_dir) if self.source_dir else None,
            "build": self.build,
            "last_version": self.last_version,
            "history": self.history[-self.HISTORY_LIMIT:],
        }
        tmp_fd, tmp_name = tempfile.mkstemp(
            prefix=self.path.name + ".", suffix=".tmp", dir=str(self.path.parent),
        )
        try:
            with os.fdopen(tmp_fd, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
                f.flush()
                os.fsync(f.fileno())
            os.replace(tmp_name, self.path)
        except Exception:
            try:
                os.unlink(tmp_name)
            except OSError:
                pass
            raise

    def next_build(self) -> int:
        return self.build + 1

    def commit(self, version: str, archive_name: str) -> int:
        self.build += 1
        self.last_version = version
        self.history.append({
            "build": self.build,
            "version": version,
            "archive": archive_name,
            "created": datetime.now().isoformat(timespec="seconds"),
        })
        self._save()
        return self.build

    def set_build(self, value: int) -> None:
        self.build = int(value)
        self._save()


# =====================================================================
#  Архиваторы
# =====================================================================

def _which(candidates):
    for c in candidates:
        path = shutil.which(c)
        if path:
            return Path(path)
    return None


def find_7zip():
    exe = _which(["7z", "7z.exe"])
    if exe:
        return exe
    for c in (
        r"C:\Program Files\7-Zip\7z.exe",
        r"C:\Program Files (x86)\7-Zip\7z.exe",
        os.path.expandvars(r"%LOCALAPPDATA%\Programs\7-Zip\7z.exe"),
    ):
        p = Path(c)
        if p.is_file():
            return p
    return None


def find_winrar():
    exe = _which(["rar", "rar.exe"])
    if exe:
        return exe
    for c in (
        r"C:\Program Files\WinRAR\Rar.exe",
        r"C:\Program Files (x86)\WinRAR\Rar.exe",
    ):
        p = Path(c)
        if p.is_file():
            return p
    return None


def find_tar():
    return _which(["tar", "tar.exe"])


TOOLS = {
    "7z":     find_7zip,
    "winrar": find_winrar,
    "tar":    find_tar,
}


def detect_tool(preferred: str | None = None):
    if preferred:
        if preferred not in TOOLS:
            raise ValueError(f"Неизвестный архиватор: {preferred}")
        exe = TOOLS[preferred]()
        if not exe:
            raise FileNotFoundError(
                f"Архиватор '{preferred}' не найден. "
                f"Установите его или укажите tool_path в конфиге."
            )
        return preferred, exe

    for name in ("7z", "winrar", "tar"):
        exe = TOOLS[name]()
        if exe:
            return name, exe

    raise FileNotFoundError(
        "Не найден ни один архиватор (7-Zip, WinRAR, tar). "
        "Установите 7-Zip или используйте встроенный tar из Windows 10/11."
    )


def tool_from_exe_path(exe: Path) -> str:
    """Определяет тип архиватора по имени exe."""
    low = exe.name.lower()
    if "7z" in low:
        return "7z"
    if "rar" in low:
        return "winrar"
    if "tar" in low:
        return "tar"
    raise ValueError(f"Не удалось определить тип архиватора по имени: {exe.name}")


def resolve_tool(cfg_tool: str | None, cfg_tool_path: str | None,
                 base_dir: Path) -> tuple[str, Path]:
    """Определяет архиватор с учётом конфига."""
    if cfg_tool_path:
        exe = resolve_relative_to(cfg_tool_path, base_dir)
        if not exe.is_file():
            raise FileNotFoundError(f"Архиватор не найден по пути: {exe}")
        tool = tool_from_exe_path(exe)
        return tool, exe
    return detect_tool(cfg_tool)


# =====================================================================
#  Semver
# =====================================================================

def parse_version(version_str: str):
    parts = version_str.strip().split(".")
    if not all(p.isdigit() for p in parts):
        raise ValueError(f"Некорректная версия: {version_str}")
    return tuple(int(p) for p in parts)


def format_version(v) -> str:
    return ".".join(str(p) for p in v)


def bump_version(v, part: str = "patch"):
    major, minor, patch = (list(v) + [0, 0, 0])[:3]
    if part == "major":
        return (major + 1, 0, 0)
    if part == "minor":
        return (major, minor + 1, 0)
    return (major, minor, patch + 1)


def get_existing_versions(output_dir: Path, name: str):
    versions = []
    pattern = re.compile(
        rf"^{re.escape(name)}-v(\d+\.\d+\.\d+)(?:-b(\d+))?\.zip$", re.IGNORECASE,
    )
    if not output_dir.exists():
        return versions
    for entry in output_dir.iterdir():
        m = pattern.match(entry.name)
        if not m:
            continue
        try:
            ver = parse_version(m.group(1))
        except ValueError:
            continue
        build = int(m.group(2)) if m.group(2) else None
        versions.append((ver, build))
    return versions


def determine_next_version(output_dir: Path, name: str, bump: str = "patch"):
    existing = get_existing_versions(output_dir, name)
    if not existing:
        return (0, 0, 1)
    latest = max(v for v, _ in existing)
    return bump_version(latest, bump)


def max_build_in_output(output_dir: Path, name: str) -> int:
    builds = [b for _, b in get_existing_versions(output_dir, name) if b is not None]
    return max(builds, default=0)


# =====================================================================
#  Запуск архиватора
# =====================================================================

def build_command(tool: str, exe: Path, source_dir: Path, archive_path: Path,
                  include_root: bool, password: str | None,
                  compression_level: int | None) -> tuple[list[str], Path]:
    if tool == "7z":
        cmd = [str(exe), "a", "-tzip", "-y", "-mcu=on"]
        if compression_level is not None:
            cmd.append(f"-mx={compression_level}")
        if password:
            cmd.append(f"-p{password}")
        cmd.append(str(archive_path))
        if include_root:
            return cmd + [source_dir.name], source_dir.parent
        return cmd + ["*"], source_dir

    if tool == "winrar":
        cmd = [str(exe), "a", "-afzip", "-y"]
        if compression_level is not None:
            m = max(0, min(5, compression_level - 4)) if compression_level > 4 else 0
            cmd.append(f"-m{m}")
        if password:
            cmd.append(f"-p{password}")
        cmd.append(str(archive_path))
        if include_root:
            return cmd + [source_dir.name], source_dir.parent
        return cmd + ["*"], source_dir

    if tool == "tar":
        cmd = [str(exe), "-a", "-c", "-f", str(archive_path)]
        if include_root:
            return cmd + ["-C", str(source_dir.parent), source_dir.name], Path.cwd()
        return cmd + ["-C", str(source_dir), "."], Path.cwd()

    raise ValueError(f"Неизвестный архиватор: {tool}")


def run_archiver(tool: str, exe: Path, source_dir: Path, archive_path: Path,
                 include_root: bool, password: str | None,
                 compression_level: int | None) -> None:
    cmd, cwd = build_command(tool, exe, source_dir, archive_path,
                             include_root, password, compression_level)
    print(f"[i] Архиватор:     {tool}  ({exe})")
    print(f"[i] Команда:       {' '.join(cmd)}")
    print(f"[i] Рабочая папка: {cwd}")

    result = subprocess.run(
        cmd, cwd=str(cwd), capture_output=True, text=False,
        env=subprocess_utf8_env(),
    )

    def decode(b: bytes) -> str:
        if not b:
            return ""
        for enc in ("utf-8", "cp866" if os.name == "nt" else "utf-8",
                    locale.getpreferredencoding(False) or "utf-8"):
            try:
                return b.decode(enc)
            except UnicodeDecodeError:
                continue
        return b.decode("utf-8", errors="replace")

    out = decode(result.stdout).strip()
    err = decode(result.stderr).strip()
    if out:
        print(out)
    if err:
        print(err, file=sys.stderr)

    if result.returncode != 0:
        raise RuntimeError(f"Архиватор завершился с кодом {result.returncode}")

    if not archive_path.exists():
        raise RuntimeError("Архив не был создан (файл не найден).")


# =====================================================================
#  CLI
# =====================================================================

def build_arg_parser():
    p = argparse.ArgumentParser(
        description="Упаковка директории патча в ZIP через внешний архиватор "
                    "(7-Zip/WinRAR/tar). UTF-8 + счётчик версий + конфиг-файл.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument("source", nargs="?", default=None,
                   help="Путь к директории патча (можно задать в конфиге)")
    p.add_argument("-c", "--config", default=None,
                   help=f"Путь к JSON-конфигу (по умолчанию ищется "
                        f"'{DEFAULT_CONFIG_NAME}' в cwd и рядом со скриптом)")

    # --- Переопределения (имеют приоритет над конфигом) ---
    p.add_argument("-v", "--version", help="Версия вручную (например, 1.2.3)")
    p.add_argument("-o", "--output", help="Папка для архива (переопределяет конфиг)")
    p.add_argument("-n", "--name", help="Базовое имя архива")
    p.add_argument("--bump", choices=["major", "minor", "patch"],
                   help="Какую часть версии инкрементировать")
    p.add_argument("--tool", choices=list(TOOLS.keys()),
                   help="Архиватор (переопределяет конфиг)")
    p.add_argument("--tool-path", help="Явный путь к exe архиватора")
    p.add_argument("--no-root", action="store_true",
                   help="Не включать корневую папку в архив")
    p.add_argument("--root", action="store_true",
                   help="Включать корневую папку в архив (принудительно)")
    p.add_argument("--password", help="Пароль на архив")
    p.add_argument("-l", "--level", type=int, help="Уровень сжатия 0-9")
    p.add_argument("--timestamp", action="store_true",
                   help="Добавить дату-время в имя архива")

    # --- Опции счётчика ---
    ctr = p.add_argument_group("счётчик версий")
    ctr.add_argument("--counter-file",
                     help="Путь к JSON-файлу счётчика (переопределяет конфиг)")
    ctr.add_argument("--no-build", action="store_true",
                     help="Не добавлять build-номер в имя архива")
    ctr.add_argument("--set-build", type=int, metavar="N",
                     help="Установить счётчик в N и выйти")
    ctr.add_argument("--reset-counter", action="store_true",
                     help="Сбросить счётчик в 0 и выйти")
    ctr.add_argument("--show-counter", action="store_true",
                     help="Показать состояние счётчика и выйти")
    ctr.add_argument("--list-counters", action="store_true",
                     help="Показать все счётчики в папке вывода и выйти")

    # --- Служебное ---
    p.add_argument("--show-config", action="store_true",
                   help="Показать итоговую конфигурацию и выйти")
    p.add_argument("--init-config", action="store_true",
                   help=f"Создать шаблон '{DEFAULT_CONFIG_NAME}' и выйти")
    return p


# =====================================================================
#  Слияние CLI + конфиг
# =====================================================================

def merge_settings(args, cfg: dict[str, Any], cfg_dir: Path) -> dict[str, Any]:
    """
    Объединяет CLI-аргументы и значения из конфига.
    Приоритет: CLI > конфиг > DEFAULTS.
    Относительные пути из конфига разрешаются относительно cfg_dir.
    """
    s: dict[str, Any] = {}

    # output_dir
    if args.output is not None:
        s["output_dir"] = Path(args.output).resolve()
    else:
        s["output_dir"] = resolve_relative_to(str(cfg["output_dir"]), cfg_dir)

    # counter_file (может быть None → авто по имени директории)
    if args.counter_file is not None:
        s["counter_file"] = Path(args.counter_file).resolve()
    elif cfg.get("counter_file"):
        s["counter_file"] = resolve_relative_to(str(cfg["counter_file"]), cfg_dir)
    else:
        s["counter_file"] = None

    # tool / tool_path
    s["tool"] = args.tool if args.tool is not None else cfg.get("tool")
    s["tool_path"] = (args.tool_path if args.tool_path is not None
                      else cfg.get("tool_path"))

    # name
    s["name"] = args.name if args.name is not None else cfg.get("name")

    # version
    s["version"] = args.version if args.version is not None else cfg.get("version")

    # bump
    s["bump"] = args.bump if args.bump is not None else cfg.get("bump", "patch")

    # level
    s["level"] = args.level if args.level is not None else cfg.get("level", 9)

    # password
    s["password"] = args.password if args.password is not None else cfg.get("password")

    # include_root: --no-root отменяет --root и значение конфига
    if args.no_root and args.root:
        raise ConfigError("Нельзя одновременно указывать --no-root и --root.")
    if args.no_root:
        s["include_root"] = False
    elif args.root:
        s["include_root"] = True
    else:
        s["include_root"] = bool(cfg.get("include_root", True))

    # timestamp
    s["timestamp"] = bool(args.timestamp or cfg.get("timestamp", False))

    # no_build
    s["no_build"] = bool(args.no_build or cfg.get("no_build", False))

    return s


def print_settings(settings: dict[str, Any], cfg_path: Path | None,
                   source_dir: Path | None) -> None:
    print("[i] Итоговая конфигурация:")
    if cfg_path:
        print(f"    config file    : {cfg_path}")
    else:
        print("    config file    : (не используется)")
    if source_dir:
        print(f"    source dir     : {source_dir}")
    print(f"    output dir     : {settings['output_dir']}")
    print(f"    counter file   : {settings['counter_file'] or '(авто по имени директории)'}")
    print(f"    tool           : {settings['tool'] or '(автопоиск)'}")
    print(f"    tool path      : {settings['tool_path'] or '(не задан)'}")
    print(f"    name           : {settings['name'] or '(имя директории)'}")
    print(f"    version        : {settings['version'] or '(авто)'}")
    print(f"    bump           : {settings['bump']}")
    print(f"    level          : {settings['level']}")
    print(f"    include_root   : {settings['include_root']}")
    print(f"    password       : {'***' if settings['password'] else '(нет)'}")
    print(f"    timestamp      : {settings['timestamp']}")
    print(f"    no_build       : {settings['no_build']}")


# =====================================================================
#  Шаблон конфига
# =====================================================================

CONFIG_TEMPLATE = {
    "output_dir":   "./dist",
    "counter_file": "./state/patch_version_counter.json",
    "tool":         "7z",
    "tool_path":    None,
    "name":         None,
    "level":        9,
    "include_root": True,
    "password":     None,
    "timestamp":    False,
    "bump":         "patch",
    "version":      None,
    "no_build":     False,
}


def write_config_template(target: Path) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    with target.open("w", encoding="utf-8") as f:
        json.dump(CONFIG_TEMPLATE, f, ensure_ascii=False, indent=2)
    print(f"[✓] Шаблон конфига создан: {target}")


# =====================================================================
#  main
# =====================================================================

def print_counter_info(counter: VersionCounter) -> None:
    print(f"[i] Файл счётчика:    {counter.path}")
    print(f"[i] Текущая сборка:   {counter.build}")
    print(f"[i] Следующая:        {counter.next_build()}")
    if counter.last_version:
        print(f"[i] Последняя версия: {counter.last_version}")
    if counter.history:
        print("[i] Последние сборки:")
        for item in counter.history[-5:]:
            print(f"    #{item.get('build'):<4} v{item.get('version'):<10} "
                  f"{item.get('created', '')}  {item.get('archive', '')}")


def print_all_counters(output_dir: Path) -> None:
    files = counter_files_in(output_dir)
    if not files:
        print(f"[i] В папке '{output_dir}' счётчиков не найдено.")
        return
    print(f"[i] Счётчики в '{output_dir}':")
    for f in files:
        name = f.name[:-len(COUNTER_SUFFIX)]
        try:
            with f.open("r", encoding="utf-8") as fh:
                data = json.load(fh)
            build = data.get("build", "?")
            ver = data.get("last_version", "—")
            print(f"    {name:<30} build={build:<6} last_version={ver}")
        except Exception as e:
            print(f"    {name:<30} [ошибка чтения: {e}]")


def main(argv=None):
    setup_utf8_environment()
    args = build_arg_parser().parse_args(argv)

    script_dir = Path(__file__).resolve().parent
    cwd = Path.cwd()

    # --- init-config: пишем шаблон и выходим ---
    if args.init_config:
        target = Path(args.config).resolve() if args.config else cwd / DEFAULT_CONFIG_NAME
        write_config_template(target)
        return 0

    # --- Загрузка конфига ---
    try:
        cfg_path = find_default_config(args.config, script_dir, cwd)
    except ConfigError as e:
        print(f"[!] {e}", file=sys.stderr)
        return 2

    cfg: dict[str, Any] = dict(DEFAULTS)
    if cfg_path:
        try:
            cfg = load_config(cfg_path)
        except ConfigError as e:
            print(f"[!] {e}", file=sys.stderr)
            return 2
    else:
        print("[i] Конфиг не найден — работаю с настройками по умолчанию. "
              f"Создать шаблон: --init-config")

    cfg_dir = cfg_path.parent if cfg_path else cwd

    # --- Слияние CLI + конфиг ---
    try:
        settings = merge_settings(args, cfg, cfg_dir)
    except ConfigError as e:
        print(f"[!] {e}", file=sys.stderr)
        return 2

    output_dir: Path = settings["output_dir"]
    output_dir.mkdir(parents=True, exist_ok=True)

    # --- source: CLI или конфиг ---
    source_arg = args.source or cfg.get("source_dir")  # если решите добавить в конфиг
    source_dir: Path | None = None
    if source_arg:
        source_dir = Path(source_arg).resolve()

    # --- Сервисные команды без обязательного source ---

    if args.list_counters:
        print_all_counters(output_dir)
        return 0

    if args.show_config:
        print_settings(settings, cfg_path, source_dir)
        return 0

    # Определяем базовое имя (для поиска счётчика и имени архива)
    base_name = settings["name"] or (source_dir.name if source_dir else None)

    # Путь к счётчику
    if settings["counter_file"] is not None:
        counter_path = settings["counter_file"]
    elif base_name:
        counter_path = make_counter_path(output_dir, base_name)
    else:
        # без source и без имени — счётчик не определить
        if args.show_counter or args.reset_counter or args.set_build is not None:
            print("[!] Не удалось определить счётчик: укажите source или --counter-file.",
                  file=sys.stderr)
            return 2
        counter_path = None

    counter = VersionCounter(counter_path, source_dir) if counter_path else None

    if args.show_counter:
        print_counter_info(counter)
        return 0

    if args.reset_counter:
        counter.set_build(0)
        counter.last_version = None
        counter.history.clear()
        counter._save()
        print(f"[✓] Счётчик сброшен: {counter.path}")
        return 0

    if args.set_build is not None:
        counter.set_build(args.set_build)
        print(f"[✓] Счётчик установлен в {args.set_build}: {counter.path}")
        return 0

    # --- Основной сценарий: нужен source ---
    if not source_dir:
        print("[!] Не указана директория патча. Передайте её аргументом "
              "или задайте 'source_dir' в конфиге.", file=sys.stderr)
        return 2
    if not source_dir.is_dir():
        print(f"[!] Директория не найдена: {source_dir}", file=sys.stderr)
        return 2

    if not base_name:
        base_name = source_dir.name

    # Версия (semver)
    if settings["version"]:
        try:
            version_tuple = parse_version(settings["version"])
        except ValueError as e:
            print(f"[!] {e}", file=sys.stderr)
            return 2
    else:
        version_tuple = determine_next_version(output_dir, base_name, settings["bump"])
        print(f"[i] Версия определена автоматически: {format_version(version_tuple)}")
    version_str = format_version(version_tuple)

    # Build-номер
    if settings["no_build"] or counter is None:
        build_number = None
    else:
        next_b = counter.next_build()
        max_in_dir = max_build_in_output(output_dir, base_name)
        if max_in_dir >= next_b:
            print(f"[i] В папке найден архив со сборкой b{max_in_dir}; "
                  f"синхронизирую счётчик.")
            counter.set_build(max_in_dir)
            next_b = counter.next_build()
        build_number = next_b

    # Имя архива
    ts = "-" + datetime.now().strftime("%Y%m%d-%H%M%S") if settings["timestamp"] else ""
    build_suffix = f"-b{build_number}" if build_number is not None else ""
    archive_name = f"{base_name}-v{version_str}{build_suffix}{ts}.zip"
    archive_path = output_dir / archive_name

    # Архиватор
    try:
        tool, exe = resolve_tool(settings["tool"], settings["tool_path"], cfg_dir)
    except (FileNotFoundError, ValueError) as e:
        print(f"[!] {e}", file=sys.stderr)
        return 3

    print(f"[i] Конфиг:        {cfg_path or '(по умолчанию)'}")
    print(f"[i] Источник:      {source_dir}")
    print(f"[i] Архив:         {archive_path}")
    if build_number is not None:
        print(f"[i] Сборка:        b{build_number}  (счётчик: {counter.path})")

    # Упаковка
    try:
        run_archiver(
            tool, exe, source_dir, archive_path,
            include_root=settings["include_root"],
            password=settings["password"],
            compression_level=settings["level"],
        )
    except Exception as e:
        print(f"[!] Ошибка упаковки: {e}", file=sys.stderr)
        return 1

    # Фиксация счётчика после успеха
    if build_number is not None and counter is not None:
        committed = counter.commit(version_str, archive_name)
        print(f"[i] Счётчик зафиксирован: build = {committed}")

    size_kb = archive_path.stat().st_size / 1024
    print(f"[✓] Готово: {archive_path}  ({size_kb:.1f} КБ)")
    return 0


if __name__ == "__main__":
    sys.exit(main())