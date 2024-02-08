#!/bin/bash

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
TESTS="
sysinfo-image-release
sysinfo-uname
sysinfo-dpkg"
SKIP_INSTALL="false"

usage() {
    echo "Usage: $0 [-s <true|false>] [-t test]" 1>&2
    exit 1
}

while getopts "s:t:h" o; do
    case "$o" in
    s) SKIP_INSTALL="${OPTARG}" ;;
    t) TESTS="${OPTARG}" ;;
    h|*) usage ;;
    esac
done

install() {
    apt-get update -q
    apt-get -y install tree
}

run() {
    local test_case_id="$1"
    info_msg "Running ${test_case_id} test..."

    case "$test_case_id" in
    "sysinfo-image-release")
        cat /etc/revpi/image-release
        ;;
    "sysinfo-uname")
        uname -a
        ;;
    "sysinfo-top")
        top -n 1
        ;;
    "sysinfo-dmesg")
        dmesg
        ;;
    "sysinfo-dpkg")
        dpkg -l --no-pager
        ;;
    "sysinfo-tree")
        tree /sys/
        ;;
    "sysinfo-fdtdump")
        fdtdump /sys/firmware/fdt
        ;;
    *)
        report_fail "Undefined test..."
        ;;
    esac

    check_return "${test_case_id}"
}

# Test run
create_out_dir "${OUTPUT}"

if [ "${SKIP_INSTALL}" = "true" ] || [ "${SKIP_INSTALL}" = "True" ]; then
    info_msg "Package installation skipped"
else
    install
fi

for t in $TESTS; do
    run "$t"
done
