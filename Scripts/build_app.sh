#!/bin/bash
# ============================================================
# OmniWM — Build, Bundle & Zip
# Run this from the repo root:  bash Scripts/build_app.sh
# ============================================================
set -e

REPO="$(cd "$(dirname "$0")/.." && pwd)"
BINARY_NAME="OmniWM"
APP_NAME="OmniWM"
APP_BUNDLE="${REPO}/${APP_NAME}.app"
ZIP_OUT="${REPO}/${APP_NAME}.app.zip"
PLIST="${REPO}/Info.plist"
ENTITLEMENTS="${REPO}/OmniWM.entitlements"
ICON="${REPO}/Resources/AppIcon.icns"

BUILD_CONFIG="release"
if [[ "$1" == "--debug" ]]; then
    BUILD_CONFIG="debug"
    echo "⚡ Debug build (faster, not optimised)"
fi

echo "📦 OmniWM Build Script"
echo "═══════════════════════════════════════"

# ── 1. Build ────────────────────────────────────────────────
echo "🔨 Building (${BUILD_CONFIG})…"
START_TIME=$(date +%s)
cd "$REPO"
swift build -c "$BUILD_CONFIG" --product "$BINARY_NAME"
END_TIME=$(date +%s)

BUILT_BINARY="${REPO}/.build/${BUILD_CONFIG}/${BINARY_NAME}"
if [ ! -f "$BUILT_BINARY" ]; then
    echo "❌ Build failed — binary not found at ${BUILT_BINARY}"
    exit 1
fi
echo "✅ Build succeeded"

# ── 2. Assemble .app bundle ─────────────────────────────────
echo "🗂  Assembling ${APP_NAME}.app…"
rm -rf "$APP_BUNDLE"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy binary (named OmniWM as declared in Info.plist CFBundleExecutable)
cp "$BUILT_BINARY" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Copy Info.plist
cp "$PLIST" "${APP_BUNDLE}/Contents/Info.plist"

# Copy icon
if [ -f "$ICON" ]; then
    cp "$ICON" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
fi

# Copy any bundled resources (aelte, dwstevens etc.)
if [ -d "${REPO}/Sources/OmniWM/Resources" ]; then
    cp "${REPO}/Sources/OmniWM/Resources/"*.png "${APP_BUNDLE}/Contents/Resources/" 2>/dev/null || true
fi

echo "✅ Bundle assembled"

# ── 3. Ad-hoc code-sign (allows Accessibility permission prompts) ──
echo "🔏 Code-signing (ad-hoc)…"
codesign --force --deep --sign - \
    --entitlements "$ENTITLEMENTS" \
    --options runtime \
    "$APP_BUNDLE"
echo "✅ Signed"

# ── 4. Remove quarantine so macOS doesn't block launch ──────
xattr -cr "$APP_BUNDLE" 2>/dev/null || true

# ── 5. Zip it ───────────────────────────────────────────────
echo "🗜  Creating ${APP_NAME}.app.zip…"
rm -f "$ZIP_OUT"
cd "$REPO"
zip -r --symlinks "${APP_NAME}.app.zip" "${APP_NAME}.app"
echo "✅ Zip created: ${ZIP_OUT}"

# ── 6. Report ───────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════"
echo "🎉 Done!  OmniWM.app.zip is ready."
echo ""
echo "To launch right now:"
echo "   open '${APP_BUNDLE}'"
echo ""
echo "To grant Accessibility (if not already granted):"
echo "   System Settings → Privacy & Security → Accessibility → add OmniWM"
echo ""
