open Printf
open Funs

type config =
  { mutable configPath: string;
    mutable dirPath: string;
    mutable engineSensors: string list;
    mutable ips: string list;
  }

let config = { configPath = "./"; dirPath  = "./"; rangeSensor="A2"; engineSensors=[] }

let () =
  let args =
    [ ("-s", Arg.String (fun s -> config.configPath <- s), "config")
    ; ("-d", Arg.String (fun s -> config.dirPath <- s),    "dir")
    ; ("-e", Arg.String (fun s -> config.engineSensors <- s::config.engineSensors), "engine sensor")
    ]
  in
  Arg.parse args (fun ip -> config.ips <- ip::config.ips) "usage"

let say_hello () =
  let delay = 10 in
  while true do
    Printf.printf "Saying Hello every %d seconds\n%!" delay;
    let _ = Thread.delay (float_of_int delay) in
    ()
  done

let () =
  let app = QApplication.create Sys.argv in
  let brick = Brick.create app config.configPath config.dirPath in
  let mailbox = Mailbox.create brick (fun s -> printf "Somethis is received: '%s'\n%!" s) in

  let set_engine_power newval =
    printf "current power value = %d\n%!" newval;
    List.iter (fun s -> Motor.set_power (Brick.motor brick s) newval) config.engineSensors
  in

  let move rangeSensor =
    while true do
      let newval = Random.int 50 in
      Motor.set_power (Brick.motor brick motor) newval;
      Thread.delay 1.;
    done
  in
  let _thread_ids =
    [ Thread.create say_hello ()
    ; Thread.create move ()
    ]
  in

  at_exit (fun () -> List.iter (fun s -> Motor.set_power (Brick.motor brick s) 0) config.engineSensors);

  QApplication.exec app |> ignore



