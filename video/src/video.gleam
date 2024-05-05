import gleam/erlang/process.{type Subject}
import gleam/float
import gleam/int
import gleam/io
import gleam/result
import gleam/string
import peggy
import peggy/ffprobe

// IDEA: perhaps this should be set up in reverse where the
//  caller can listen for messages giving status updates on
//  the video processing's progress. I think this idea might
//  be a bit more straight-forward. I need to research how
//  other apps tend to handle this though.

pub type VideoUpdate {
  Compressing
  Chunking
  Saving
  Done

  Failed(String)
}

pub fn start_process(caller: Subject(VideoUpdate), id, file_path) {
  // get vid info
  let end =
    file_path
    |> ffprobe.get_duration
    |> result.unwrap(0.0)
    |> float.ceiling
    |> float.truncate
  // compress video (only sometimes works? LOL)
  case
    peggy.new_command()
    |> peggy.input(file_path)
    |> peggy.video_codec("libx264")
    |> peggy.audio_codec("mp2")
    |> peggy.output(id <> "_compressed.mp4")
    |> peggy.exec_sync
  {
    Ok(_) -> {
      // for now, just chunking the compressed file,
      //  in the future, need to chunk versions of varying resolutions
      case chunk_video(id, id <> "_compressed.mp4", end, 5, 0) {
        Ok(_) -> {
          // store files
          Nil
        }
        Error(es) -> {
          es
          |> io.println
          Nil
        }
      }
      Nil
    }
    Error(msg) -> {
      process.send(caller, Failed(msg))
      Nil
    }
  }
}

fn chunk_video(id, file_path, duration, chunk_size, count) {
  let start = count * chunk_size
  let end = start + chunk_size
  case start > duration {
    True -> Ok(Nil)
    False -> {
      io.println("Chunking some more")
      case
        peggy.new_command()
        |> peggy.fmt("mp4")
        //|> peggy.seek(start)
        |> peggy.add_arg(
          "-ss",
          to_timestamp(start)
            |> io.debug,
        )
        |> peggy.until(
          to_timestamp(end)
          |> io.debug,
        )
        |> peggy.input(file_path)
        |> peggy.codec("copy")
        |> peggy.add_arg("-crf", "24")
        |> peggy.add_arg("-avoid_negative_ts", "make_zero")
        |> peggy.output(id <> "_chunk_" <> int.to_string(count) <> ".mp4")
        |> io.debug
        |> peggy.exec_sync
        |> io.debug
      {
        Ok(_) -> chunk_video(id, file_path, duration, chunk_size, count + 1)
        Error(es) -> Error(es)
      }
    }
  }
}

fn to_timestamp(seconds) {
  let secs =
    seconds % 60
    |> int.to_string
  let mins =
    { seconds / 60 } % 60
    |> int.to_string
  let hour =
    { { seconds / 60 } / 60 } % 24
    |> int.to_string
  string.pad_left(hour, 2, "0")
  <> ":"
  <> string.pad_left(mins, 2, "0")
  <> ":"
  <> string.pad_left(secs, 2, "0")
}
