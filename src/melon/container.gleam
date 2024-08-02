import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleamyshell.{type CommandOutput, CommandOutput}

/// The error type to represent the reason why a container
/// could not be started.
pub type ContainerStartFailure {
  CouldNotStartContainer(reason: String)
}

/// The error type to represent a reason why a container
/// could not be stopped.
pub type ContainerStopFailure {
  CannotStopContainerThatIsNotRunning
  CouldNotStopContainer(reason: String)
}

/// The error type to represent a reason why the health status
/// of a container could not be obtained.
pub type ContainerHealthStatusFailure {
  CannotObtainHealthStatusOfContainerThatIsNotRunning
  CouldNotObtainHealthStatus(reason: String)
  ContainerIsUnhealthy
}

/// The error type to represent a reason why a mapped port
/// of a container could not be found.
pub type ContainerMappedPortFailure {
  CannotObtainMappedPortOfContainerThatIsNotRunning
  CouldNotFindMappedPort
}

/// The type to specify the protocol a port is exposed via.
pub type PortProtocol {
  Tcp
  Udp
  Sctp
}

/// The type that holds information about a port.
pub type Port {
  Port(host: String, value: Int, protocol: PortProtocol)
}

/// The type to represent a memory unit.
pub type MemoryUnit {
  Byte
  Kilobyte
  Megabyte
  Gigabyte
}

