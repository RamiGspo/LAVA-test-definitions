#!/bin/bash

# shellcheck disable=SC2034
LOW=0
HIGH=1

ANALOG_START=0
ANALOG_END=9000
ANALOG_STEP=1000
ANALOG_RANGE=250

PROCIMG_WAIT=1

# Function to check if a module is NOT configured
is_module_configured() {
    info_msg "$1" | grep -q "but NOT CONFIGURED"
}

# Function to check if a module is not physically present
is_module_not_present() {
    info_msg "$1" | grep -q "Module is NOT present"
}

# Function to check if a update for modules is needed
is_module_updated() {
    info_msg "$1" | grep -q "The firmware of some I/O modules must be updated."
}

# Function to check hardware setup configured in pictory.
piTest_Check_config() (
    # $1: TEST_CASE_NAME
    # $2: PIT_TEST_OUTPUT
    test_case_name=$1
    pi_test_output=$2

    # Check if piTest -x fails
    if ! piTest -x
    then
        report_fail "$test_case_name-piTest-x-fail"
    fi

    # Check if a module is NOT configured
    if is_module_configured "$pi_test_output"
    then
        report_fail "$test_case_name-HW_CONFIGURED"
    else
        report_pass "$test_case_name-HW_CONFIGURED"
    fi

    # Check if a module is not physically present
    if is_module_not_present "$pi_test_output"
    then
        report_fail "$test_case_name-HW_NOT_PRESENT"
    else
        report_pass "$test_case_name-HW_NOT_PRESENT"
    fi

    # Check if an update is required
    if is_module_updated "$pi_test_output"
    then
        lava-test-case "$test_case_name-HW_UPDATE" --result fail
    fi
)

# Function for setting the IO value
piTest_setIOValue() (
    test_case_name=$1
    variable=$2
    value=$3

    output=$(piTest -w "$variable","$value")
    ret=$?

    # XXX: hack: piTest is broken:
    #  - no proper exit code on failure
    #  - no usage of stderr for error messages

    if echo "$output" | grep -E "(Cannot find variable)|(Wrong arguments)"
    then
        report_fail "$test_case_name-piTest"
    return
    fi

    # XXX: piTest never seems to return an error code
    if [ "$ret" -ne 0 ]
    then
        report_fail "$test_case_name-piTest-write"
    return
    fi
)

# Function for checking digital IO value
piTest_validateIOValue() (
    if [ "$(piTest -v "$2")" != "Cannot read variable info" ]
    then
        if [ "$(piTest -q -1 -r "$2")" -ne "$3" ]
        then
            report_fail "$1-$2"
        else
            report_pass "$1-$2"
        fi
    else
        report_fail "$1-variable-not-found-$2"
    fi
)

piTest_getOffset() (
    # $1: Variable name
    local var="$1"
    local offset=0
    offset=$(piTest -v "$var")
    offset=$(echo "$offset" | grep -oP '(?<=offset:\s)\d+')
    echo "$offset"
)

piTest_set_bit() (
    # $1: Variable name
    # $2: Bit number (bi0-bit7)
    # $3: Status to set the bit to (0 or 1)
    local var="$1"
    local bit="$2"
    local bit_status="$3"
    local offset=0
    offset=$(piTest_getOffset "$var")
    piTest -s "$offset","$bit","$bit_status"
)

# Function for checking digital IO bit status
piTest_validate_BitStatus() (
    # $1: Variable name
    # $2: Bit number (bi0-bit7)
    # $3: Expected status of the bit (0 or 1)
    local var="$1"
    local bit="$2"
    local bit_status="$3"
    local offset=0
    local val=0
    offset=$(piTest_getOffset "$var")
    val=$(piTest -qg "$offset","$bit")
    if [ "$val" = "$bit_status" ]; then
        return 0
    else
        return 1
    fi
)

# Function for checking analog IO value
piTest_validateAIOValue() (
    if [ "$(piTest -v "$2")" != "Cannot read variable info" ]
    then
        value=$(piTest -q -1 -r "$2")
        range_low=$(( $3 - ANALOG_RANGE ))
        range_high=$(( $3 + ANALOG_RANGE ))

        if [ $range_low -lt 0 ]; then
            range_low=0
        fi

        if ! [ "$value" -ge "$range_low" ] && [ "$value" -le "$range_high" ];
        then
            report_fail "$1-$2-value-$3-is-$value"
        fi
    else
        report_fail "$1-variable-not-found-$2"
    fi
)

# Function for digital IO
piTest_Check_001() (
    # $1: TEST_CASE_NAME
    # $2: INPUT
    # $3: OUTPUT
    test_case_name=$1
    input=$2
    output=$3

    # set output to low
    piTest_setIOValue "$test_case_name" "$output" "$LOW"
    # wait for process image
    sleep "$PROCIMG_WAIT"
    piTest_validateIOValue "$test_case_name" "$input" "$LOW"

    # set output to high
    piTest_setIOValue "$test_case_name" "$output" "$HIGH"
    # wait for process image
    sleep "$PROCIMG_WAIT"
    piTest_validateIOValue "$test_case_name" "$input" "$HIGH"
)

# Function for analog IO
piTest_Check_002() (
    # $1: TEST_CASE_NAME
    # $2: INPUT
    # $3: OUTPUT
    test_case_name=$1
    input=$2
    output=$3

    # set output with ANALOG_VALx
    for analog_value in $(seq $ANALOG_START $ANALOG_STEP $ANALOG_END); do
        piTest_setIOValue "$test_case_name" "$output" "$analog_value"
        # Wait for process image
        sleep "$PROCIMG_WAIT"
        piTest_validateAIOValue "$test_case_name" "$input" "$analog_value"
    done

    # set output to zero
    piTest_setIOValue "$test_case_name" "$output" "$LOW"
    # wait for process image
    sleep "$PROCIMG_WAIT"
    piTest_validateAIOValue "$test_case_name" "$input" "$LOW"
)

test_pt_connect_digin1_relaisX() (
    # $1: TEST_CASE_NAME
    # $2: NAME VARIABLE RELAY
    local test_case_name="$1"
    local variable_relay="$2"
    local variable_di="RevPiStatus"
    local bit_relay=0
    local bit_di=6
    local val_di=0
    local ret=0
    if [ "$(piTest -v "$variable_relay")" = "Cannot read variable info" ]; then
        report_fail "$test_case_name: Variable $variable_relay cannot be read"
        return 1
    fi
    if [ "$(piTest -v "$variable_di")" = "Cannot read variable info" ]; then
        report_fail "$test_case_name: Variable $variable_di cannot be read"
        return 1
    fi
    if [ "$variable_relay" = "RevPiLED" ]; then
        bit_relay=6
        val_di=1
    fi
    piTest_set_bit "$variable_relay" "$bit_relay" "$LOW"
    # wait for process image
    sleep "$PROCIMG_WAIT"
    piTest_validate_BitStatus "$variable_di" "$bit_di" "$val_di"
    ret=$?
    if [ "$ret" -eq 1 ]; then
        report_fail "$test_case_name-$variable_di-bit$bit_relay-$val_di"
        return 1
    fi
    piTest_set_bit "$variable_relay" "$bit_relay" "$HIGH"
    # wait for process image
    sleep "$PROCIMG_WAIT"
    piTest_validate_BitStatus "$variable_di" "$bit_di" $((1 - val_di))
    ret=$?
    if [ "$ret" -eq 1 ]; then
        report_fail "$test_case_name-$variable_di-bit$bit_relay-$((1 - val_di))"
        return 1
    fi
)
