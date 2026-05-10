#!/bin/bash
#
# install-app.sh - Install Android APK via ADB with auto-uninstall
#
# Usage: ./install-app.sh <path-to-apk> [package-name]
#
# This script automatically uninstalls any existing version of the app
# before installing the new APK.
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect package name from APK using aapt
get_package_name() {
    local apk_path="$1"
    local package_name

    # Try to use aapt or aapt2 to get package name
    if command -v aapt &> /dev/null; then
        package_name=$(aapt dump badging "$apk_path" 2>/dev/null | grep -o "^package: name='[^']*'" | sed "s/.*name='\([^']*\)'/\1/")
    elif command -v aapt2 &> /dev/null; then
        package_name=$(aapt2 dump badging "$apk_path" 2>/dev/null | grep -o "^package: name='[^']*'" | sed "s/.*name='\([^']*\)'/\1/")
    elif [ -n "$2" ]; then
        # Fallback to manually provided package name
        package_name="$2"
    else
        log_error "Cannot detect package name. Please install aapt/aapt2 or provide package name as second argument."
        exit 1
    fi

    echo "$package_name"
}

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# T003: ADB device detection
check_device() {
    local devices
    devices=$(adb devices 2>/dev/null | grep -v "List of devices" | grep "device$" | wc -l)

    if [ "$devices" -eq 0 ]; then
        log_error "No device found. Please connect your Android device via USB and enable USB debugging."
        exit 1
    fi

    if [ "$devices" -gt 1 ]; then
        log_warn "Multiple devices detected. Using first device."
    fi

    log_info "Device detected successfully"
}

# T004: APK path validation
validate_apk() {
    local apk_path="$1"

    if [ -z "$apk_path" ]; then
        log_error "APK path not provided. Usage: $0 <path-to-apk> [package-name]"
        exit 1
    fi

    if [ ! -f "$apk_path" ]; then
        log_error "APK file not found: $apk_path"
        exit 1
    fi

    if [ ! -r "$apk_path" ]; then
        log_error "APK file is not readable: $apk_path"
        exit 1
    fi

    log_info "APK file validated: $apk_path"
}

# T006: Check for existing package
check_existing_package() {
    local package="$1"
    local exists

    exists=$(adb shell pm list packages 2>/dev/null | grep -c "^package:$package" || true)

    if [ "$exists" -gt 0 ]; then
        return 0  # Package exists
    else
        return 1  # Package does not exist
    fi
}

# T007: Auto-uninstall existing package
uninstall_existing() {
    local package="$1"

    if check_existing_package "$package"; then
        log_warn "Existing installation found. Uninstalling..."
        adb uninstall "$package" >/dev/null 2>&1
        log_info "Previous version uninstalled"
    fi
}

# T005: Install APK
install_apk() {
    local apk_path="$1"

    log_info "Installing APK..."
    if adb install -r "$apk_path" 2>&1; then
        log_info "APK installed successfully!"
        return 0
    else
        log_error "Failed to install APK"
        return 1
    fi
}

# T009: Device selection for multiple devices
select_device() {
    local device_list
    local device_count

    device_list=$(adb devices 2>/dev/null | grep "device$" | grep -v "List of devices" | cut -f1)
    device_count=$(echo "$device_list" | wc -l)

    if [ "$device_count" -gt 1 ]; then
        log_warn "Multiple devices available:"
        echo "$device_list" | nl
        echo ""
        read -p "Enter device number [1]: " device_num
        device_num="${device_num:-1}"

        local selected_device
        selected_device=$(echo "$device_list" | sed -n "${device_num}p")

        if [ -n "$selected_device" ]; then
            adb -s "$selected_device" wait-for-device
            log_info "Using device: $selected_device"
        fi
    fi
}

# Main execution
main() {
    local apk_path="$1"

    log_info "Starting ADB app installation..."

    check_device
    select_device
    validate_apk "$apk_path"

    # Detect package name from APK
    local package_name
    package_name=$(get_package_name "$apk_path" "$2")
    log_info "Package name detected: $package_name"

    uninstall_existing "$package_name"
    install_apk "$apk_path"

    log_info "Installation complete!"
}

# Run main function
main "$@"