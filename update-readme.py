import glob
import yaml

revpi_LAVA_dir = sorted(glob.glob('./automated/**/*.yaml', recursive = True))

revpi_title = """# LAVA-test-definitions

A set of testing scripts designed to work with LAVA.

"""

revpi_tests = """# Compilation of tests definitions for devices


| Test name | Description | Devices |
| --------- | ----------- | ------- |
"""

revpi_jobs = """# Compilation of jobs


| Job name | Device type |
| -------- | ----------- |
"""

revpi_suites = """# Compilation of testsuites


| Job name | Device type |
| -------- | ----------- |
"""

for template in revpi_LAVA_dir:
    with open(template, 'r') as f:
        file_data = yaml.safe_load(f)

        if template.__contains__("job"):
            name = file_data['job_name']
            device = file_data['device_type']

            revpi_jobs += f"| [{name }]({template}) | {device} |\n"
        else:
            if template.__contains__("testsuite"):
                name = file_data['job_name']
                device = file_data['device_type']

                revpi_suites += f"| [{name }]({template}) | {device} |\n"
            else:
                if template.__contains__("test"):
                    name = file_data['metadata']['name']
                    description = file_data['metadata']['description']
                    device = file_data['metadata']['devices']

                    revpi_tests += f"| [{name }]({template}) | {description} | {device} |\n"

with open("README.md", "w") as f:
    readme = revpi_title
    readme += revpi_suites
    readme += revpi_tests
    readme += revpi_jobs
    f.write(readme)