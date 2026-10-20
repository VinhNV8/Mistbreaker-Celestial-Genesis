#!/usr/bin/env bash
# C1-50 (KT-06): build file chạy Windows. Cần export templates Godot 4.7.2 (một lần):
#   Godot editor → Editor → Manage Export Templates → Download and Install
#   hoặc giải nén Godot_v4.7.2-stable_export_templates.tpz vào %APPDATA%/Godot/export_templates/4.7.2.stable/
# Chạy từ thư mục gốc dự án:  bash tools/build_windows.sh
set -e
GODOT="${GODOT:-C:/Users/ADMIN/AppData/Local/Programs/Godot/Godot_v4.7.2-stable_win64_console.exe}"
mkdir -p build
"$GODOT" --headless --path godot --import
"$GODOT" --headless --path godot --export-release "Windows Desktop" ../build/ThienPhuKhaiGioi.exe
ls -la build/
