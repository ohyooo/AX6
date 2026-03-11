#!/usr/bin/env sh

set -eu

REPO_URL="https://github.com/immortalwrt/immortalwrt"
BRANCH="openwrt-25.12"
SRC_DIR="immortalwrt"
CONFIG_FILE="cudy.config"
PATCH_FILE="cudy.patch"

require_file() {
    if [ ! -f "$1" ]; then
        echo "Missing file: $1" >&2
        exit 1
    fi
}

command -v git >/dev/null 2>&1 || {
    echo "git is required" >&2
    exit 1
}

command -v patch >/dev/null 2>&1 || {
    echo "patch is required" >&2
    exit 1
}

require_file "$CONFIG_FILE"
require_file "$PATCH_FILE"

if [ ! -d "$SRC_DIR/.git" ]; then
    git clone "$REPO_URL" -b "$BRANCH" "$SRC_DIR"
else
    echo "Using existing source tree: $SRC_DIR"
fi

cp "$CONFIG_FILE" "$SRC_DIR/.config"

if [ ! -d "$SRC_DIR/package/base-files" ]; then
    echo "Source directory missing: $SRC_DIR/package/base-files" >&2
    exit 1
fi

rm -rf "$SRC_DIR/packages/base-files"
cp -r "$SRC_DIR/package/base-files" "$SRC_DIR/packages/base-files"

if git -C "$SRC_DIR" apply --check "../$PATCH_FILE" >/dev/null 2>&1; then
    git -C "$SRC_DIR" apply "../$PATCH_FILE"
else
    echo "Patch may already be applied or has conflicts, trying patch(1) fallback"
    patch -d "$SRC_DIR" -p1 < "$PATCH_FILE" || {
        echo "Failed to apply patch: $PATCH_FILE" >&2
        exit 1
    }
fi

NPROC="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"

(
    cd "$SRC_DIR"
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    make download -j8
    make -j"$NPROC"
)
