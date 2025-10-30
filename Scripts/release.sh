#!/bin/bash

# PromptDock Release Build Script
# Automates building, signing, notarizing, and packaging for distribution

set -e  # Exit on error

# Configuration
APP_NAME="PromptDock"
SCHEME="PromptDock"
VERSION="1.1.0"
BUILD_DIR="build"
RELEASE_DIR="release"
BUNDLE_ID="com.promptdock.PromptDock"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_step() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
    exit 1
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

check_requirements() {
    print_step "Checking requirements..."

    # Check for Xcode
    if ! command -v xcodebuild &> /dev/null; then
        print_error "xcodebuild not found. Install Xcode Command Line Tools."
    fi

    # Check for create-dmg
    if ! command -v create-dmg &> /dev/null; then
        print_warning "create-dmg not found. Install with: brew install create-dmg"
    fi

    # Check for signing identity
    if ! security find-identity -v -p codesigning | grep -q "Developer ID Application"; then
        print_warning "No Developer ID Application certificate found"
        print_warning "Code signing will be skipped. App will not run on other machines."
    fi
}

clean_build() {
    print_step "Cleaning previous builds..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$RELEASE_DIR"
}

build_app() {
    print_step "Building Release configuration..."

    xcodebuild clean build \
        -scheme "$SCHEME" \
        -configuration Release \
        -derivedDataPath "$BUILD_DIR" \
        | xcpretty || xcodebuild clean build \
        -scheme "$SCHEME" \
        -configuration Release \
        -derivedDataPath "$BUILD_DIR"

    if [ ! -d "$BUILD_DIR/Build/Products/Release/$APP_NAME.app" ]; then
        print_error "Build failed - app bundle not found"
    fi

    print_step "Build successful: $BUILD_DIR/Build/Products/Release/$APP_NAME.app"
}

sign_app() {
    print_step "Signing application..."

    local identity=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -n 1 | awk -F'"' '{print $2}')

    if [ -z "$identity" ]; then
        print_warning "Skipping code signing - no Developer ID certificate found"
        return 0
    fi

    codesign --force --deep --sign "$identity" \
        --options runtime \
        --entitlements "$APP_NAME/$APP_NAME.entitlements" \
        "$BUILD_DIR/Build/Products/Release/$APP_NAME.app"

    # Verify signature
    codesign -dv --verbose=4 "$BUILD_DIR/Build/Products/Release/$APP_NAME.app" 2>&1 | grep -q "Signature=adhoc" && \
        print_warning "Using ad-hoc signature" || \
        print_step "Code signing successful"
}

create_dmg() {
    print_step "Creating DMG..."

    local dmg_name="$APP_NAME-$VERSION.dmg"

    if command -v create-dmg &> /dev/null; then
        create-dmg \
            --volname "$APP_NAME" \
            --window-pos 200 120 \
            --window-size 600 400 \
            --icon-size 100 \
            --icon "$APP_NAME.app" 175 190 \
            --hide-extension "$APP_NAME.app" \
            --app-drop-link 425 185 \
            "$RELEASE_DIR/$dmg_name" \
            "$BUILD_DIR/Build/Products/Release/$APP_NAME.app" || true
    else
        # Fallback to hdiutil
        print_warning "create-dmg not found, using hdiutil"

        hdiutil create -volname "$APP_NAME" \
            -srcfolder "$BUILD_DIR/Build/Products/Release/$APP_NAME.app" \
            -ov -format UDZO \
            "$RELEASE_DIR/$dmg_name"
    fi

    if [ -f "$RELEASE_DIR/$dmg_name" ]; then
        print_step "DMG created: $RELEASE_DIR/$dmg_name"
    else
        print_error "DMG creation failed"
    fi
}

generate_checksum() {
    print_step "Generating checksum..."

    local dmg_name="$APP_NAME-$VERSION.dmg"

    shasum -a 256 "$RELEASE_DIR/$dmg_name" > "$RELEASE_DIR/$dmg_name.sha256"

    echo ""
    echo "SHA256 Checksum:"
    cat "$RELEASE_DIR/$dmg_name.sha256"
    echo ""
}

verify_build() {
    print_step "Verifying build..."

    # Check app bundle
    if [ -d "$BUILD_DIR/Build/Products/Release/$APP_NAME.app" ]; then
        echo "  ✓ App bundle exists"
    else
        print_error "App bundle not found"
    fi

    # Check signature
    if codesign -dv "$BUILD_DIR/Build/Products/Release/$APP_NAME.app" 2>&1 | grep -q "Signature"; then
        echo "  ✓ App is signed"
    else
        echo "  ⚠ App is not signed"
    fi

    # Check DMG
    local dmg_name="$APP_NAME-$VERSION.dmg"
    if [ -f "$RELEASE_DIR/$dmg_name" ]; then
        echo "  ✓ DMG created"
        local size=$(du -h "$RELEASE_DIR/$dmg_name" | cut -f1)
        echo "    Size: $size"
    fi
}

print_next_steps() {
    echo ""
    print_step "Build complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Test the app: open $BUILD_DIR/Build/Products/Release/$APP_NAME.app"
    echo "  2. Test the DMG: open $RELEASE_DIR/$APP_NAME-$VERSION.dmg"
    echo "  3. Submit for notarization (see RELEASE.md)"
    echo "  4. Create GitHub release with DMG and checksum"
    echo ""
}

# Main execution
main() {
    echo "========================================"
    echo " $APP_NAME Release Build v$VERSION"
    echo "========================================"
    echo ""

    check_requirements
    clean_build
    build_app
    sign_app
    create_dmg
    generate_checksum
    verify_build
    print_next_steps
}

# Run main function
main
