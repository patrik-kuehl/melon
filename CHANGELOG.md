# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2024-08-02

### Added

-   Added `melon/container/wait_until_healthy` to wait until the given container is healthy.

## [0.3.0] - 2024-07-28

### Added

-   Added `melon/container/set_health_check_retries` to set the health check retry count of a given container.
-   Added `melon/container/set_health_check_start_period` to set the health check start period of a given container.
-   Added `melon/container/set_health_check_timeout` to set the health check timeout of a given container.
-   Added `melon/container/set_health_check_interval` to set the health check interval of a given container.
-   Added `melon/container/set_health_check_command` to set the health check command of a given container.

## [0.2.0] - 2024-07-26

### Added

-   Added `melon/container/set_memory_limit` to set the memory limit of a given container.
-   Added `melon/container/set_env_file` to set the environment file of a given container.

## [0.1.0] - 2024-07-23

### Added

-   Added `melon/container/mapped_port` to get a mapped port of a given container.
-   Added `melon/container/stop` to stop a given container.
-   Added `melon/container/start` to start a given container.
-   Added `melon/container/add_env` to add an environment variable to a given container.
-   Added `melon/container/add_exposed_port` to add an exposed port to a given container.
-   Added `melon/container/set_working_directory` to set the working directory of a given container.
-   Added `melon/container/set_command` to set the command of a given container.
-   Added `melon/container/set_entrypoint` to set the entrypoint of a given container.
-   Added `melon/container/set_user` to set the user of a given container.
-   Added `melon/container/new` to create a new container.

[unreleased]: https://github.com/patrik-kuehl/melon/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/patrik-kuehl/melon/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/patrik-kuehl/melon/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/patrik-kuehl/melon/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/patrik-kuehl/melon/releases/tag/v0.1.0
