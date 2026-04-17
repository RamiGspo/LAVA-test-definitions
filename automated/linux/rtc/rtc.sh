#!/bin/sh

# shellcheck disable=SC1091
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
TESTS="rtc-1 rtc-2a"
DATE_SET="2023-12-01 11:11:00"
SKIP_REBOOT="true"
TOLERANCE_LOW_SEC=10
TOLERANCE_DEFAULT_MIN=10

usage() {
    echo "Usage: $0 [-s <true|false>] [-r <true|false>] [-t TESTS] [-d DATE_SET]" 1>&2
    echo "Example: $0 -s true -r false -t 'rtc-1 rtc-2a' -d '2023-12-01 11:11:00'" 1>&2
    exit 1
}

while getopts "s:r:t:d:h" o; do
    case "$o" in
    s)
        install_deps util-linux-extra
        ;;
    r) SKIP_REBOOT="${OPTARG}" ;;
    t) TESTS="${OPTARG}" ;;
    d) DATE_SET="${OPTARG}" ;;
    h|*) usage ;;
    esac
done

check_hwclock() {
    EXPECTED_TIME="$1"
    TOLERANCE_MINUTES="$2"
    TOLERANCE_SECONDS=$((TOLERANCE_MINUTES * 60))

    if [ "$TOLERANCE_SECONDS" -lt "$TOLERANCE_LOW_SEC" ]; then
        TOLERANCE_SECONDS=$TOLERANCE_LOW_SEC
    fi

    # Convert the date strings to epoch timestamps
    EXPECTED_TIMESTAMP=$(date -d "$EXPECTED_TIME" +%s)
    HWCLOCK_TIMESTAMP=$(date -d "$(hwclock)" +%s)

    # Calculate the difference in seconds between expected and actual timestamps
    TIME_DIFF=$((HWCLOCK_TIMESTAMP - EXPECTED_TIMESTAMP))

    info_msg "Expected timestamp: $EXPECTED_TIMESTAMP"
    info_msg "hwclock timestamp: $HWCLOCK_TIMESTAMP"
    info_msg "Tolerance in seconds: $TOLERANCE_SECONDS"

    # Check if the difference is within the tolerance
    if [ "$TIME_DIFF" -lt "$TOLERANCE_SECONDS" ]; then
        info_msg "hwclock is correct after setting."
        return 0
    else
        error_msg "hwclock is not correct after setting."
    fi
}

rtc_1() {
    info_msg "Set hardware clock to $DATE_SET"
    hwclock --set --date "$DATE_SET"
    # Check if hwclock is correct after setting
    check_hwclock "$DATE_SET"
}

rtc_2a() {
    # Disable NTP, set hardware clock to "$DATE_SET"
    timedatectl set-ntp false
    info_msg "Set hardware clock to $DATE_SET"
    hwclock --set --date "$DATE_SET"
    check_hwclock "$DATE_SET"
    # Reboot DUT if desired
    [ "${SKIP_REBOOT}" = "true" ] || shutdown -r +1
}

rtc_2b() {
    # Verify the expected time after reboot
    check_hwclock "$DATE_SET" "$TOLERANCE_DEFAULT_MIN"
}

run() {
    local test="$1"
    test_case_id="${test}"
    info_msg "Running ${test_case_id} test..."

    case "$test" in
    "rtc-1")
        rtc_1
        ;;
    "rtc-2a")
        rtc_2a
        ;;
    "rtc-2b")
        rtc_2b
        ;;
    *) error_msg "Invalid test case '$test_case_id'" ;;
    esac

    check_return "${test_case_id}"
}

# Test run.
create_out_dir "${OUTPUT}"

for t in $TESTS; do
    run "$t"
done

# Enable NTP again after tests are run (only if the DUT should not reboot)
[ "${SKIP_REBOOT}" != "true" ] || timedatectl set-ntp true
