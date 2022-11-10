# LAVA-test-definitions

A set of testing scripts designed to work with LAVA.

# Compilation of testsuites


| Job name | Device type |
| -------- | ----------- |
| [RevPi_Connect - TestSuite 001](./automated/testsuites/connect-testsuite-001.yaml) | RevPi_Connect |
| [RevPi_Core - TestSuite 001](./automated/testsuites/core-testsuite-001.yaml) | RevPi_Core |
# Compilation of tests definitions for devices


| Test name | Description | Devices |
| --------- | ----------- | ------- |
| [Basic test 0001 - Repo](./automated/linux/basic-tests/basic-test-0001_repo.yaml) | This test checks if RevolutionPi-Repository works. | ['Core', 'Core 3', 'core 3+', 'Core S'] |
| [Basic test 0002 - Repo with script](./automated/linux/basic-tests/basic-test-0002_repo-script.yaml) | This test checks if RevolutionPi-Repository works and run a simple script. | ['Core', 'Core 3', 'core 3+', 'Core S'] |
| [Test eth-ethtool](./automated/linux/ethernet/test-eth-ethtool.yaml) | Test displays parameters of network interface controller (NIC). | ['Core', 'Core 3', 'core 3+', 'Core S', 'Connect', 'Connect+', 'Connect S', 'Connect SE'] |
| [Test eth-iperf3](./automated/linux/ethernet/test-eth-iperf3.yaml) | Measurements of the maximum achievable bandwidth on IP networks. | ['Core', 'Core 3', 'core 3+', 'Core S', 'Connect', 'Connect+', 'Connect S', 'Connect SE'] |
| [Test LEDs 1](./automated/linux/leds/test-leds1.yaml) | Listing default LEDs with visual test - LEDs on/off - green/red. | ['Core', 'Core 3', 'core 3+', 'Core S', 'Connect', 'Connect+', 'Connect S', 'Connect SE'] |
| [Test usb-1](./automated/linux/piTest/test-PT-1.yaml) | All hardware devices are listed and shown with text: Module is present. | ['Core', 'Core 3', 'core 3+', 'Core S', 'Connect', 'Connect+', 'Connect S', 'Connect SE'] |
| [Test pc-1](./automated/linux/picontrol/test-pc-1.yaml) | Check picontrol driver and picontrol0 device | ['Core', 'Core 3', 'core 3+', 'Core S', 'Connect', 'Connect+', 'Connect S', 'Connect SE'] |
| [Test usb-2](./automated/linux/usb/test-usb-2.yaml) | Test for correct USB data transfer with a USB flash disk. Flash disk will be formated | ['Core', 'Core 3', 'core 3+', 'Core S', 'Connect', 'Connect+', 'Connect S', 'Connect SE'] |
| [Test usb-3](./automated/linux/usb/test-usb-3.yaml) | Test read speed from USB flash disk | ['Core', 'Core 3', 'core 3+', 'Core S', 'Connect', 'Connect+', 'Connect S', 'Connect SE'] |
| [Test usb-4](./automated/linux/usb/test-usb-4.yaml) | Test write speed from USB flash disk | ['Core', 'Core 3', 'core 3+', 'Core S', 'Connect', 'Connect+', 'Connect S', 'Connect SE'] |
| [Test IOCycle-1](./automated/revpi/iocycle/test-iocycle-1.yaml) | Cycle should be displayed | ['Core', 'Core 3', 'core 3+', 'Core S', 'Connect', 'Connect+', 'Connect S', 'Connect SE'] |
| [Test piBridge.](./automated/revpi/pibridge/test-pb-1.yaml) | Test read/write from/to RevPi modules using piTest | ['Core', 'Core 3', 'core 3+', 'Core S', 'Connect', 'Connect+', 'Connect S', 'Connect SE'] |
# Compilation of jobs


| Job name | Device type |
| -------- | ----------- |
| [Test PT-1 - Connect](./automated/linux/jobs-definition/connect/job-PT-1.yaml) | RevPi_Connect |
| [Test eth-ethtool - Connect](./automated/linux/jobs-definition/connect/job-eth-ethtool.yaml) | RevPi_Connect |
| [Test eth-iperf3 - Connect](./automated/linux/jobs-definition/connect/job-eth-iperf3.yaml) | RevPi_Connect |
| [Test LEDs 1 - Check LEDs with visual test - LEDs on/off - green/red."](./automated/linux/jobs-definition/connect/job-leds1.yaml) | RevPi_Connect |
| [Test pc-1 - Connect](./automated/linux/jobs-definition/connect/job-pc-1.yaml) | RevPi_Connect |
| [Test USB data transfer with USB flash disk - Connect](./automated/linux/jobs-definition/connect/job-usb-2.yaml) | RevPi_Connect |
| [Test read speed from USB flash disk - Connect](./automated/linux/jobs-definition/connect/job-usb-3.yaml) | RevPi_Connect |
| [Test write speed from USB flash disk - Connect](./automated/linux/jobs-definition/connect/job-usb-4.yaml) | RevPi_Connect |
| [Test PT-1 - Core](./automated/linux/jobs-definition/core/job-PT-1.yaml) | RevPi_Core |
| [Test eth-ethtool - Core](./automated/linux/jobs-definition/core/job-eth-ethtool.yaml) | RevPi_Core |
| [Test eth-iperf3 - Core](./automated/linux/jobs-definition/core/job-eth-iperf3.yaml) | RevPi_Core |
| [Test LEDs 1 - Check LEDs with visual test - LEDs on/off - green/red."](./automated/linux/jobs-definition/core/job-leds1.yaml) | RevPi_Core |
| [Test pc-1 - Core](./automated/linux/jobs-definition/core/job-pc-1.yaml) | RevPi_Core |
| [Test USB data transfer with USB flash disk - Core](./automated/linux/jobs-definition/core/job-usb-2.yaml) | RevPi_Core |
| [Test read speed from USB flash disk - Core](./automated/linux/jobs-definition/core/job-usb-3.yaml) | RevPi_Core |
| [Test write speed from USB flash disk - Core](./automated/linux/jobs-definition/core/job-usb-4.yaml) | RevPi_Core |
| [Core3 - First job from GitHub Repository](./automated/linux/jobs-definition/job-0001_test-repo.yaml) | RevPi_Core |
| [RevPi_Core - Job from GitHub RevolutionPi Repository with single shell script](./automated/linux/jobs-definition/job-0002_test-repo-script.yaml) | RevPi_Core |
| [Test iocycle-1](./automated/revpi/jobs-definition/connect/job-iocycle-1.yaml) | RevPi_Connect |
| [Test iocycle-1](./automated/revpi/jobs-definition/core/job-iocycle-1.yaml) | RevPi_Core |
| [Test pibridge-1](./automated/revpi/jobs-definition/job-pb-1.yaml) | RevPi_Core |
