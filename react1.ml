open Printf
open Funs

type config =
  { mutable configPath: string;
    mutable dirPath: string;
    mutable rangeSensor: string;
  }

let config = { configPath = "./"; dirPath  = "./"; rangeSensor="" }

let () =
  let args =
    [ ("-s", Arg.String (fun s -> config.configPath <- s), "config")
    ; ("-d", Arg.String (fun s -> config.dirPath <- s),    "dir")
    ; ("-r", Arg.String (fun s -> config.rangeSensor <- s),"range sensor")
    ]
  in
  Arg.parse args (fun s -> printf "Anonymous arg '%s'\n%!" s) "usage"

let () =
  if config.rangeSensor = "" then
    let () = fprintf stderr "Range sensor port is not specified" in
    exit 1


let () =
  let app = QApplication.create Sys.argv in
  let brick = Brick.create app config.configPath config.dirPath in
  let current_power = ref 10 in


  let wall_signal = TR.wrap_sensor brick config.rangeSensor in
  let onRangeChanged (data, rawData)  =
    printf "rangeChanged: (%d,%d)\t%!" data rawData
  in
  let _ = React.S.map onRangeChanged wall_signal in

  at_exit (fun () -> print_endline "Die, die, die, my darling!");

  QApplication.exec app |> ignore
