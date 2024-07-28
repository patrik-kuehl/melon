[![Package Version](https://img.shields.io/hexpm/v/melon)](https://hex.pm/packages/melon)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/melon)
![Erlang-compatible](https://img.shields.io/badge/target-erlang-a2003e)
![JavaScript-compatible](https://img.shields.io/badge/target-javascript-f1e05a)

# Melon 🍈

A Gleam library for running containers tailored to testing purposes.

Melon is inspired by [Testcontainers](https://testcontainers.com/) and provides an API to configure, start and stop
containers.

In contrast to other libraries, Melon doesn't use the [Docker Engine API](https://docs.docker.com/engine/api/), but
simply searches for and uses the `docker` executable. This makes the
[discovery methods](https://java.testcontainers.org/supported_docker_environment/#docker-environment-discovery) used by
other libraries unnecessary. You can still use a remote Docker Engine by
[configuring a context](https://code.visualstudio.com/docs/containers/ssh) accordingly.

This approach also makes it possible to support all non-browser targets (Erlang, Bun, Deno, and Node.js) without further
dependencies, as consumers of this library don't need to reach for a target-specific client like
[fetch](https://hexdocs.pm/gleam_fetch/) and [httpc](https://hexdocs.pm/gleam_httpc/) in order to communicate with the
Docker Engine API.

## Demo 🍈

```gleam
import gleam/int
import gleam/io
import melon/container.{Megabyte, Port, Second, Tcp}

pub fn main() {
  let start_result =
    container.new("postgres:16.3-alpine3.20")
    |> container.set_memory_limit(limit: 256, unit: Megabyte)
    |> container.set_health_check_command(["pg_isready", "-d", "morty_smith"])
    |> container.set_health_check_interval(interval: 10, unit: Second)
    |> container.set_health_check_timeout(timeout: 15, unit: Second)
    |> container.set_health_check_start_period(start_period: 5, unit: Second)
    |> container.set_health_check_retries(5)
    |> container.add_exposed_port(host: "127.0.0.1", port: 5432, protocol: Tcp)
    |> container.add_env(name: "POSTGRES_USER", value: "postgres")
    |> container.add_env(name: "POSTGRES_DB", value: "morty_smith")
    |> container.add_env(name: "POSTGRES_PASSWORD", value: "rick_sanchez")
    |> container.start()

  case start_result {
    Error(_) -> io.println("Couldn't start the container :(")
    Ok(container) -> {
      case container.mapped_port(container, port: 5432, protocol: Tcp) {
        Error(_) -> io.println("Couldn't find the mapped port :<")
        Ok(Port(host, port, _)) ->
          io.println(
            "The database is available on "
            <> host
            <> ":"
            <> int.to_string(port)
            <> ".",
          )
      }
    }
  }
}
```

## Changelog 🍈

Take a look at the [changelog](https://github.com/patrik-kuehl/melon/blob/main/CHANGELOG.md) to get an overview of each
release and its changes.

## Contribution Guidelines 🍈

More information can be found [here](https://github.com/patrik-kuehl/melon/blob/main/CONTRIBUTING.md).

## License 🍈

Melon is licensed under the [MIT license](https://github.com/patrik-kuehl/melon/blob/main/LICENSE.md).
