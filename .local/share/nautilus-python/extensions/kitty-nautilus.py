#!/usr/bin/env python3
"""
Kitty Terminal Extension for Nautilus/Caja.
支持通过右键菜单在多个目录或文件所在的目录中同时打开终端。
"""

import subprocess
from shutil import which
import os

try:
    from urllib import unquote  # type: ignore
    from urlparse import urlparse
except ImportError:
    from urllib.parse import unquote, urlparse

from gi import get_required_version, require_version

API_VERSION: str
if (API_VERSION := get_required_version("Nautilus")) is not None:
    try:
        require_version("Gtk", "4.0")
    except ValueError:
        require_version("Gtk", "3.0")
    from gi.repository import Nautilus as FileManager
elif (API_VERSION := get_required_version("Caja")) is not None:
    require_version("Gtk", "3.0")
    from gi.repository import Caja as FileManager
else:
    raise RuntimeError("This module can only be executed as a Nautilus/Caja extension")

from gi.repository import (
    Gio,
    GLib,
    GObject,
    Gtk,
)  # noqa: E402 pylint: disable=wrong-import-position


class KittyTerminalExtension(GObject.GObject, FileManager.MenuProvider):
    def _open_kitty(self, _menu, files):
        """Open kitty terminal in the selected directories."""
        fallback_paths = [
            "kitty",
            os.path.join(os.path.expanduser("~"), ".local/kitty.app/bin/kitty"),
            os.path.join(os.path.expanduser("~"), ".local/bin/kitty"),
            os.path.join(os.path.expanduser("~"), ".bin/kitty"),
            os.path.join(os.path.expanduser("~"), "bin/kitty"),
        ]
        kitty_bin = None
        for exe in fallback_paths:
            # 如果在 PATH 中找到或可直接访问，则使用该可执行文件
            if which(exe) or os.path.exists(exe):
                kitty_bin = which(exe) or exe
                break

        if not kitty_bin:
            return

        for file in files:
            if file.is_directory():
                path = unquote(file.get_uri()[7:])
                subprocess.Popen(
                    [kitty_bin, "--directory", path]
                )

    def get_file_items(self, *args):
        if len(args) == 1:
            files = args[0]
            window = None
        else:
            window, files = args

        directories = set()
        for file_obj in files:
            if file_obj.is_directory():
                directories.add(file_obj.get_uri())
            else:
                parent_uri = file_obj.get_parent_uri()
                if parent_uri:
                    directories.add(parent_uri)

        if not directories:
            return []

        target_files = [FileManager.FileInfo.create_for_uri(uri) for uri in directories]

        item = FileManager.MenuItem(
            name="KittyTerminalExtension::OpenKitty",
            label="Open in Kitty",
            tip="Opens Kitty terminal in these directories",
        )
        item.connect("activate", self._open_kitty, list(target_files))
        return [item]

    def get_background_items(self, *args):
        if len(args) == 1:
            current_folder = args[0]
            window = None
        else:
            window, current_folder = args

        if not current_folder.is_directory():
            return []

        item = FileManager.MenuItem(
            name="KittyTerminalExtension::OpenKittyBackground",
            label="Open in Kitty",
            tip="Opens Kitty terminal in this directory",
        )
        item.connect("activate", self._open_kitty, [current_folder])
        return [item]
