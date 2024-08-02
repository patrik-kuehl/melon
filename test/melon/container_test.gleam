import gleam/string
import gleamyshell.{Windows}
import gleeunit/should
import melon/container.{
  type Port, CannotObtainHealthStatusOfContainerThatIsNotRunning,
  CannotStopContainerThatIsNotRunning, CouldNotObtainHealthStatus,
  CouldNotStartContainer, Gigabyte, Kilobyte, Megabyte, Port, Sctp, Second, Tcp,
  Udp,
}
import prelude.{because}

@target(erlang)
import qcheck_gleeunit_utils/test_spec

@target(erlang)
pub fn adminer_test_() {
  use <- test_spec.make()

  adminer_container_actions()
}

@target(javascript)
pub fn adminer_test() {
  adminer_container_actions()
}

@target(erlang)
pub fn postgres_test_() {
  use <- test_spec.make()

  postgres_container_actions()
}

@target(javascript)
pub fn postgres_test() {
  postgres_container_actions()
}

@target(erlang)
pub fn mapped_ports_test_() {
  use <- test_spec.make()

  mapped_port_actions()
}

@target(javascript)
pub fn mapped_ports_test() {
  mapped_port_actions()
}

@target(erlang)
pub fn mapped_sctp_ports_test_() {
  use <- test_spec.make()

  mapped_sctp_port_actions()
}

@target(javascript)
pub fn mapped_sctp_ports_test() {
  mapped_sctp_port_actions()
}

@target(erlang)
pub fn invalid_arguments_test_() {
  use <- test_spec.make()

  invalid_argument_actions()
}

@target(javascript)
pub fn invalid_arguments_test() {
  invalid_argument_actions()
}

@target(erlang)
pub fn env_file_test_() {
  use <- test_spec.make()

  env_file_actions()
}

@target(javascript)
pub fn env_file_test() {
  env_file_actions()
}

fn adminer_container_actions() {
  container.new("adminer:4.8.1-standalone")
  |> container.set_memory_limit(limit: 256, unit: Megabyte)
  |> container.add_exposed_port(host: "127.0.0.1", port: 8080, protocol: Tcp)
  |> container.start()
  |> should.be_ok()
  |> because("the container could be created and started")
  |> container.stop()
  |> should.be_ok()
  |> because("the container could be stopped")
  |> container.stop()
  |> should.be_error()
  |> should.equal(CannotStopContainerThatIsNotRunning)
  |> because("the container was not running")
}

fn postgres_container_actions() {
  let image = "postgres:16.3-alpine3.20"

  container.new(image)
  |> container.set_memory_limit(limit: 1, unit: Gigabyte)
  |> container.set_health_check_command(["pg_isready", "-d", "morty_smith"])
  |> container.set_health_check_interval(interval: 2, unit: Second)
  |> container.set_health_check_timeout(timeout: 5, unit: Second)
  |> container.set_health_check_start_period(start_period: 2, unit: Second)
  |> container.set_health_check_retries(10)
  |> container.add_exposed_port(host: "127.0.0.1", port: 5432, protocol: Tcp)
  |> container.add_env(name: "POSTGRES_USER", value: "postgres")
  |> container.add_env(name: "POSTGRES_DB", value: "morty_smith")
  |> container.add_env(name: "POSTGRES_PASSWORD", value: "rick_sanchez")
  |> container.start()
  |> should.be_ok()
  |> because("the container could be created and started")
  |> container.wait_until_healthy(retries: 10)
  |> should.be_ok()
  |> because("the database set up was successful")
  |> container.stop()
  |> should.be_ok()
  |> because("the container could be stopped")
  |> container.stop()
  |> should.be_error()
  |> should.equal(CannotStopContainerThatIsNotRunning)
  |> because("the container was not running")

  let container =
    container.new(image)
    |> container.set_memory_limit(limit: 512, unit: Megabyte)
    |> container.add_exposed_port(host: "127.0.0.1", port: 5432, protocol: Tcp)
    |> container.add_env(name: "POSTGRES_USER", value: "postgres")
    |> container.add_env(name: "POSTGRES_DB", value: "morty_smith")
    |> container.add_env(name: "POSTGRES_PASSWORD", value: "rick_sanchez")
    |> container.start()
    |> should.be_ok()
    |> because("the container could be created and started")

  let assert CouldNotObtainHealthStatus(error_message) =
    container
    |> container.wait_until_healthy(retries: 3)
    |> should.be_error()

  error_message
  |> string.starts_with("template parsing error: ")
  |> should.be_true()
  |> because("no health check was configured")

  let _ = container.stop(container)

  let container =
    container.new(image)
    |> container.set_memory_limit(limit: 1, unit: Gigabyte)
    |> container.set_health_check_command(["pg_isready", "-d", "morty_smith"])
    |> container.set_health_check_interval(interval: 2, unit: Second)
    |> container.set_health_check_timeout(timeout: 5, unit: Second)
    |> container.set_health_check_start_period(start_period: 2, unit: Second)
    |> container.set_health_check_retries(10)
    |> container.add_exposed_port(host: "127.0.0.1", port: 5432, protocol: Tcp)
    |> container.add_env(name: "POSTGRES_USER", value: "postgres")
    |> container.add_env(name: "POSTGRES_DB", value: "morty_smith")
    |> container.add_env(name: "POSTGRES_PASSWORD", value: "rick_sanchez")

  container
  |> container.wait_until_healthy(retries: 10)
  |> should.be_error()
  |> should.equal(CannotObtainHealthStatusOfContainerThatIsNotRunning)
  |> because("the container was not running")
}

