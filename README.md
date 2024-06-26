# LAVA-test-definitions

A set of testing scripts designed to work with LAVA.

## Repository Layout

```
.
├── automated				# test definitions
│   ├── bin					# misc. tools to use with this repo
│   ├── deployment			# test definitions for deploying images onto boards
│   ├── device-config		# pictory configuration files for RevPi boards
│   ├── health-checks		# definitions of health checks for various boards
│   ├── lib					# reusable code
│   ├── linux				# linux-specific tests
│   ├── revpi				# revpi-specific tests
│   └── utils				# various utilities used by jobs
├── docs					# general documentation
└── plans					# commonly used job definitions
```

## Naming schema for Pictory configurations

To be able to uniquely identify the I/O of connected modules for tests the
following naming schema should be used:

`$MODULE_$SIDE$NUMBER_$IOTYPE$IO$NUMBER`

- `$MODULE`: DIO, AIO, etc.
- `$SIDE`: L, R
- `$IOTYPE`: D (Digital), A (Analog)
-  - optional, only needed when a MIO is used
- `$IO`: I (Input), O (Output), C (Counter), P (PWM)

examples:
 - `DIO_R1_I1` - DIO connected directly on the right of the RevPi, Input number 1
 - `MIO_L4_DO4` - MIO connected as 4th device to the left of the RevPi, Digital
   Output number 4
 - `DIO_R2_C1` - DIO connected as 2nd device to the right of the RevPi, Counter
   Output number 1

This naming schema should be enforced in the Pictory configuration to be
usable in scripts.

## Naming schema for plans

In order to simplify the testsuites, the following naming schema will be used for the plans:

`$TYPE-$CONFIG_NR.yaml`

- `$TYPE`: RevPi_Core, RevPi_Compact, etc.
- `$CONFIG_NR`: Configuration number used with RevPi (See [Configuration RevPi devices](./automated/device-config/README.md))
