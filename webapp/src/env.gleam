import gleam/erlang/os
import gleam/erlang/process
import gleam/int
import gleam/io

pub type Environment {
  Vars(port: Int)
  None
}

pub fn get_environment() -> Environment {
  case os.get_env("DEP_TARGET") {
    Ok("DEV") -> Vars(port: 3000)
    Ok("PROD") -> {
      let assert Ok(port) =
        os.get_env("PORT")
        |> unwrap_var
        |> int.parse

      Vars(port: port)
    }
    Ok(e) -> {
      io.println("Unsupported DEP_TARGET \"" <> e <> "\".")
      process.kill(process.self())
      None
    }
    Error(_) -> {
      io.println("WARNING: No DEP_TARGET variable set")
      Vars(port: 3000)
    }
  }
  Vars(port: 3000)
}

fn unwrap_var(r: Result(String, Nil)) -> String {
  case r {
    Ok(x) -> x
    Error(_) -> {
      io.println("Failed to unwrap var")
      ""
    }
  }
}
