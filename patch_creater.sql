#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Упаковка директории патча в ZIP-архив через внешний архиватор.
UTF-8 + счётчик версий + конфигурационный файл.

Декомпозиция:
    - Utf8Setup        — включение UTF-8 окружения
    - Config           — работа с JSON-конфигом
    - Settings         — итоговые настройки (CLI + Config + DEFAULTS)
    - SemVer           — операции над версией
    - VersionCounter   — счётчик сборок
    - Archiver*        — конкретные архиваторы (7z / WinRAR / tar)
    - ArchiverFactory  — выбор/автопоиск архиватора
    - PatchPacker      — оркестратор упаковки
    - CliApp           — разбор argv и диспетчеризация команд
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
from abc import ABC, abstractmethod
from datetime import datetime
from pathlib import Path
from typing import Any


# =====================================================================
#  1. UTF-8
# =====================================================================

class Utf8Setup:
    """Принудительно включает UTF-8 для потоков, файловой системы и подпроцессов."""

    @staticmethod
    def apply() -> None:
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

    @staticmethod
    def subprocess_env() -> dict:
        env = os.environ.copy()
        env["PYTHONUTF8"] = "1"
        env["PYTHONIOENCODING"] = "utf-8"
        if os.name == "nt":
            env.setdefault("LANG", "ru_RU.UTF-8")
        return env

    @staticmethod
    def decode_bytes(b: bytes) -> str:
        """Декодирует вывод внешнего процесса: сначала UTF-8, затем OEM."""
        if not b:
            return ""
        for enc in ("utf-8",
                    "cp866" if os.name == "nt" else "utf-8",
                    locale.getpreferredencoding(False) or "utf-8"):
            try:
                return b.decode(enc)
            except UnicodeDecodeError:
                continue
        return b.decode("utf-8", errors="replace")


# =====================================================================
#  2. Ошибки
# =====================================================================

class ConfigError(Exception):
    """Ошибка разбора/валидации конфигурации."""


class ArchiverError(Exception):
    """Ошибка архиватора."""


# =====================================================================
#  3. SemVer
# =====================================================================

class SemVer:
    """Операции над семантической версией X.Y.Z."""

    @staticmethod
    def parse(text: str) -> tuple[int, int, int]:
        parts = text.strip().split(".")
        if not all(p.isdigit() for p in parts):
            raise ValueError(f"Некорректная версия: {text}")
        parts = (parts + ["0", "0", "0"])[:3]
        return tuple(int(p) for p in parts)  # type: ignore[return-value]

    @staticmethod
    def format(v: tuple[int, int, int]) -> str:
        return ".".join(str(p) for p in v)

    @staticmethod
    def bump(v: tuple[int, int, int], part: str = "patch") -> tuple[int, int, int]:
        major, minor, patch = v
        if part == "major":
            return (major + 1, 0, 0)
        if part == "minor":
            return (major, minor + 1, 0)
        return (major, minor, patch + 1)


# =====================================================================
#  4. Конфигурация
# =====================================================================