/// The type to represent a time unit.
pub type TimeUnit {
  Second
  Minute
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
    memory_limit: Option(MemoryLimit),
    env_file: Option(String),
    health_check_command: Option(List(String)),
    health_check_interval: Option(HealthCheckInterval),
    health_check_timeout: Option(HealthCheckTimeout),
    health_check_start_period: Option(HealthCheckStartPeriod),
    health_check_retries: Option(Int),
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
    memory_limit: None,
    env_file: None,
    health_check_command: None,
    health_check_interval: None,
    health_check_timeout: None,
    health_check_start_period: None,
    health_check_retries: None,
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

/// Sets the memory limit of the given container.
pub fn set_memory_limit(
  container: Container,
  limit limit: Int,
  unit unit: MemoryUnit,
) -> Container {
  Container(..container, memory_limit: Some(MemoryLimit(limit, unit)))
}

/// Sets the environment file of a given container.
pub fn set_env_file(container: Container, env_file: String) -> Container {
  Container(..container, env_file: Some(env_file))
}

/// Sets the health check command of the given container.
pub fn set_health_check_command(
  container: Container,
  command: List(String),
) -> Container {
  Container(..container, health_check_command: Some(command))
}

/// Sets the health check interval of the given container.
pub fn set_health_check_interval(
  container: Container,
  interval interval: Int,
  unit unit: TimeUnit,
) -> Container {
  Container(
    ..container,
    health_check_interval: Some(HealthCheckInterval(interval, unit)),
  )
}

/// Sets the health check timeout of the given container.
pub fn set_health_check_timeout(
  container: Container,
  timeout timeout: Int,
  unit unit: TimeUnit,
) -> Container {
  Container(
    ..container,
    health_check_timeout: Some(HealthCheckTimeout(timeout, unit)),
  )
}

/// Sets the health check start period of the given container.
pub fn set_health_check_start_period(
  container: Container,
  start_period start_period: Int,
  unit unit: TimeUnit,
) -> Container {
  Container(
    ..container,
    health_check_start_period: Some(HealthCheckStartPeriod(start_period, unit)),
  )
}

/// Sets the health check retry count of the given container.
pub fn set_health_check_retries(container: Container, retries: Int) -> Container {
  Container(..container, health_check_retries: Some(retries))
}

/// Adds an exposed port to the given container.
pub fn add_exposed_port(
  container: Container,
  host host: String,
  port port: Int,
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
pub fn start(container: Container) -> Result(Container, ContainerStartFailure) {
  let arguments =
    ["run", "--rm"]
    |> list.append(user_to_arg(container.user))
    |> list.append(entrypoint_to_arg(container.entrypoint))
    |> list.append(working_directory_to_arg(container.working_directory))
    |> list.append(memory_limit_to_arg(container.memory_limit))
    |> list.append(env_file_to_arg(container.env_file))
    |> list.append(health_check_command_to_arg(container.health_check_command))
    |> list.append(health_check_interval_to_arg(container.health_check_interval))
    |> list.append(health_check_timeout_to_arg(container.health_check_timeout))
    |> list.append(health_check_start_period_to_arg(
      container.health_check_start_period,
    ))
    |> list.append(health_check_retries_to_arg(container.health_check_retries))
    |> list.append(list.flat_map(container.exposed_ports, port_to_arg))
    |> list.append(list.flat_map(container.environment, env_to_arg))
    |> list.append(["-d", container.image])
    |> list.append(option.unwrap(container.command, []))

  case docker_cmd(arguments) {
    Ok(CommandOutput(0, output)) ->
      case string.trim(output) |> string.split("\n") |> list.last() {
        Error(_) -> string.trim(output) |> CouldNotStartContainer() |> Error()
        Ok(container_id) ->
          Container(..container, id: string.trim(container_id) |> Some())
          |> Ok()
      }
    Ok(CommandOutput(_, output)) ->
      string.trim(output) |> CouldNotStartContainer() |> Error()
    Error(reason) -> string.trim(reason) |> CouldNotStartContainer() |> Error()
  }
}

/// Stops the given container.
pub fn stop(container: Container) -> Result(Container, ContainerStopFailure) {
  case container.id {
    None -> Error(CannotStopContainerThatIsNotRunning)
    Some(container_id) ->
      case docker_cmd(["stop", container_id]) {
        Ok(CommandOutput(0, _)) -> Container(..container, id: None) |> Ok()
        Ok(CommandOutput(_, output)) ->
          string.trim(output) |> CouldNotStopContainer() |> Error()
        Error(reason) ->
          string.trim(reason) |> CouldNotStopContainer() |> Error()
      }
  }
}

/// Waits until the given container is healthy. It fails if all retries
/// are exhausted.
pub fn wait_until_healthy(
  container: Container,
  retries retries: Int,
) -> Result(Container, ContainerHealthStatusFailure) {
  case container.id {
    None -> Error(CannotObtainHealthStatusOfContainerThatIsNotRunning)
    Some(container_id) ->
      case retries {
        _ if retries < 0 -> do_wait_until_healthy(container, container_id, 0)
        _ -> do_wait_until_healthy(container, container_id, retries)
      }
  }
}

/// Returns a mapped port of the given container.
pub fn mapped_port(
  container: Container,
  port port: Int,
  protocol protocol: PortProtocol,
) -> Result(Port, ContainerMappedPortFailure) {
  case container.id {
    None -> Error(CannotObtainMappedPortOfContainerThatIsNotRunning)
    Some(container_id) ->
      case
        docker_cmd([
          "port",
          container_id,
          int.to_string(port)
            <> "/"
            <> string.inspect(protocol) |> string.lowercase(),
        ])
      {
        Ok(CommandOutput(0, output)) ->
          case string.trim(output) |> string.split(":") {
            [host, value, ..] ->
              case int.parse(value) {
                Error(_) -> Error(CouldNotFindMappedPort)
                Ok(int_value) -> Port(host, int_value, protocol) |> Ok()
              }
            _ -> Error(CouldNotFindMappedPort)
          }
        _ -> Error(CouldNotFindMappedPort)
      }
  }
}

type EnvironmentVariable {
  EnvironmentVariable(identifier: String, value: String)
}

type MemoryLimit {
  MemoryLimit(limit: Int, unit: MemoryUnit)
}

type HealthCheckInterval {
  HealthCheckInterval(interval: Int, unit: TimeUnit)
}

type HealthCheckTimeout {
  HealthCheckTimeout(timeout: Int, unit: TimeUnit)
}

type HealthCheckStartPeriod {
  HealthCheckStartPeriod(start_period: Int, unit: TimeUnit)
}

fn docker_cmd(args: List(String)) -> Result(CommandOutput, String) {
  gleamyshell.execute("docker", in: ".", args: args)
}

fn do_wait_until_healthy(
  container: Container,
  container_id: String,
  retries: Int,
) -> Result(Container, ContainerHealthStatusFailure) {
  case retries == -1 {
    True -> Error(ContainerIsUnhealthy)
    False ->
      case
        docker_cmd([
          "inspect",
          "--format",
          "{{.State.Health.Status}}",
          container_id,
        ])
      {
        Error(reason) ->
          string.trim(reason)
          |> CouldNotObtainHealthStatus()
          |> Error()
        Ok(CommandOutput(0, output)) ->
          case is_healthy(output) {
            True -> Ok(container)
            False -> {
              sleep(1000)

              do_wait_until_healthy(container, container_id, retries - 1)
            }
          }
        Ok(CommandOutput(_, output)) ->
          string.trim(output) |> CouldNotObtainHealthStatus() |> Error()
      }
  }
}

fn is_healthy(output: String) -> Bool {
  string.trim(output) |> string.lowercase() == "healthy"
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

fn memory_limit_to_arg(memory_limit: Option(MemoryLimit)) -> List(String) {
  case memory_limit {
    None -> []
    Some(MemoryLimit(limit, unit)) -> [
      "-m",
      int.to_string(limit) <> unit_to_string(unit),
    ]
  }
}

fn env_file_to_arg(env_file: Option(String)) -> List(String) {
  case env_file {
    None -> []
    Some(file) -> ["--env-file", file]
  }
}

fn health_check_command_to_arg(command: Option(List(String))) -> List(String) {
  case command {
    None -> []
    Some(value) -> ["--health-cmd", string.join(value, " ")]
  }
}

fn health_check_interval_to_arg(
  interval: Option(HealthCheckInterval),
) -> List(String) {
  case interval {
    None -> []
    Some(value) -> [
      "--health-interval",
      int.to_string(value.interval) <> unit_to_string(value.unit),
    ]
  }
}

fn health_check_timeout_to_arg(
  interval: Option(HealthCheckTimeout),
) -> List(String) {
  case interval {
    None -> []
    Some(value) -> [
      "--health-timeout",
      int.to_string(value.timeout) <> unit_to_string(value.unit),
    ]
  }
}

fn health_check_start_period_to_arg(
  interval: Option(HealthCheckStartPeriod),
) -> List(String) {
  case interval {
    None -> []
    Some(value) -> [
      "--health-start-period",
      int.to_string(value.start_period) <> unit_to_string(value.unit),
    ]
  }
}

fn health_check_retries_to_arg(retries: Option(Int)) {
  case retries {
    None -> []
    Some(value) -> ["--health-retries", int.to_string(value)]
  }
}

fn port_to_arg(port: Port) -> List(String) {
  [
    "-p",
    port.host
      <> ":0:"
      <> int.to_string(port.value)
      <> "/"
      <> string.inspect(port.protocol) |> string.lowercase(),
  ]
}

fn env_to_arg(env: EnvironmentVariable) -> List(String) {
  ["-e", env.identifier <> "=" <> env.value]
}

fn unit_to_string(unit: a) -> String {
  let assert Ok(value) = string.inspect(unit) |> string.first()

  value |> string.lowercase()
}

@external(erlang, "timer", "sleep")
@external(javascript, "../melon_ffi.mjs", "sleep")
fn sleep(milliseconds: Int) -> Nil
