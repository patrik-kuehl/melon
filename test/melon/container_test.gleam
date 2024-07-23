import gleeunit/should
import melon/container.{
  type Port, ContainerCouldNotBeStarted, ContainerIsNotRunning, Port, Sctp, Tcp,
  Udp,
}
import prelude.{because}

@target(erlang)
import qcheck_gleeunit_utils/test_spec

@target(erlang)
pub fn adminer_test_() {
  use <- test_spec.make()

  adminer_container_test_actions()
}

@target(javascript)
pub fn adminer_test() {
  adminer_container_test_actions()
}

@target(erlang)
pub fn postgres_test_() {
  use <- test_spec.make()

  postgres_container_test_actions()
}

@target(javascript)
pub fn postgres_test() {
  postgres_container_test_actions()
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
pub fn invalid_arguments_test_() {
  use <- test_spec.make()

  invalid_argument_actions()
}

@target(javascript)
pub fn invalid_arguments_test() {
  invalid_argument_actions()
}

fn adminer_container_test_actions() {
  container.new("adminer:4.8.1-standalone")
  |> container.add_exposed_port(host: "127.0.0.1", port: "8080", protocol: Tcp)
  |> container.start()
  |> should.be_ok()
  |> because("the container could be created and started")
  |> container.stop()
  |> should.be_ok()
  |> because("the container could be stopped")
  |> container.stop()
  |> should.be_error()
  |> should.equal(ContainerIsNotRunning)
  |> because("the container was not running")
}

fn postgres_container_test_actions() {
  container.new("postgres:16.3-alpine3.20")
  |> container.add_exposed_port(host: "127.0.0.1", port: "5432", protocol: Tcp)
  |> container.add_env(name: "POSTGRES_USER", value: "postgres")
  |> container.add_env(name: "POSTGRES_DB", value: "morty_smith")
  |> container.add_env(name: "POSTGRES_PASSWORD", value: "rick_sanchez")
  |> container.start()
  |> should.be_ok()
  |> because("the container could be created and started")
  |> container.stop()
  |> should.be_ok()
  |> because("the container could be stopped")
  |> container.stop()
  |> should.be_error()
  |> should.equal(ContainerIsNotRunning)
  |> because("the container was not running")
}

fn mapped_port_actions() {
  let container =
    container.new("memcached:1.6.29-alpine3.20")
    |> container.add_exposed_port(
      host: "127.0.0.1",
      port: "8000",
      protocol: Tcp,
    )
    |> container.add_exposed_port(host: "0.0.0.0", port: "8080", protocol: Sctp)
    |> container.add_exposed_port(
      host: "127.0.0.1",
      port: "8090",
      protocol: Udp,
    )
    |> container.start()
    |> should.be_ok()
    |> because("the container could be created and started")

  let assert Port("127.0.0.1", mapped_tcp_port, Tcp) =
    container
    |> container.mapped_port(port: "8000", protocol: Tcp)
    |> should.be_ok()
    |> because("the mapped port could be found")

  let assert Port("0.0.0.0", mapped_sctp_port, Sctp) =
    container
    |> container.mapped_port(port: "8080", protocol: Sctp)
    |> should.be_ok()
    |> because("the mapped port could be found")

  let assert Port("127.0.0.1", mapped_udp_port, Udp) =
    container
    |> container.mapped_port(port: "8090", protocol: Udp)
    |> should.be_ok()
    |> because("the mapped port could be found")

  mapped_tcp_port
  |> should.not_equal("8000")
  |> because("the mapped port is randomly assigned")

  mapped_sctp_port
  |> should.not_equal("8080")
  |> because("the mapped port is randomly assigned")

  mapped_udp_port
  |> should.not_equal("8090")
  |> because("the mapped port is randomly assigned")

  container |> container.stop()
}

fn invalid_argument_actions() {
  let deno_image = "denoland/deno:alpine-1.45.2"

  container.new("___")
  |> container.start()
  |> should.be_error()
  |> should.equal(ContainerCouldNotBeStarted(
    "docker: invalid reference format.\nSee 'docker run --help'.",
  ))
  |> because("the given image is invalid")

  container.new(deno_image)
  |> container.add_exposed_port(host: "127.0.0.1", port: "-20", protocol: Tcp)
  |> container.start()
  |> should.be_error()
  |> should.equal(ContainerCouldNotBeStarted(
    "docker: invalid containerPort: -20.\nSee 'docker run --help'.",
  ))
  |> because("the given port is invalid")

  container.new(deno_image)
  |> container.add_exposed_port(host: "-10", port: "8080", protocol: Udp)
  |> container.start()
  |> should.be_error()
  |> should.equal(ContainerCouldNotBeStarted(
    "docker: invalid IP address: -10.\nSee 'docker run --help'.",
  ))
  |> because("the given host is invalid")
}