class Config:
    """
    JSON-конфиг. Отвечает за:
      - значения по умолчанию;
      - загрузку из файла;
      - поиск конфига (explicit → cwd → папка скрипта);
      - запись шаблона.
    """

    DEFAULT_NAME = "pack_config.json"

    DEFAULTS: dict[str, Any] = {
        "output_dir":   "./dist",
        "counter_file": None,
        "tool":         None,
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

    TEMPLATE: dict[str, Any] = {
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

    ALLOWED_KEYS = set(DEFAULTS.keys())

    def __init__(self, path: Path | None, data: dict[str, Any]):
        self.path = path
        self.data = data

    # ---------- загрузка/поиск ----------

    @classmethod
    def find(cls, explicit: str | None, script_dir: Path, cwd: Path) -> Path | None:
        if explicit:
            p = Path(explicit).resolve()
            if not p.is_file():
                raise ConfigError(f"Указанный конфиг не найден: {p}")
            return p
        for candidate in (cwd / cls.DEFAULT_NAME, script_dir / cls.DEFAULT_NAME):
            if candidate.is_file():
                return candidate.resolve()
        return None

    @classmethod
    def load(cls, path: Path) -> "Config":
        if not path.is_file():
            raise ConfigError(f"Файл конфигурации не найден: {path}")
        try:
            with path.open("r", encoding="utf-8") as f:
                raw = json.load(f)
        except json.JSONDecodeError as e:
            raise ConfigError(f"Ошибка разбора JSON '{path}': {e}") from e
        except OSError as e:
            raise ConfigError(f"Не удалось прочитать '{path}': {e}") from e

        if not isinstance(raw, dict):
            raise ConfigError(f"Корень конфига должен быть объектом JSON: {path}")

        unknown = set(raw.keys()) - cls.ALLOWED_KEYS
        if unknown:
            print(f"[i] В конфиге '{path}' неизвестные ключи: "
                  f"{', '.join(sorted(unknown))} (пропущены)")

        data = dict(cls.DEFAULTS)
        for k, v in raw.items():
            if k in cls.ALLOWED_KEYS:
                data[k] = v
        return cls(path=path, data=data)

    @classmethod
    def empty(cls) -> "Config":
        return cls(path=None, data=dict(cls.DEFAULTS))

    # ---------- доступ ----------

    def get(self, key: str, default: Any = None) -> Any:
        return self.data.get(key, default)

    def resolve_path(self, value: str) -> Path:
        """Относительный путь разрешается от папки конфига (или cwd, если конфига нет)."""
        base = self.path.parent if self.path else Path.cwd()
        p = Path(value)
        return (base / p).resolve() if not p.is_absolute() else p.resolve()

    @property
    def dir(self) -> Path:
        return self.path.parent if self.path else Path.cwd()

    # ---------- шаблон ----------

    @classmethod
    def write_template(cls, target: Path, *, overwrite: bool = False) -> None:
        if target.exists() and not overwrite:
            print(f"[i] Конфиг уже существует, оставляю без изменений: {target}")
            return
        target.parent.mkdir(parents=True, exist_ok=True)
        with target.open("w", encoding="utf-8") as f:
            json.dump(cls.TEMPLATE, f, ensure_ascii=False, indent=2)
        verb = "перезаписан" if overwrite and target.exists() else "создан"
        print(f"[✓] Шаблон конфига {verb}: {target}")


# =====================================================================
#  5. Настройки (CLI + Config + DEFAULTS)
# =====================================================================

class Settings:
    """
    Итоговые настройки после слияния CLI > Config > DEFAULTS.
    Все пути уже абсолютные.
    """

    def __init__(self, **kw):
        self.output_dir: Path = kw["output_dir"]
        self.counter_file: Path | None = kw["counter_file"]
        self.tool: str | None = kw["tool"]
        self.tool_path: str | None = kw["tool_path"]
        self.name: str | None = kw["name"]
        self.level: int = kw["level"]
        self.include_root: bool = kw["include_root"]
        self.password: str | None = kw["password"]
        self.timestamp: bool = kw["timestamp"]
        self.bump: str = kw["bump"]
        self.version: str | None = kw["version"]
        self.no_build: bool = kw["no_build"]

    @classmethod
    def build(cls, args: argparse.Namespace, cfg: Config) -> "Settings":
        # output_dir
        if args.output is not None:
            output_dir = Path(args.output).resolve()
        else:
            output_dir = cfg.resolve_path(str(cfg.get("output_dir")))

        # counter_file
        if args.counter_file is not None:
            counter_file = Path(args.counter_file).resolve()
        elif cfg.get("counter_file"):
            counter_file = cfg.resolve_path(str(cfg.get("counter_file")))
        else:
            counter_file = None

        # include_root: --no-root / --root
        if args.no_root and args.root:
            raise ConfigError("Нельзя одновременно указывать --no-root и --root.")
        if args.no_root:
            include_root = False
        elif args.root:
            include_root = True
        else:
            include_root = bool(cfg.get("include_root", True))

        return cls(
            output_dir=output_dir,
            counter_file=counter_file,
            tool=args.tool if args.tool is not None else cfg.get("tool"),
            tool_path=args.tool_path if args.tool_path is not None else cfg.get("tool_path"),
            name=args.name if args.name is not None else cfg.get("name"),
            level=args.level if args.level is not None else cfg.get("level", 9),
            include_root=include_root,
            password=args.password if args.password is not None else cfg.get("password"),
            timestamp=bool(args.timestamp or cfg.get("timestamp", False)),
            bump=args.bump if args.bump is not None else cfg.get("bump", "patch"),
            version=args.version if args.version is not None else cfg.get("version"),
            no_build=bool(args.no_build or cfg.get("no_build", False)),
        )

    def describe(self, cfg_path: Path | None, source_dir: Path | None) -> None:
        print("[i] Итоговая конфигурация:")
        print(f"    config file    : {cfg_path or '(не используется)'}")
        if source_dir:
            print(f"    source dir     : {source_dir}")
        print(f"    output dir     : {self.output_dir}")
        print(f"    counter file   : {self.counter_file or '(авто по имени директории)'}")
        print(f"    tool           : {self.tool or '(автопоиск)'}")
        print(f"    tool path      : {self.tool_path or '(не задан)'}")
        print(f"    name           : {self.name or '(имя директории)'}")
        print(f"    version        : {self.version or '(авто)'}")
        print(f"    bump           : {self.bump}")
        print(f"    level          : {self.level}")
        print(f"    include_root   : {self.include_root}")
        print(f"    password       : {'***' if self.password else '(нет)'}")
        print(f"    timestamp      : {self.timestamp}")
        print(f"    no_build       : {self.no_build}")


# =====================================================================
#  6. Счётчик версий
# =====================================================================

class VersionCounter:
    """
    Монотонно растущий счётчик сборок в JSON.
    Файл: <output>/<имя_директории>_version_counter.json
    """

    SUFFIX = "_version_counter.json"
    HISTORY_LIMIT = 50

    def __init__(self, path: Path, source_dir: Path | None = None):
        self.path = path
        self.source_dir = source_dir
        self.build = 0
        self.last_version: str | None = None
        self.history: list[dict] = []
        self._load()

    # ---------- пути ----------

    @staticmethod
    def sanitize(name: str) -> str:
        cleaned = re.sub(r'[<>:"/\\|?*\x00-\x1f]', "_", name).strip(" .")
        return cleaned or "patch"

    @classmethod
    def make_path(cls, output_dir: Path, source_name: str) -> Path:
        safe = cls.sanitize(source_name)
        return (output_dir / f"{safe}{cls.SUFFIX}").resolve()

    @classmethod
    def files_in(cls, directory: Path) -> list[Path]:
        if not directory.exists():
            return []
        return sorted(directory.glob(f"*{cls.SUFFIX}"))

    # ---------- I/O ----------

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

    def save(self) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        name = self.path.name
        source_name = name[:-len(self.SUFFIX)] if name.endswith(self.SUFFIX) else self.path.stem
        data = {
            "source_name": source_name,
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

    # ---------- операции ----------

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
        self.save()
        return self.build

    def reset(self) -> None:
        self.build = 0
        self.last_version = None
        self.history.clear()
        self.save()

    def set_build(self, value: int) -> None:
        self.build = int(value)
        self.save()

    # ---------- отображение ----------

    def describe(self) -> None:
        print(f"[i] Файл счётчика:    {self.path}")
        print(f"[i] Текущая сборка:   {self.build}")
        print(f"[i] Следующая:        {self.next_build()}")
        if self.last_version:
            print(f"[i] Последняя версия: {self.last_version}")
        if self.history:
            print("[i] Последние сборки:")
            for item in self.history[-5:]:
                print(f"    #{item.get('build'):<4} v{item.get('version'):<10} "
                      f"{item.get('created', '')}  {item.get('archive', '')}")


# =====================================================================
#  7. Архиваторы
# =====================================================================

class ArchiverBase(ABC):
    """Общий интерфейс архиватора."""

    NAME: str = ""

    def __init__(self, exe: Path):
        self.exe = exe

    @abstractmethod
    def build_command(self, source_dir: Path, archive_path: Path, *,
                      include_root: bool, password: str | None,
                      level: int | None) -> tuple[list[str], Path]:
        """Возвращает (argv, cwd)."""

    def run(self, source_dir: Path, archive_path: Path, *,
            include_root: bool, password: str | None, level: int | None) -> None:
        cmd, cwd = self.build_command(source_dir, archive_path,
                                      include_root=include_root,
                                      password=password, level=level)
        print(f"[i] Архиватор:     {self.NAME}  ({self.exe})")
        print(f"[i] Команда:       {' '.join(cmd)}")
        print(f"[i] Рабочая папка: {cwd}")

        result = subprocess.run(
            cmd, cwd=str(cwd), capture_output=True, text=False,
            env=Utf8Setup.subprocess_env(),
        )
        out = Utf8Setup.decode_bytes(result.stdout).strip()
        err = Utf8Setup.decode_bytes(result.stderr).strip()
        if out:
            print(out)
        if err:
            print(err, file=sys.stderr)

        if result.returncode != 0:
            raise ArchiverError(f"Архиватор завершился с кодом {result.returncode}")
        if not archive_path.exists():
            raise ArchiverError("Архив не был создан (файл не найден).")


class SevenZipArchiver(ArchiverBase):
    NAME = "7z"

    def build_command(self, source_dir, archive_path, *, include_root,
                      password, level):
        cmd = [str(self.exe), "a", "-tzip", "-y", "-mcu=on"]
        if level is not None:
            cmd.append(f"-mx={level}")
        if password:
            cmd.append(f"-p{password}")
        cmd.append(str(archive_path))
        if include_root:
            return cmd + [source_dir.name], source_dir.parent
        return cmd + ["*"], source_dir


class WinRarArchiver(ArchiverBase):
    NAME = "winrar"

    def build_command(self, source_dir, archive_path, *, include_root,
                      password, level):
        cmd = [str(self.exe), "a", "-afzip", "-y"]
        if level is not None:
            m = max(0, min(5, level - 4)) if level > 4 else 0
            cmd.append(f"-m{m}")
        if password:
            cmd.append(f"-p{password}")
        cmd.append(str(archive_path))
        if include_root:
            return cmd + [source_dir.name], source_dir.parent
        return cmd + ["*"], source_dir


class TarArchiver(ArchiverBase):
    NAME = "tar"

    def build_command(self, source_dir, archive_path, *, include_root,
                      password, level):
        # tar не поддерживает пароль и уровень сжатия в этом виде
        cmd = [str(self.exe), "-a", "-c", "-f", str(archive_path)]
        if include_root:
            return cmd + ["-C", str(source_dir.parent), source_dir.name], Path.cwd()
        return cmd + ["-C", str(source_dir), "."], Path.cwd()


class ArchiverFactory:
    """Автопоиск/выбор архиватора и создание экземпляра."""

    REGISTRY: dict[str, type[ArchiverBase]] = {
        "7z":     SevenZipArchiver,
        "winrar": WinRarArchiver,
        "tar":    TarArchiver,
    }

    @classmethod
    def names(cls) -> list[str]:
        return list(cls.REGISTRY.keys())

    # --- поиск exe ---

    @staticmethod
    def _which(candidates):
        for c in candidates:
            path = shutil.which(c)
            if path:
                return Path(path)
        return None

    @classmethod
    def find_7zip(cls) -> Path | None:
        exe = cls._which(["7z", "7z.exe"])
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

    @classmethod
    def find_winrar(cls) -> Path | None:
        exe = cls._which(["rar", "rar.exe"])
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

    @classmethod
    def find_tar(cls) -> Path | None:
        return cls._which(["tar", "tar.exe"])

    FINDERS: dict[str, Any] = {}  # заполним ниже

    @classmethod
    def _finders(cls) -> dict[str, Any]:
        return {
            "7z":     cls.find_7zip,
            "winrar": cls.find_winrar,
            "tar":    cls.find_tar,
        }

    # --- определение типа по имени exe ---

    @staticmethod
    def tool_from_exe_path(exe: Path) -> str:
        low = exe.name.lower()
        if "7z" in low:
            return "7z"
        if "rar" in low:
            return "winrar"
        if "tar" in low:
            return "tar"
        raise ArchiverError(f"Не удалось определить тип архиватора по имени: {exe.name}")

    # --- фабричный метод ---

    @classmethod
    def create(cls, cfg_tool: str | None, cfg_tool_path: str | None,
               base_dir: Path) -> ArchiverBase:
        # явный путь к exe
        if cfg_tool_path:
            exe = Path(cfg_tool_path)
            if not exe.is_absolute():
                exe = (base_dir / exe).resolve()
            else:
                exe = exe.resolve()
            if not exe.is_file():
                raise ArchiverError(f"Архиватор не найден по пути: {exe}")
            name = cls.tool_from_exe_path(exe)
            return cls.REGISTRY[name](exe)

        # явный выбор по имени
        if cfg_tool:
            if cfg_tool not in cls.REGISTRY:
                raise ArchiverError(f"Неизвестный архиватор: {cfg_tool}")
            exe = cls._finders()[cfg_tool]()
            if not exe:
                raise ArchiverError(
                    f"Архиватор '{cfg_tool}' не найден. Установите его "
                    f"или укажите tool_path в конфиге."
                )
            return cls.REGISTRY[cfg_tool](exe)

        # автопоиск
        for name in ("7z", "winrar", "tar"):
            exe = cls._finders()[name]()
            if exe:
                return cls.REGISTRY[name](exe)

        raise ArchiverError(
            "Не найден ни один архиватор (7-Zip, WinRAR, tar). "
            "Установите 7-Zip или используйте встроенный tar из Windows 10/11."
        )


# =====================================================================
#  8. Оркестратор упаковки
# =====================================================================

class PatchPacker:
    """
    Собирает всё воедино: настройки, счётчик, архиватор.
    Один прогон — один источник.
    """

    def __init__(self, settings: Settings, cfg: Config,
                 source_dir: Path, base_name: str | None = None):
        self.settings = settings
        self.cfg = cfg
        self.source_dir = source_dir
        self.base_name = base_name or settings.name or source_dir.name
        self.output_dir = settings.output_dir
        self.counter: VersionCounter | None = None
        self.archiver: ArchiverBase | None = None
        self.version_str: str = ""
        self.build_number: int | None = None
        self.archive_path: Path | None = None

    # ---------- подготовка ----------

    def prepare(self) -> None:
        self.output_dir.mkdir(parents=True, exist_ok=True)

        # счётчик
        if not self.settings.no_build:
            cpath = self.settings.counter_file or \
                    VersionCounter.make_path(self.output_dir, self.base_name)
            self.counter = VersionCounter(cpath, self.source_dir)

        # архиватор
        self.archiver = ArchiverFactory.create(
            self.settings.tool, self.settings.tool_path, self.cfg.dir,
        )

    # ---------- версия и build ----------

    def _resolve_version(self) -> str:
        if self.settings.version:
            try:
                return SemVer.format(SemVer.parse(self.settings.version))
            except ValueError as e:
                raise ConfigError(str(e)) from e
        nxt = self._determine_next_version()
        print(f"[i] Версия определена автоматически: {SemVer.format(nxt)}")
        return SemVer.format(nxt)

    def _determine_next_version(self) -> tuple[int, int, int]:
        existing = self._existing_versions()
        if not existing:
            return (0, 0, 1)
        latest = max(v for v, _ in existing)
        return SemVer.bump(latest, self.settings.bump)

    def _existing_versions(self) -> list[tuple[tuple[int, int, int], int | None]]:
        pattern = re.compile(
            rf"^{re.escape(self.base_name)}-v(\d+\.\d+\.\d+)(?:-b(\d+))?\.zip$",
            re.IGNORECASE,
        )
        versions = []
        if not self.output_dir.exists():
            return versions
        for entry in self.output_dir.iterdir():
            m = pattern.match(entry.name)
            if not m:
                continue
            try:
                ver = SemVer.parse(m.group(1))
            except ValueError:
                continue
            build = int(m.group(2)) if m.group(2) else None
            versions.append((ver, build))
        return versions

    def _resolve_build(self) -> int | None:
        if self.counter is None:
            return None
        next_b = self.counter.next_build()
        max_in_dir = max(
            (b for _, b in self._existing_versions() if b is not None),
            default=0,
        )
        if max_in_dir >= next_b:
            print(f"[i] В папке найден архив со сборкой b{max_in_dir}; "
                  f"синхронизирую счётчик.")
            self.counter.set_build(max_in_dir)
            next_b = self.counter.next_build()
        return next_b

    # ---------- основной шаг ----------

    def run(self) -> Path:
        self.prepare()

        self.version_str = self._resolve_version()
        self.build_number = self._resolve_build()

        ts = "-" + datetime.now().strftime("%Y%m%d-%H%M%S") if self.settings.timestamp else ""
        build_suffix = f"-b{self.build_number}" if self.build_number is not None else ""
        archive_name = f"{self.base_name}-v{self.version_str}{build_suffix}{ts}.zip"
        self.archive_path = self.output_dir / archive_name

        print(f"[i] Источник:      {self.source_dir}")
        print(f"[i] Архив:         {self.archive_path}")
        if self.build_number is not None and self.counter is not None:
            print(f"[i] Сборка:        b{self.build_number}  (счётчик: {self.counter.path})")

        assert self.archiver is not None
        self.archiver.run(
            self.source_dir, self.archive_path,
            include_root=self.settings.include_root,
            password=self.settings.password,
            level=self.settings.level,
        )

        if self.build_number is not None and self.counter is not None:
            committed = self.counter.commit(self.version_str, archive_name)
            print(f"[i] Счётчик зафиксирован: build = {committed}")

        size_kb = self.archive_path.stat().st_size / 1024
        print(f"[✓] Готово: {self.archive_path}  ({size_kb:.1f} КБ)")
        return self.archive_path


# =====================================================================
#  9. CLI
# =====================================================================

class CliApp:
    """Разбор argv и диспетчеризация команд."""

    def __init__(self, argv: list[str] | None = None):
        self.argv = argv
        self.parser = self._build_parser()
        self.args = self.parser.parse_args(argv)
        self.script_dir = Path(__file__).resolve().parent
        self.cwd = Path.cwd()

    # ---------- argparse ----------

    @staticmethod
    def _build_parser() -> argparse.ArgumentParser:
        p = argparse.ArgumentParser(
            description="Упаковка директории патча в ZIP через внешний архиватор.",
            formatter_class=argparse.RawDescriptionHelpFormatter,
        )
        p.add_argument("source", nargs="?", default=None,
                       help="Путь к директории патча")
        p.add_argument("-c", "--config", default=None,
                       help=f"Путь к JSON-конфигу (по умолчанию ищется "
                            f"'{Config.DEFAULT_NAME}' в cwd и рядом со скриптом)")

        # переопределения
        p.add_argument("-v", "--version", help="Версия вручную (например, 1.2.3)")
        p.add_argument("-o", "--output", help="Папка для архива")
        p.add_argument("-n", "--name", help="Базовое имя архива")
        p.add_argument("--bump", choices=["major", "minor", "patch"],
                       help="Какую часть версии инкрементировать")
        p.add_argument("--tool", choices=ArchiverFactory.names(),
                       help="Архиватор")
        p.add_argument("--tool-path", help="Явный путь к exe архиватора")
        p.add_argument("--no-root", action="store_true",
                       help="Не включать корневую папку в архив")
        p.add_argument("--root", action="store_true",
                       help="Включать корневую папку в архив (принудительно)")
        p.add_argument("--password", help="Пароль на архив")
        p.add_argument("-l", "--level", type=int, help="Уровень сжатия 0-9")
        p.add_argument("--timestamp", action="store_true",
                       help="Добавить дату-время в имя архива")

        ctr = p.add_argument_group("счётчик версий")
        ctr.add_argument("--counter-file", help="Путь к JSON-файлу счётчика")
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

        p.add_argument("--show-config", action="store_true",
                       help="Показать итоговую конфигурацию и выйти")
        p.add_argument("--init-config", action="store_true",
                       help=f"Создать шаблон '{Config.DEFAULT_NAME}', если его нет, и выйти")
        p.add_argument("--init-config-force", action="store_true",
                       help=f"Перезаписать '{Config.DEFAULT_NAME}' шаблоном и выйти")
        return p

    # ---------- entry point ----------

    def run(self) -> int:
        Utf8Setup.apply()

        # init-config / force — до загрузки конфига
        if self.args.init_config or self.args.init_config_force:
            target = (Path(self.args.config).resolve()
                      if self.args.config
                      else self.cwd / Config.DEFAULT_NAME)
            Config.write_template(target, overwrite=self.args.init_config_force)
            return 0

        # конфиг
        try:
            cfg_path = Config.find(self.args.config, self.script_dir, self.cwd)
        except ConfigError as e:
            print(f"[!] {e}", file=sys.stderr)
            return 2

        if cfg_path:
            try:
                cfg = Config.load(cfg_path)
            except ConfigError as e:
                print(f"[!] {e}", file=sys.stderr)
                return 2
        else:
            cfg = Config.empty()
            print("[i] Конфиг не найден — работаю с настройками по умолчанию. "
                  "Создать шаблон: --init-config")

        # слияние
        try:
            settings = Settings.build(self.args, cfg)
        except ConfigError as e:
            print(f"[!] {e}", file=sys.stderr)
            return 2

        settings.output_dir.mkdir(parents=True, exist_ok=True)

        # source
        source_arg = self.args.source or cfg.get("source_dir")
        source_dir = Path(source_arg).resolve() if source_arg else None

        # сервисные команды
        rc = self._handle_service_commands(settings, cfg, cfg_path, source_dir)
        if rc is not None:
            return rc

        # основной сценарий
        return self._pack(settings, cfg, cfg_path, source_dir)

    # ---------- сервисные команды ----------

    def _resolve_counter(self, settings: Settings, source_dir: Path | None,
                         base_name: str | None) -> VersionCounter | None:
        if settings.counter_file is not None:
            cpath = settings.counter_file
        elif base_name:
            cpath = VersionCounter.make_path(settings.output_dir, base_name)
        else:
            return None
        return VersionCounter(cpath, source_dir)

    def _handle_service_commands(self, settings: Settings, cfg: Config,
                                 cfg_path: Path | None,
                                 source_dir: Path | None) -> int | None:
        a = self.args
        base_name = settings.name or (source_dir.name if source_dir else None)

        if a.list_counters:
            files = VersionCounter.files_in(settings.output_dir)
            if not files:
                print(f"[i] В папке '{settings.output_dir}' счётчиков не найдено.")
                return 0
            print(f"[i] Счётчики в '{settings.output_dir}':")
            for f in files:
                name = f.name[:-len(VersionCounter.SUFFIX)]
                try:
                    with f.open("r", encoding="utf-8") as fh:
                        data = json.load(fh)
                    print(f"    {name:<30} build={data.get('build', '?'):<6} "
                          f"last_version={data.get('last_version', '—')}")
                except Exception as e:
                    print(f"    {name:<30} [ошибка чтения: {e}]")
            return 0

        if a.show_config:
            settings.describe(cfg_path, source_dir)
            return 0

        # для show/reset/set-build нужен counter
        needs_counter = a.show_counter or a.reset_counter or a.set_build is not None
        counter = self._resolve_counter(settings, source_dir, base_name)

        if needs_counter and counter is None:
            print("[!] Не удалось определить счётчик: укажите source или --counter-file.",
                  file=sys.stderr)
            return 2

        if a.show_counter and counter is not None:
            counter.describe()
            return 0

        if a.reset_counter and counter is not None:
            counter.reset()
            print(f"[✓] Счётчик сброшен: {counter.path}")
            return 0

        if a.set_build is not None and counter is not None:
            counter.set_build(a.set_build)
            print(f"[✓] Счётчик установлен в {a.set_build}: {counter.path}")
            return 0

        return None

    # ---------- основной сценарий ----------

    def _pack(self, settings: Settings, cfg: Config,
              cfg_path: Path | None, source_dir: Path | None) -> int:
        if not source_dir:
            print("[!] Не указана директория патча.", file=sys.stderr)
            return 2
        if not source_dir.is_dir():
            print(f"[!] Директория не найдена: {source_dir}", file=sys.stderr)
            return 2

        print(f"[i] Конфиг:        {cfg_path or '(по умолчанию)'}")

        packer = PatchPacker(settings, cfg, source_dir)
        try:
            packer.run()
        except ArchiverError as e:
            print(f"[!] Ошибка упаковки: {e}", file=sys.stderr)
            return 1
        except ConfigError as e:
            print(f"[!] {e}", file=sys.stderr)
            return 2
        return 0


# =====================================================================
#  Точка входа
# =====================================================================

def main(argv=None) -> int:
    return CliApp(argv).run()


if __name__ == "__main__":
    sys.exit(main())