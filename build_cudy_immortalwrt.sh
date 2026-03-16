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
    (
      cd $SRC_DIR
      git reset --hard bbe3e58df01476a499ffcdc1098a418946d368b0 # ath79: disable build for fortinet fap-220-b by default
    )
else
    echo "Using existing source tree: $SRC_DIR"
fi

cp "$CONFIG_FILE" "$SRC_DIR/.config"

if [ ! -d "$SRC_DIR/package/base-files" ]; then
    echo "Source directory missing: $SRC_DIR/package/base-files" >&2
    exit 1
fi

#rm -rf "$SRC_DIR/packages/base-files"
cp -r "base-files" "$SRC_DIR/packages"

if git -C "$SRC_DIR" apply --check "../$PATCH_FILE" >/dev/null 2>&1; then
    echo "Applying patch: $PATCH_FILE"
    git -C "$SRC_DIR" apply "../$PATCH_FILE"
elif git -C "$SRC_DIR" apply -R --check "../$PATCH_FILE" >/dev/null 2>&1; then
    echo "Patch already applied: $PATCH_FILE"
else
    echo "Patch has conflicts and cannot be applied cleanly: $PATCH_FILE" >&2
    exit 1
fi

NPROC="${NPROC:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)}"

(
    cd "$SRC_DIR"
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    make download -j"$(nproc 2>/dev/null || getconf _NPROCESSORS_ONLN || echo 1)"
    if [ "$NPROC" -eq "1" ]; then
        make -j1 V=s
    else
        make -j"$NPROC"
    fi
)