fn mapped_port_actions() {
  let container =
    container.new("memcached:1.6.29-alpine3.20")
    |> container.add_exposed_port(host: "127.0.0.1", port: 8000, protocol: Tcp)
    |> container.add_exposed_port(host: "127.0.0.1", port: 8090, protocol: Udp)
    |> container.start()
    |> should.be_ok()
    |> because("the container could be created and started")

  let assert Port("127.0.0.1", mapped_tcp_port, Tcp) =
    container
    |> container.mapped_port(port: 8000, protocol: Tcp)
    |> should.be_ok()
    |> because("the mapped port could be found")

  let assert Port("127.0.0.1", mapped_udp_port, Udp) =
    container
    |> container.mapped_port(port: 8090, protocol: Udp)
    |> should.be_ok()
    |> because("the mapped port could be found")

  mapped_tcp_port
  |> should.not_equal(8000)
  |> because("the mapped port is randomly assigned")

  mapped_udp_port
  |> should.not_equal(8090)
  |> because("the mapped port is randomly assigned")

  container.stop(container)
}

fn mapped_sctp_port_actions() {
  case gleamyshell.os() {
    Windows -> Nil
    _ -> {
      let container =
        container.new("nginx:1.27.0-alpine3.19")
        |> container.add_exposed_port(host: "0.0.0.0", port: 80, protocol: Sctp)
        |> container.start()
        |> should.be_ok()
        |> because("the container could be created and started")

      let assert Port("0.0.0.0", mapped_sctp_port, Sctp) =
        container
        |> container.mapped_port(port: 80, protocol: Sctp)
        |> should.be_ok()
        |> because("the mapped port could be found")

      mapped_sctp_port
      |> should.not_equal(80)
      |> because("the mapped port is randomly assigned")

      let _ = container |> container.stop()

      Nil
    }
  }
}

fn invalid_argument_actions() {
  let deno_image = "denoland/deno:alpine-1.45.2"

  container.new("___")
  |> container.start()
  |> should.be_error()
  |> should.equal(CouldNotStartContainer(
    "docker: invalid reference format.\nSee 'docker run --help'.",
  ))
  |> because("the given image is invalid")

  container.new(deno_image)
  |> container.add_exposed_port(host: "127.0.0.1", port: -20, protocol: Tcp)
  |> container.start()
  |> should.be_error()
  |> should.equal(CouldNotStartContainer(
    "docker: invalid containerPort: -20.\nSee 'docker run --help'.",
  ))
  |> because("the given port is invalid")

  container.new(deno_image)
  |> container.add_exposed_port(host: "-10", port: 8080, protocol: Udp)
  |> container.start()
  |> should.be_error()
  |> should.equal(CouldNotStartContainer(
    "docker: invalid IP address: -10.\nSee 'docker run --help'.",
  ))
  |> because("the given host is invalid")
}

fn env_file_actions() {
  container.new("busybox:1.36.1-musl")
  |> container.set_memory_limit(limit: 10_240, unit: Kilobyte)
  |> container.set_env_file("./test/melon/.env.test")
  |> container.start()
  |> should.be_ok()
  |> because("the container could be created and started")
  |> container.stop()
  |> should.be_ok()
  |> because("the container could be stopped")

  let CouldNotStartContainer(error_message) =
    container.new("bash:5.1.16-alpine3.20")
    |> container.set_memory_limit(limit: 64, unit: Megabyte)
    |> container.set_env_file("i_dont_exist")
    |> container.start()
    |> should.be_error()

  error_message
  |> string.starts_with("docker: open i_dont_exist: ")
  |> should.be_true()
  |> because("the environment file does not exist")
}
