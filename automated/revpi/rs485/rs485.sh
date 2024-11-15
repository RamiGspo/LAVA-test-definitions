#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
SKIP_INSTALL="true"
RSDEV="/dev/ttyRS485"
TESTS="rs485-client"
BAUD=19200
LIMIT=50

usage() {
    echo "Usage: $0 [-s <true|false>] [-t TESTS] [-d RSDEV] [-b BAUD] [-l LIMIT]" 1>&2
    echo "Example: $0 -s true -t 'rs485-client' -d /dev/ttyRS485 -b 19200 -l 12" 1>&2
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

rs485_client() {
    local errors=0

    if errors="$(./rs485.py "$RSDEV" -b "$BAUD" -l "$LIMIT" client)"; then
        result="pass"
    else
        result="fail"
    fi
    add_metric rs485 "$result" "$errors" errors
}

run() {
    local test="$1"
    test_case_id="${test}"
    info_msg "Running ${test_case_id} test..."

    case "$test" in
    "rs485-client") rs485_client ;;
    *) error_msg "Unknown test case '$test'" >&2
    esac
}

# Test run.
create_out_dir "${OUTPUT}"

install_deps "python3-crcmod" "$SKIP_INSTALL"

if [ ! -c "$RSDEV" ] ; then
	error_msg "RS485 device $RSDEV not found!"
fi

for t in $TESTS; do
    run "$t"
done
