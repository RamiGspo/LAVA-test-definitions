#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
export RESULT_FILE="$OUTPUT/result.txt"
TESTS="keyrings apt-sources sudoers etc"

KEYRING_DIR="/usr/share/keyrings"

APT_SOURCES_FILES="/etc/apt/sources.list"
APT_SOURCES_DIR="/etc/apt/sources.list.d"

SUDOERS_FILES="/etc/sudoers"
SUDOERS_DIR="/etc/sudoers.d"

ETC_FILES="
    /etc/hosts
    /etc/hostname
"

usage() {
    echo "Usage: $0 [-s <true|false>] [-t TESTS]"
    exit "$1"
}

while getopts "s:t:h" o; do
    case "$o" in
    s) ;;
    t) TESTS="$OPTARG" ;;
    h) usage 0 ;;
    *) usage 1 >&2 ;;
    esac
done

# check for correct permissions of file
# $1: permissions in octal format
# $2..: files
check_permission_file() {
    local expected_permissions="$1"
    local actual_permission
    local test_case
    shift

    for f; do
        test_case="file-perms_$f"
        actual_permission="$(stat -c "%a" "$f")"
        if [ "$actual_permission" = "$expected_permissions" ]; then
            report_pass "$test_case"
        else
            printf "%s: %s (expected %s)\n" "$f" "$actual_permission" "$expected_permissions"
            report_fail "$test_case"
        fi
    done
}

check_permission_dir() {
    local expected_permissions="$1"
    shift

    for d; do
        # shellcheck disable=SC2046
        check_permission_file "$expected_permissions" $(find "$d" -type f -print)
    done
}

run() {
    local test_case_id="$1"

    case "$test_case_id" in
    keyrings)
        report_set_start "file-perms_keyrings"
        # shellcheck disable=SC2086
        check_permission_file 644 $KEYRING_FILES
        # shellcheck disable=SC2086
        check_permission_dir 644 $KEYRING_DIR
        report_set_stop
        ;;
    apt-sources)
        report_set_start "file-perms_apt-sources"
        # shellcheck disable=SC2086
        check_permission_file 644 $APT_SOURCES_FILES
        # shellcheck disable=SC2086
        check_permission_dir 644 $APT_SOURCES_DIR
        report_set_stop
        ;;
    sudoers)
        report_set_start "file-perms_sudoers"
        # shellcheck disable=SC2086
        check_permission_file 440 $SUDOERS_FILES
        # shellcheck disable=SC2086
        check_permission_dir 440 $SUDOERS_DIR
        report_set_stop
        ;;
    etc)
        report_set_start "file-perms_etc"
        # shellcheck disable=SC2086
        check_permission_file 644 $ETC_FILES
        report_set_stop
        ;;
    esac
}

create_out_dir "$OUTPUT"

for t in $TESTS; do
    run "$t"
done
