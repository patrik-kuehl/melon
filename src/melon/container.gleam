import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleamyshell.{type CommandOutput, CommandOutput}

/// The error type to represent a reason why a container
/// operation failed.
pub type ContainerFailure {
  ContainerIsNotRunning
  ContainerCouldNotBeStarted(reason: String)
  ContainerCouldNotBeStopped(reason: String)
  MappedPortCouldNotBeFound
}

/// The type to specify the protocol a port is exposed via.
pub type PortProtocol {
  Tcp
  Udp
  Sctp
}

/// The type that holds information about a port.
pub type Port {
  Port(host: String, value: String, protocol: PortProtocol)
}

/// The type that holds information about a container.
pub opaque type Container {
  Container(
    id: Option(String),
    image: String,
    user: Option(String),
    entrypoint: Option(String),
    command: Option(List(String)),
    working_directory: Option(String),
    exposed_ports: List(Port),
    environment: List(EnvironmentVariable),
  )
}

/// Creates a new container using the given image.
/// 
/// Remaining properties of the container can be configured
/// via various setter functions in this module.
pub fn new(image: String) -> Container {
  Container(
    id: None,
    image: image,
    user: None,
    entrypoint: None,
    command: None,
    working_directory: None,
    exposed_ports: [],
    environment: [],
  )
}

/// Sets the user of the given container.
pub fn set_user(container: Container, user: String) -> Container {
  Container(..container, user: Some(user))
}

/// Sets the entrypoint of the given container.
pub fn set_entrypoint(container: Container, entrypoint: String) -> Container {
  Container(..container, entrypoint: Some(entrypoint))
}

/// Sets the command of the given container.
pub fn set_command(container: Container, command: List(String)) -> Container {
  Container(..container, command: Some(command))
}

/// Sets the working directory of the given container.
pub fn set_working_directory(
  container: Container,
  working_directory: String,
) -> Container {
  Container(..container, working_directory: Some(working_directory))
}

/// Adds an exposed port to the given container.
pub fn add_exposed_port(
  container: Container,
  host host: String,
  port port: String,
  protocol protocol: PortProtocol,
) -> Container {
  Container(
    ..container,
    exposed_ports: [Port(host, port, protocol), ..container.exposed_ports],
  )
}

/// Adds an environment variable to the given container.
pub fn add_env(
  container: Container,
  name identifier: String,
  value value: String,
) -> Container {
  Container(
    ..container,
    environment: [
      EnvironmentVariable(identifier, value),
      ..container.environment
    ],
  )
}

/// Starts the given container.
pub fn start(container: Container) -> Result(Container, ContainerFailure) {
  let arguments =
    ["run", "--rm"]
    |> list.append(user_to_arg(container.user))
    |> list.append(entrypoint_to_arg(container.entrypoint))
    |> list.append(working_directory_to_arg(container.working_directory))
    |> list.append(list.flat_map(container.exposed_ports, port_to_arg))
    |> list.append(list.flat_map(container.environment, env_to_arg))
    |> list.append(["-d", container.image])
    |> list.append(option.unwrap(container.command, []))

  case docker_cmd(arguments) {
    Ok(CommandOutput(0, output)) ->
      case string.trim(output) |> string.split("\n") |> list.last() {
        Error(_) ->
          string.trim(output) |> ContainerCouldNotBeStarted() |> Error()
        Ok(container_id) ->
          Container(..container, id: string.trim(container_id) |> Some())
          |> Ok()
      }
    Ok(CommandOutput(_, output)) ->
      string.trim(output) |> ContainerCouldNotBeStarted() |> Error()
    Error(reason) ->
      string.trim(reason) |> ContainerCouldNotBeStarted() |> Error()
  }
}

/// Stops the given container.
pub fn stop(container: Container) -> Result(Container, ContainerFailure) {
  case container.id {
    None -> Error(ContainerIsNotRunning)
    Some(container_id) ->
      case docker_cmd(["stop", container_id]) {
        Ok(CommandOutput(0, _)) -> Container(..container, id: None) |> Ok()
        Ok(CommandOutput(_, output)) ->
          string.trim(output) |> ContainerCouldNotBeStopped() |> Error()
        Error(reason) ->
          string.trim(reason) |> ContainerCouldNotBeStopped() |> Error()
      }
  }
}

/// Returns a mapped port of the given container.
pub fn mapped_port(
  container: Container,
  port port: String,
  protocol protocol: PortProtocol,
) -> Result(Port, ContainerFailure) {
  case container.id {
    None -> Error(ContainerIsNotRunning)
    Some(container_id) ->
      case
        docker_cmd([
          "port",
          container_id,
          port <> "/" <> string.inspect(protocol) |> string.lowercase(),
        ])
      {
        Ok(CommandOutput(0, output)) ->
          case string.trim(output) |> string.split(":") {
            [host, value, ..] -> Port(host, value, protocol) |> Ok()
            _ -> Error(MappedPortCouldNotBeFound)
          }
        _ -> Error(MappedPortCouldNotBeFound)
      }
  }
}

type EnvironmentVariable {
  EnvironmentVariable(identifier: String, value: String)
}

fn docker_cmd(args: List(String)) -> Result(CommandOutput, String) {
  gleamyshell.execute("docker", in: ".", args: args)
}

fn user_to_arg(user: Option(String)) -> List(String) {
  case user {
    None -> []
    Some(value) -> ["-u", value]
  }
}

fn entrypoint_to_arg(entrypoint: Option(String)) -> List(String) {
  case entrypoint {
    None -> []
    Some(value) -> ["--entrypoint", value]
  }
}

fn working_directory_to_arg(working_directory: Option(String)) -> List(String) {
  case working_directory {
    None -> []
    Some(value) -> ["-w", value]
  }
}

fn port_to_arg(port: Port) -> List(String) {
  [
    "-p",
    port.host
      <> ":0:"
      <> port.value
      <> "/"
      <> string.inspect(port.protocol) |> string.lowercase(),
  ]
}

fn env_to_arg(env: EnvironmentVariable) -> List(String) {
  ["-e", env.identifier <> "=" <> env.value]
}
