#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
SKIP_INSTALL="true"
RSDEV="/dev/ttyRS485-0"
TESTS="rs485-dev-perms rs485-dev-group rs485-client"
BAUD=19200
LIMIT=50

usage() {
    echo "Usage: $0 [-s <true|false>] [-t TESTS] [-d RSDEV] [-b BAUD] [-l LIMIT]" 1>&2
    echo "Example: $0 -s true -t 'rs485-client' -d /dev/ttyRS485-0 -b 19200 -l 12" 1>&2
    exit 1
}

while getopts "s:t:d:b:l:h" o; do
    case "$o" in
    s) SKIP_INSTALL="${OPTARG}" ;;
    t) TESTS="${OPTARG}" ;;
    d) RSDEV="${OPTARG}" ;;
    b) BAUD="${OPTARG}" ;;
    l) LIMIT="${OPTARG}" ;;
    h|*) usage ;;
    esac
done

# on bullseye and older, a single RS485 device was named /dev/ttyRS485 instead
# of /dev/ttyRS485-0. fall back to the legacy name if the specified device does
# not exist.
if [ ! -e "$RSDEV" ] && [ "$RSDEV" = "/dev/ttyRS485-0" ]; then
    . /etc/os-release
    if [ "${VERSION_ID:-0}" -lt 12 ]; then
        RSDEV="/dev/ttyRS485"
        info_msg "falling back to legacy RS485 device name: $RSDEV"
    fi
fi

rs485_client() {
    local errors=0

    if errors="$(./rs485.py "$RSDEV" -b "$BAUD" -l "$LIMIT" client)"; then
        result="pass"
    else
        result="fail"
    fi
    add_metric rs485-client "$result" "$errors" errors
}

rs485_dev_present() {
    # the RS485 device being present is a prerequisite for all tests. exit and
    # mark all remaining tests as skipped if the RS485 device isn't present.
    # the rs485-dev-present test should always be the first test among the rs485
    # tests.
    [ -L "$RSDEV" ] && [ -c "$RSDEV" ]
    exit_on_fail rs485-dev-present \
        "rs485-dev-perms rs485-dev-group rs485-client"
}

rs485_dev_perms() {
    local dev_perms=""

    if ! dev_perms="$(stat -Lc "%a" "$RSDEV")"; then
        printf "Unable to stat rs485 dev '%s'\n" "$RSDEV" >&2
        report_fail rs485-dev-perms
        return 1
    fi

    [ "$dev_perms" = "660" ]
    check_return rs485-dev-perms
}

rs485_dev_group() {
    local dev_group=""

    if ! dev_group="$(stat -Lc "%G" "$RSDEV")"; then
        printf "Unable to stat rs485 dev '%s'\n" "$RSDEV" >&2
        report_fail rs485-dev-group
        return 1
    fi

    [ "$dev_group" = "dialout" ]
    check_return rs485-dev-group
}

run() {
    local test="$1"
    test_case_id="${test}"
    info_msg "Running ${test_case_id} test..."

    case "$test" in
    rs485-dev-present) rs485_dev_present ;;
    rs485-dev-perms) rs485_dev_perms ;;
    rs485-dev-group) rs485_dev_group ;;
    "rs485-client") rs485_client ;;
    *) error_msg "Unknown test case '$test'" >&2
    esac
}

# Test run.
create_out_dir "${OUTPUT}"

install_deps "python3-crcmod" "$SKIP_INSTALL"

# rs485-dev-present test is always first
# if it fails it marks all others as skipped
TESTS="rs485-dev-present $TESTS"

for t in $TESTS; do
    run "$t"
done
